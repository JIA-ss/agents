---
name: etl-processor
description: >
  ETL 数据处理系统专家，负责数据抽取、转换、加载的完整管道设计与实现。
  Use when the user asks to "implement data pipeline", "debug ETL job",
  "optimize data transformation", "configure data source", "fix data loading errors",
  mentions "ETLPipeline", "DataExtractor", "DataTransformer", "DataLoader", "TaskScheduler",
  or needs help with data ingestion, transformation rules and batch processing.
  Also responds to "实现数据管道", "调试ETL任务", "优化数据转换", "配置数据源", "修复数据加载错误".
related-skills: [data-quality, task-scheduler, monitoring-system]
deprecated: false
superseded-by: ""
---

# ETL Processor 数据处理系统指南

## Overview

ETL 数据处理系统专家，精通数据抽取（Extract）、转换（Transform）、加载（Load）全流程。负责管理多源数据接入、转换规则引擎、批量写入和任务调度。

**核心能力**：
- **数据抽取**：支持 REST API、数据库、CSV/JSON 文件、消息队列等多种数据源
- **数据转换**：基于规则引擎的数据清洗、映射、聚合、校验
- **数据加载**：批量写入 PostgreSQL，支持 upsert、增量和全量模式
- **任务调度**：基于 Celery + Redis 的分布式任务调度与监控

**核心职责**：
- 诊断和解决 ETL 任务失败（数据源不可达、转换异常、写入冲突）
- 优化大数据量处理性能（批量大小、并发度、内存控制）
- 配置和管理数据源连接与转换规则
- 实现新数据管道和数据质量校验规则

## Core Rules

### 规则 1: ETL 任务必须实现幂等性

**同一批数据重复执行 ETL 不应产生重复记录或数据错误：**
```python
# !! 错误：直接 INSERT，重复执行会产生重复数据
async def load_data(records: list[dict], session: AsyncSession):
    for record in records:
        session.add(DataRecord(**record))
    await session.commit()

# >> 正确：使用 upsert（INSERT ON CONFLICT）保证幂等性
from sqlalchemy.dialects.postgresql import insert

async def load_data(records: list[dict], session: AsyncSession):
    stmt = insert(DataRecord).values(records)
    stmt = stmt.on_conflict_do_update(
        index_elements=["source_id", "record_date"],
        set_={
            "value": stmt.excluded.value,
            "updated_at": func.now(),
        },
    )
    await session.execute(stmt)
    await session.commit()
```

### 规则 2: 大数据量必须分批处理，禁止一次性加载到内存

**处理大量数据时必须使用流式处理或分批读取，防止内存溢出：**
```python
# !! 错误：一次性读取全部数据到内存
async def extract_all(source_url: str) -> list[dict]:
    response = await client.get(source_url)
    return response.json()  # 可能返回数百万条记录

# >> 正确：使用异步生成器分批读取
async def extract_batched(
    source_url: str, batch_size: int = 1000
) -> AsyncGenerator[list[dict], None]:
    offset = 0
    while True:
        response = await client.get(
            source_url, params={"offset": offset, "limit": batch_size}
        )
        batch = response.json()
        if not batch:
            break
        yield batch
        offset += batch_size

# 使用方式
async for batch in extract_batched(url):
    transformed = await transform(batch)
    await load_data(transformed, session)
```

### 规则 3: 转换逻辑必须与 IO 操作解耦

**Transform 阶段必须是纯函数，不得包含数据库查询或网络请求：**
```python
# !! 错误：转换函数中混入 IO 操作
async def transform_record(record: dict, session: AsyncSession) -> dict:
    category = await session.execute(
        select(Category).where(Category.code == record["cat_code"])
    )  # IO 操作耦合在转换逻辑中
    return {**record, "category_id": category.scalar_one().id}

# >> 正确：预加载映射表，转换函数保持纯粹
async def load_category_mapping(session: AsyncSession) -> dict[str, int]:
    result = await session.execute(select(Category.code, Category.id))
    return {row.code: row.id for row in result.all()}

def transform_record(record: dict, category_map: dict[str, int]) -> dict:
    """纯函数：无 IO 依赖，易于测试"""
    category_id = category_map.get(record["cat_code"])
    if category_id is None:
        raise TransformError(f"未知分类代码: {record['cat_code']}")
    return {**record, "category_id": category_id}
```

### 规则 4: 所有 ETL 任务必须记录详细执行日志

