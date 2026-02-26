---
name: websearch
description: 替代 Claude 内置 websearch 的搜索工具，整合 YDC/Exa/Tavily/Jina 四个搜索 MCP，自动降级切换。当用户要求"搜索"、"查找"、"search"、"查一下"、"web search"、"联网"、"联网搜索"、"调研"、"查询最新"时使用。
---

# WebSearch

整合多后端的 Web 搜索：YDC > Exa > Tavily > Jina，自动降级。

---

## 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### Phase 0：预检（每次搜索前必须执行）

在执行任何搜索前，先完成以下检查和修复：

#### 0.1 读取 MCP 配置

运行以下命令，获取当前已配置的 MCP 列表：

```bash
cat ~/.claude.json
```

从输出的 `mcpServers` 字段中，检查以下四个 MCP 是否存在：

| MCP 名称 | npm 包 | 环境变量 Key |
|----------|--------|-------------|
| `you-search` | `@youdotcom-oss/mcp` | `YDC_API_KEY` |
| `exa` | `exa-mcp-server` | `EXA_API_KEY` |
| `tavily` | `tavily-mcp` | `TAVILY_API_KEY` |
| `jina` | `jina-mcp-tools` | `JINA_API_KEY` |

#### 0.2 检查每个 MCP 的状态

对每个未在 `mcpServers` 中出现的 MCP，执行以下流程：

**Step A：检查对应 Key 是否在 shell 环境变量中存在**

```bash
# 以 YDC 为例
echo "YDC_API_KEY=${YDC_API_KEY:-<not set>}"
echo "EXA_API_KEY=${EXA_API_KEY:-<not set>}"
echo "TAVILY_API_KEY=${TAVILY_API_KEY:-<not set>}"
echo "JINA_API_KEY=${JINA_API_KEY:-<not set>}"
```

**Step B：根据检查结果执行对应操作**

| 状态 | 操作 |
|------|------|
| MCP 已安装 | ✅ 跳过，无需处理 |
| MCP 未安装 + Key 存在于环境变量 | 🔧 自动安装（见下方安装命令） |
| MCP 未安装 + Key 不存在 | ⚠️ 提示用户配置（见下方提示模板），**跳过该 MCP，继续检查下一个** |

#### 0.3 自动安装命令（Key 存在时使用）

```bash
# YDC
claude mcp add --transport stdio --scope user you-search \
  --env YDC_API_KEY=$YDC_API_KEY \
  -- npx -y @youdotcom-oss/mcp

# Exa
claude mcp add --transport stdio --scope user exa \
  --env EXA_API_KEY=$EXA_API_KEY \
  -- npx -y exa-mcp-server

# Tavily
claude mcp add --transport stdio --scope user tavily \
  --env TAVILY_API_KEY=$TAVILY_API_KEY \
  -- npx -y tavily-mcp

# Jina
claude mcp add --transport stdio --scope user jina \
  --env JINA_API_KEY=$JINA_API_KEY \
  -- npx -y jina-mcp-tools
```

安装完成后告知用户：`✅ 已自动安装 [MCP名称]，继续执行搜索。`

#### 0.4 Key 缺失时的提示模板

若某个 MCP 的 Key 未配置，输出以下提示后**跳过该 MCP**（不退出整个流程，继续用其他可用的 MCP 搜索）：

```
⚠️ [MCP名称] 未配置，已跳过。

如需启用，请按以下步骤操作：
1. 前往 [申请地址] 获取 API Key
2. 在终端中设置环境变量：
   export YDC_API_KEY=your_key_here   # 临时生效
   # 或写入 ~/.bashrc / ~/.zshrc 永久生效
3. 重新运行搜索，系统将自动安装并启用该 MCP
```

各 MCP 申请地址：
- **YDC**（You.com）：https://api.you.com
- **Exa**：https://dashboard.exa.ai
- **Tavily**：https://app.tavily.com
- **Jina**：https://jina.ai/api-dashboard

#### 0.5 预检结果判定

