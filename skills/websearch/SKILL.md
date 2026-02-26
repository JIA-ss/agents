---
name: websearch
description: 替代 Claude 内置 websearch 的搜索工具，整合 YDC/Exa/Tavily/Jina 四个搜索 MCP，自动降级切换。当用户要求"搜索"、"查找"、"search"、"查一下"、"web search"、"联网"、"联网搜索"、"调研"、"查询最新"时使用。
---

# WebSearch

整合多后端的 Web 搜索：YDC > Exa > Tavily > Jina，自动降级。

---

## 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 1. 解析搜索意图

- 提取用户的搜索关键词（query）
- 识别搜索类型：通用搜索 / 代码搜索 / 深度研究 / 页面读取
- 如果用户指定了时间范围、域名限制等过滤条件，记录备用

### 2. 执行搜索（降级策略）

按优先级依次尝试，**成功即停止，不重复调用**：

#### 第一优先：YDC

调用 `mcp__you-search__you-search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `count` | int | 否 | 返回结果数，1-100 |
| `freshness` | string | 否 | `"day"`, `"week"`, `"month"`, `"year"` 或 `YYYY-MM-DDtoYYYY-MM-DD` |
| `country` | enum | 否 | 国家代码，如 `"US"`, `"CN"` |

**失败判定**：返回错误（HTTP 401/429/500）、结果为空、或超时。

#### 第二优先：Exa

调用 `mcp__exa__web_search_exa`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `numResults` | number | 否 | 返回结果数，默认 8 |

**失败判定**：返回错误（HTTP 400/401/429/500）、结果为空、或超时。

#### 第三优先：Tavily

调用 `mcp__tavily__tavily_search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `max_results` | number | 否 | 返回结果数，5-20，默认 5 |
| `search_depth` | enum | 否 | `"basic"`, `"advanced"`, `"fast"`, `"ultra-fast"` |

**失败判定**：返回错误（HTTP 400/401/429/500）、结果为空、或超时。

#### 第四优先：Jina

调用 `mcp__jina__jina_search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `count` | number | 否 | 返回结果数，默认 5 |

**失败判定**：返回错误（HTTP 401/429）、结果为空、或超时。

#### 全部失败

告知用户：

> 所有搜索服务均不可用（YDC / Exa / Tavily / Jina 依次尝试均失败）。请检查对应 API Key 是否有效，或稍后重试。

### 3. 格式化输出

无论使用哪个后端，统一按以下格式输出：

```
搜索：{query}  [来源: YDC/Exa/Tavily/Jina]

1. **标题**
   摘要内容
   链接: URL

2. **标题**
   摘要内容
   链接: URL

...
```

- 来源标注当前实际使用的后端名称
- 每条结果包含标题、摘要、URL 三部分
- 如果后端返回的结果缺少某个字段，跳过该字段即可

---

## 补充能力

以下能力不走降级策略，按场景直接调用：

### 深度读取页面

当用户需要获取某个 URL 的完整内容时：

1. 优先调用 `mcp__jina__jina_reader`（轻量、有缓存、支持分页）
2. 备选调用 `mcp__tavily__tavily_extract`（适合 JS 渲染页面，设置 `extract_depth: "advanced"`）
3. 备选调用 `mcp__you-search__you-contents`（需要 metadata/OpenGraph 时）

### 深度研究

当用户需要对某个主题做全面调研时：

- 调用 `mcp__tavily__tavily_research`（参数：`input` 为研究任务描述，`model` 可选 `"mini"` / `"pro"` / `"auto"`）

### 代码搜索

当用户搜索 API 用法、库文档、代码示例时：

- 调用 `mcp__exa__get_code_context_exa`（参数：`query` 为搜索内容，`tokensNum` 控制返回量 1000-50000）

### 站点爬取与映射

当用户需要探索某个网站的结构或批量抓取内容时：

- 站点映射：`mcp__tavily__tavily_map`
- 站点爬取：`mcp__tavily__tavily_crawl`

### 企业调研

当用户需要调研某公司信息时：

- 调用 `mcp__exa__company_research_exa`（参数：`companyName`）

---

## 约束

- 每次搜索只使用一个后端，成功即停止降级
- 输出格式统一，用户无需关心底层使用的是哪个服务
- 在来源标注中如实标记实际使用的后端
- 搜索结果中的 URL 必须是后端返回的原始链接，不得自行构造
- 补充能力（深度读取、研究、代码搜索等）不走降级策略，直接使用最适合的工具