**每次 ETL 执行必须记录开始时间、处理数量、成功/失败数、耗时等指标：**
```python
# !! 错误：无日志，出问题无法排查
async def run_pipeline(source_id: str):
    data = await extract(source_id)
    result = transform(data)
    await load(result)

# >> 正确：完整的执行日志记录
async def run_pipeline(source_id: str) -> PipelineResult:
    job = await PipelineJob.create(
        source_id=source_id, status="running", started_at=datetime.utcnow()
    )
    try:
        extracted_count = 0
        loaded_count = 0
        error_count = 0

        async for batch in extract_batched(source_id):
            extracted_count += len(batch)
            transformed, errors = transform_batch(batch)
            error_count += len(errors)
            await load_data(transformed, session)
            loaded_count += len(transformed)

        job.status = "completed"
        job.extracted_count = extracted_count
        job.loaded_count = loaded_count
        job.error_count = error_count
        logger.info(
            f"管道完成: 抽取={extracted_count}, 加载={loaded_count}, 失败={error_count}"
        )
    except Exception as e:
        job.status = "failed"
        job.error_message = str(e)
        logger.exception(f"管道执行失败: {source_id}")
        raise
    finally:
        job.finished_at = datetime.utcnow()
        await job.save()

    return PipelineResult(job=job)
```

### 规则 5: 数据库连接必须使用连接池和 async session

**禁止手动管理连接生命周期，统一使用 SQLAlchemy async session：**
```python
# !! 错误：手动创建连接
import psycopg2
conn = psycopg2.connect(DATABASE_URL)
cursor = conn.cursor()
cursor.execute("INSERT INTO ...")

# >> 正确：使用 SQLAlchemy 异步引擎和 session
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
)
async_session = async_sessionmaker(engine, expire_on_commit=False)

async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session
```

## Reference Files

**核心实现**：
```
app/etl/
├── pipeline.py                      # ETL 管道主调度逻辑
├── extractors/
│   ├── base.py                      # 抽取器基类
│   ├── api_extractor.py             # REST API 数据抽取
│   ├── db_extractor.py              # 数据库数据抽取
│   └── file_extractor.py            # 文件数据抽取（CSV/JSON）
├── transformers/
│   ├── base.py                      # 转换器基类
│   ├── field_mapper.py              # 字段映射转换
│   ├── data_cleaner.py              # 数据清洗
│   └── aggregator.py                # 数据聚合
├── loaders/
│   ├── base.py                      # 加载器基类
│   └── postgres_loader.py           # PostgreSQL 批量写入
└── models/
    ├── pipeline_job.py              # 管道任务记录模型
    └── data_source.py               # 数据源配置模型
```

**配置文件**：
```
app/core/
├── config.py                        # 全局配置（Pydantic Settings）
└── database.py                      # 数据库连接池配置
```

**测试文件**：
```
tests/etl/
├── test_pipeline.py                 # 管道集成测试
├── test_extractors.py               # 抽取器单元测试
├── test_transformers.py             # 转换器单元测试（纯函数，无 IO mock）
├── test_loaders.py                  # 加载器单元测试
└── conftest.py                      # 测试 fixtures（数据库 session、mock 数据）
```

## Workflow

### 1. ETL 任务故障诊断流程

**Step 1: 确认故障阶段**
```
检查点：
- 查看 PipelineJob 表中该任务的 status 和 error_message
- 确定故障发生在 Extract / Transform / Load 哪个阶段
- 检查 extracted_count 和 loaded_count 判断中断位置
```

**Step 2: 按阶段排查**
```
Extract 阶段失败：
  - 数据源是否可达（网络/认证/权限）
  - 数据格式是否变化（schema drift）
  - 是否超过 API 限流

Transform 阶段失败：
  - 映射表是否缺少新增的枚举值
  - 数据中是否有非法格式（日期、数值）
  - 是否有空值/NULL 未正确处理

Load 阶段失败：
  - 数据库连接池是否耗尽
  - 是否有唯一约束冲突
  - 磁盘空间是否充足
```

**Step 3: 修复并重跑**
```
- 修复根因后，利用幂等性直接重新执行整个管道
- 如果数据量大，可指定 offset 从中断位置继续
- 检查重跑后的 PipelineJob 记录确认修复
```

### 2. 新数据管道开发流程

**需求分析 --> 数据源对接 --> 转换规则 --> 加载配置 --> 测试 --> 上线**

#### 开发检查清单

| 阶段 | 任务 | 说明 |
|------|------|------|
| **分析** | 确认数据源格式和量级 | 评估批处理 vs 流式 |
| **分析** | 确认目标表结构 | 创建 Alembic 迁移 |
| **开发** | 实现 Extractor | 继承 BaseExtractor |
| **开发** | 实现 Transformer | 纯函数，无 IO |
| **开发** | 实现 Loader | upsert 保证幂等 |
| **开发** | 配置调度任务 | Celery beat 定时 |
| **测试** | 编写单元测试 | Transform 100% 覆盖 |
| **测试** | 执行集成测试 | 使用测试数据库 |
| **上线** | 配置环境变量 | 数据源凭证 |
| **上线** | 设置告警规则 | 失败/超时自动通知 |