| 情况 | 处理 |
|------|------|
| 至少一个 MCP 可用 | ✅ 继续执行 Phase 1 搜索 |
| 所有 MCP 均不可用（未安装且 Key 全部缺失） | ⚠️ 提示用户配置 Key，同时降级到 WebFetch 执行搜索 |

> **重要约束**：**严禁使用 Claude 内置的 `WebSearch` 工具**。当 MCP 不可用时，可使用 WebFetch、jina_reader、tavily_extract 等其他工具作为替代。

---

### Phase 1：解析搜索意图

- 提取用户的搜索关键词（query）
- 识别搜索类型：通用搜索 / 代码搜索 / 深度研究 / 页面读取
- 如果用户指定了时间范围、域名限制等过滤条件，记录备用

---

### Phase 2：执行搜索（降级策略）

**仅对 Phase 0 中确认可用的 MCP 执行降级**，按优先级依次尝试，**成功即停止，不重复调用**：

#### 第一优先：YDC

调用 `mcp__you-search__you-search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `count` | int | 否 | 返回结果数，1-100 |
| `freshness` | string | 否 | `"day"`, `"week"`, `"month"`, `"year"` 或 `YYYY-MM-DDtoYYYY-MM-DD` |
| `country` | enum | 否 | 国家代码，如 `"US"`, `"CN"` |

**失败判定**：返回错误（HTTP 401/429/500）、结果为空、或超时 → 切换下一个。

#### 第二优先：Exa

调用 `mcp__exa__web_search_exa`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `numResults` | number | 否 | 返回结果数，默认 8 |

**失败判定**：返回错误（HTTP 400/401/429/500）、结果为空、或超时 → 切换下一个。

#### 第三优先：Tavily

调用 `mcp__tavily__tavily_search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `max_results` | number | 否 | 返回结果数，5-20，默认 5 |
| `search_depth` | enum | 否 | `"basic"`, `"advanced"`, `"fast"`, `"ultra-fast"` |

**失败判定**：返回错误（HTTP 400/401/429/500）、结果为空、或超时 → 切换下一个。

#### 第四优先：Jina

调用 `mcp__jina__jina_search`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `count` | number | 否 | 返回结果数，默认 5 |

**失败判定**：返回错误（HTTP 401/429）、结果为空、或超时 → 进入全部失败流程。

#### 全部可用 MCP 均失败

输出以下提示并停止：

所有 MCP 搜索后端均失败，自动降级到 WebFetch：

1. 告知用户：

   ```
   ⚠️ 所有搜索 MCP 均不可用（已依次尝试：YDC / Exa / Tavily / Jina），已降级使用 WebFetch 搜索。
   ```

2. 使用 WebFetch 工具抓取搜索引擎结果页（如 DuckDuckGo、Bing）作为替代：

   ```
   # 示例：抓取 DuckDuckGo HTML 搜索结果
   WebFetch: https://html.duckduckgo.com/html/?q={urlencode(query)}
   ```

3. 解析返回的 HTML 内容，提取标题、摘要、URL，按统一格式输出，来源标注为 `WebFetch`。

> **严禁使用 Claude 内置的 `WebSearch` 工具**，其他工具（WebFetch、jina_reader、tavily_extract 等）均可使用。

---

### Phase 3：格式化输出

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

- **预检必须在每次搜索前完成**，不可跳过
- MCP 未安装且 Key 存在时，自动安装后继续搜索，无需用户介入
- MCP 未安装且 Key 缺失时，跳过该 MCP，提示用户，继续尝试其他可用 MCP
- 所有 MCP 均不可用时，提示用户配置 Key，并自动降级使用 WebFetch 搜索
- **严禁使用 Claude 内置的 `WebSearch` 工具**，其他工具（WebFetch、jina_reader、tavily_extract 等）均可使用
- 每次搜索只使用一个后端，成功即停止降级
- 输出格式统一，用户无需关心底层使用的是哪个服务
- 搜索结果中的 URL 必须是后端返回的原始链接，不得自行构造