#### 关键参数说明

**批处理参数：**
```python
BATCH_SIZE (1000)              # 每批处理记录数
MAX_CONCURRENT_TASKS (4)       # 最大并发任务数
TASK_TIMEOUT (3600)            # 任务超时时间（秒）
RETRY_MAX_ATTEMPTS (3)         # 最大重试次数
RETRY_BACKOFF_BASE (60)        # 重试退避基础时间（秒）
```

**数据库连接池参数：**
```python
POOL_SIZE (20)                 # 连接池大小
MAX_OVERFLOW (10)              # 最大溢出连接数
POOL_PRE_PING (True)           # 连接健康检查
POOL_RECYCLE (3600)            # 连接回收时间（秒）
```

## Best Practices

### 实践 1: 使用 Pydantic 模型校验 ETL 数据

**在 Transform 阶段使用 Pydantic 进行数据校验，自动捕获格式错误：**
```python
from pydantic import BaseModel, field_validator
from datetime import date

class SalesRecord(BaseModel):
    product_id: str
    sale_date: date
    quantity: int
    amount_cents: int

    @field_validator("quantity")
    @classmethod
    def quantity_must_be_positive(cls, v: int) -> int:
        if v <= 0:
            raise ValueError(f"数量必须为正数，实际值: {v}")
        return v

def transform_batch(raw_records: list[dict]) -> tuple[list[dict], list[dict]]:
    valid, errors = [], []
    for record in raw_records:
        try:
            validated = SalesRecord(**record)
            valid.append(validated.model_dump())
        except ValidationError as e:
            errors.append({"record": record, "error": str(e)})
    return valid, errors
```

### 实践 2: 实现断点续传支持

**记录每批处理的 offset，失败后可从中断处继续：**
```python
async def run_with_checkpoint(
    source_id: str, resume_from: int = 0
) -> None:
    async for batch in extract_batched(source_id, offset=resume_from):
        transformed, _ = transform_batch(batch)
        await load_data(transformed, session)
        # 更新 checkpoint
        await update_checkpoint(source_id, offset=resume_from + len(batch))
        resume_from += len(batch)
```

### 实践 3: 敏感数据脱敏处理

**在 Transform 阶段对敏感字段进行脱敏，再写入目标表：**
```python
import hashlib

def mask_sensitive_fields(record: dict) -> dict:
    """脱敏处理：手机号中间四位打码，身份证号哈希"""
    if "phone" in record and record["phone"]:
        phone = record["phone"]
        record["phone_masked"] = phone[:3] + "****" + phone[-4:]
        del record["phone"]

    if "id_card" in record and record["id_card"]:
        record["id_card_hash"] = hashlib.sha256(
            record["id_card"].encode()
        ).hexdigest()
        del record["id_card"]

    return record
```

## Common Issues

### Issue 1: ETL 任务内存溢出（OOM）

**症状**：ETL 任务在处理大数据量时被系统 OOM Killer 终止，日志中出现 `Killed` 或 `MemoryError`。

**诊断步骤**：
```
1. 检查是否有一次性加载全量数据到内存的逻辑
2. 检查 BATCH_SIZE 是否过大
3. 使用 memory_profiler 定位内存高峰
4. 检查是否有未释放的大对象引用
```

**解决方案**：
```python
# 使用异步生成器替代列表，限制内存占用
async def process_large_dataset(source_id: str):
    async for batch in extract_batched(source_id, batch_size=500):
        transformed, _ = transform_batch(batch)
        await load_data(transformed, session)
        del batch, transformed  # 显式释放引用
        await asyncio.sleep(0)  # 让出事件循环
```

### Issue 2: 数据源 Schema 变更导致转换失败

**症状**：ETL 任务突然报 `KeyError` 或 `ValidationError`，此前一直正常运行。

**可能原因**：
```
1. 数据源新增/删除/重命名了字段 → 更新 Extractor 和 Pydantic 模型
2. 数据源字段类型变化（如字符串变数字） → 更新 Transformer 类型转换逻辑
3. 数据源新增了枚举值 → 更新映射表
```

### Issue 3: 数据库连接池耗尽

**症状**：Load 阶段报 `TimeoutError` 或 `QueuePool limit reached`，数据库无法建立新连接。

**排查清单**：
```
1. 检查 POOL_SIZE 和 MAX_OVERFLOW 配置是否合理
2. 检查是否有 session 未正确关闭（缺少 async with）
3. 检查并发任务数是否超过连接池容量
4. 检查数据库端的 max_connections 配置
```

---

**最后更新**: 2026-02-09
**版本**: 1.0
**维护者**: data-pipeline 团队
