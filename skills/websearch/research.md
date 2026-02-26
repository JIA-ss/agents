# MCP Web Search Services Research

> Last updated: 2026-02-26

This document catalogs the four web-search MCP servers configured in the current environment, their tools, parameters, error characteristics, and recommended usage scenarios.

---

## 1. Tavily (`tavily-mcp`)

**Package:** `tavily-mcp` (npm)
**Auth:** `TAVILY_API_KEY` env var
**Pricing model:** Credit-based per API call

### Available Tools

| Tool Name | Description |
|---|---|
| `tavily_search` | Web search with advanced filtering (depth, domains, date, images) |
| `tavily_extract` | Extract clean content from one or more URLs |
| `tavily_crawl` | Graph-based website crawler starting from a root URL |
| `tavily_map` | Map a website's URL structure without extracting content |
| `tavily_research` | Comprehensive multi-step AI research on a topic (mini/pro/auto) |

### Tool Parameters

#### `tavily_search`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | string | **yes** | - | Search query |
| `search_depth` | enum | no | `"basic"` | `"basic"`, `"advanced"`, `"fast"`, `"ultra-fast"` |
| `topic` | enum | no | `"general"` | `"general"` |
| `max_results` | number | no | 5 | 5-20 |
| `include_domains` | string[] | no | [] | Restrict to these domains |
| `exclude_domains` | string[] | no | [] | Exclude these domains |
| `include_images` | bool | no | false | Include images in response |
| `include_image_descriptions` | bool | no | false | Include image descriptions |
| `include_raw_content` | bool | no | false | Include cleaned HTML content |
| `include_favicon` | bool | no | false | Include favicon URLs |
| `time_range` | enum | no | - | `"day"`, `"week"`, `"month"`, `"year"` |
| `start_date` | string | no | - | Format: `YYYY-MM-DD` |
| `end_date` | string | no | - | Format: `YYYY-MM-DD` |
| `country` | string | no | "" | Country code for boosting results |

#### `tavily_extract`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `urls` | string[] | **yes** | - | List of URLs to extract |
| `query` | string | no | - | Query to rerank content chunks |
| `extract_depth` | enum | no | `"basic"` | `"basic"` or `"advanced"` (for protected sites, tables) |
| `format` | enum | no | `"markdown"` | `"markdown"` or `"text"` |
| `include_images` | bool | no | false | Include images |
| `include_favicon` | bool | no | false | Include favicons |

#### `tavily_crawl`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `url` | string | **yes** | - | Root URL to begin crawl |
| `max_depth` | int | no | 1 | How far from base URL (1-5) |
| `max_breadth` | int | no | 20 | Links per page level (1-500) |
| `limit` | int | no | 50 | Total links to process |
| `instructions` | string | no | - | Natural language instructions for crawler |
| `extract_depth` | enum | no | `"basic"` | `"basic"` or `"advanced"` |
| `format` | enum | no | `"markdown"` | `"markdown"` or `"text"` |
| `allow_external` | bool | no | true | Include external links |
| `select_domains` | string[] | no | [] | Regex patterns for domain restriction |
| `select_paths` | string[] | no | [] | Regex patterns for path filtering |
| `include_favicon` | bool | no | false | Include favicons |

#### `tavily_map`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `url` | string | **yes** | - | Root URL to map |
| `max_depth` | int | no | 1 | Mapping depth |
| `max_breadth` | int | no | 20 | Links per level |
| `limit` | int | no | 50 | Total links to process |
| `instructions` | string | no | - | Natural language filter |
| `allow_external` | bool | no | true | Include external links |
| `select_domains` | string[] | no | [] | Domain regex patterns |
| `select_paths` | string[] | no | [] | Path regex patterns |

#### `tavily_research`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `input` | string | **yes** | - | Research task description |
| `model` | enum | no | `"auto"` | `"mini"` (narrow), `"pro"` (broad), `"auto"` |

### Error Characteristics
- HTTP 401: Invalid or expired API key
- HTTP 429: Rate limit exceeded
- HTTP 400: Invalid parameters (e.g., malformed date, bad domain list)
- Timeouts possible on `tavily_crawl` and `tavily_research` for large sites

### Best For
- **General web search** with date/domain filtering
- **Content extraction** from known URLs (especially protected/JS-heavy sites with `advanced` depth)
- **Site mapping and crawling** for documentation or link discovery
- **Deep research** via `tavily_research` for comprehensive multi-source reports

---

## 2. Exa (`exa-mcp-server`)

**Package:** `exa-mcp-server` (npm)
**Auth:** `EXA_API_KEY` env var
**Pricing model:** API credit-based

### Available Tools

| Tool Name | Enabled by Default | Description |
|---|---|---|
| `web_search_exa` | yes | General web search optimized for LLMs |
| `company_research_exa` | yes | Research a company (products, news, industry) |
| `get_code_context_exa` | yes | Find code examples, docs, API usage |
| `web_search_advanced_exa` | no | Full control over filters, domains, dates, content |
| `crawling_exa` | no | Get full content from a specific URL |
| `people_search_exa` | no | Find people and professional profiles |
| `deep_researcher_start` | no | Start async AI deep research agent |
| `deep_researcher_check` | no | Check status of deep research task |

### Tool Parameters (Default-Enabled Tools)

#### `web_search_exa`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | string | **yes** | - | Search query |
| `numResults` | number | no | 8 | Number of results |
| `type` | enum | no | `"auto"` | `"auto"`, `"fast"` |
| `contextMaxCharacters` | number | no | 10000 | Max chars for context |
| `livecrawl` | enum | no | `"fallback"` | `"fallback"` or `"preferred"` |

#### `company_research_exa`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `companyName` | string | **yes** | - | Company name |
| `numResults` | number | no | 3 | Number of results |

#### `get_code_context_exa`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | string | **yes** | - | Code/API search query |
| `tokensNum` | number | no | 5000 | Token budget (1000-50000) |

### Error Characteristics
- HTTP 400: Invalid parameters (e.g., multi-item `includeText`/`excludeText` arrays)
- HTTP 401: Invalid API key
- HTTP 429: Rate limit exceeded
- HTTP 500: Server errors (e.g., `moderation` param on tweet category)
- `includeText` and `excludeText` only support single-item arrays in advanced search
- Tweet category does NOT support domain/text filters

### Best For
- **Semantic / neural web search** -- Exa's search is optimized for meaning, not just keywords
- **Code context retrieval** -- excellent for finding API docs, library usage examples, SDK references
- **Company research** -- business intelligence from trusted sources
- **People search** (advanced) -- professional profiles and bios

---

## 3. You.com (`@youdotcom-oss/mcp`)

**Package:** `@youdotcom-oss/mcp` (npm)
**Auth:** `YDC_API_KEY` env var
**Pricing model:** API key-based

### Available Tools

| Tool Name | Description |
|---|---|
| `you-search` | Web and news search with advanced operators and filtering |
| `you-contents` | Extract page content from URLs in markdown, HTML, or metadata formats |

Note: An additional `you-express` tool (AI-powered answers with web context) is available in the remote HTTP server but may not be present in the local STDIO package.

### Tool Parameters

#### `you-search`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | string | **yes** | - | Search query (supports operators: `site:`, `filetype:`, `+term`, `-term`, `AND/OR/NOT`, `lang:`) |
| `count` | int | no | - | Max results per section (1-100) |
| `country` | enum | no | - | Country code (`US`, `GB`, `DE`, etc.) |
| `freshness` | string | no | - | `"day"`, `"week"`, `"month"`, `"year"`, or `YYYY-MM-DDtoYYYY-MM-DD` |
| `safesearch` | enum | no | - | `"off"`, `"moderate"`, `"strict"` |
| `offset` | int | no | 0 | Pagination offset (0-9) |
| `livecrawl` | enum | no | - | `"web"`, `"news"`, `"all"` -- live-crawl sections for full content |
| `livecrawl_formats` | enum | no | - | `"html"`, `"markdown"` -- format for crawled content |

#### `you-contents`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `urls` | string[] | **yes** | - | URLs to extract content from |
| `formats` | string[] | no | - | Array of `"markdown"`, `"html"`, `"metadata"` |
| `format` | enum | no | - | (Deprecated) `"markdown"` or `"html"` |
| `crawl_timeout` | number | no | - | Timeout 1-60 seconds |

### Error Characteristics
- HTTP 401: Invalid or missing API key
- HTTP 429: Rate limit exceeded
- Timeout errors on `you-contents` for slow pages
- Empty results if query too narrow or country filter too restrictive

### Best For
- **General web search** with rich operator syntax (`site:`, `filetype:`, boolean operators)
- **News search** with freshness filtering
- **Content extraction** in multiple formats (markdown, HTML, metadata/OpenGraph)
- **Live crawling** of fresh content during search

---

## 4. Jina (`jina-mcp-tools`)

**Package:** `jina-mcp-tools` (npm)
**Auth:** `JINA_API_KEY` env var (optional for reader, required for search)
**Pricing model:** Free tier available; API key for enhanced features

### Available Tools

| Tool Name | Description |
|---|---|
| `jina_reader` | Extract and read web page content from a URL |
| `jina_search` | Search the web via s.jina.ai (standard endpoint) |

Note: With `--search-endpoint vip`, `jina_search` becomes `jina_search_vip` using svip.jina.ai.

### Tool Parameters

#### `jina_reader`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `url` | string | **yes** | - | URL to read |
| `page` | number | no | 1 | Page number for paginated content |
| `customTimeout` | number | no | - | Override timeout in seconds |

Features:
- GitHub file URLs automatically converted to raw content URLs
- LRU cache (50 URLs) for instant subsequent requests
- Automatic pagination for large documents

#### `jina_search`
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | string | **yes** | - | Search query |
| `count` | number | no | 5 | Number of results |
| `siteFilter` | string | no | - | Limit to specific domain (e.g., `"github.com"`) |

### Error Characteristics
- HTTP 401: Invalid API key (message: "Invalid API key, please get a new one from https://jina.ai")
- API key expiration: Keys can expire; error includes link to get new key
- Timeouts on large/slow pages
- Search requires valid API key; reader works without key but with limitations

### Best For
- **Simple page reading** -- lightweight, cached URL content extraction
- **Quick web search** -- basic search with site filtering
- **GitHub content** -- automatic raw URL conversion for GitHub files
- **Paginated content** -- built-in pagination support for large docs
- **Budget-conscious usage** -- free tier available, minimal parameters

---

## Comparison Matrix

| Capability | Tavily | Exa | You.com | Jina |
|---|---|---|---|---|
| **Web Search** | tavily_search | web_search_exa | you-search | jina_search |
| **Content Extraction** | tavily_extract | crawling_exa* | you-contents | jina_reader |
| **Site Crawling** | tavily_crawl | - | - | - |
| **Site Mapping** | tavily_map | - | - | - |
| **Deep Research** | tavily_research | deep_researcher_start* | - | - |
| **Code Context** | - | get_code_context_exa | - | - |
| **Company Research** | - | company_research_exa | - | - |
| **People Search** | - | people_search_exa* | - | - |
| **Metadata Extraction** | - | - | you-contents (metadata) | - |
| **Search Operators** | domain/date filter | neural/semantic | site:/filetype:/boolean | siteFilter |
| **Date Filtering** | time_range, start/end_date | startPublishedDate* | freshness | - |
| **Live Crawl** | advanced extract_depth | livecrawl | livecrawl | - |
| **Free Tier** | limited | no | no | yes (reader only) |
| **Latency** | ~1-3s search | ~1.5-2.8s search | ~1-2s search | ~1-2s search |

\* = off by default or advanced tool

## Recommended Usage Strategy

### Primary Search: `tavily_search` or `you-search`
Both offer robust general search. Tavily excels at date/domain filtering. You.com supports richer query operators.

### Content Extraction: `tavily_extract` (complex) or `jina_reader` (simple)
- Use `tavily_extract` for JS-heavy/protected sites (with `extract_depth: "advanced"`)
- Use `jina_reader` for quick, simple page reads (cached, paginated)
- Use `you-contents` when you need metadata/OpenGraph alongside content

### Code & API Documentation: `get_code_context_exa`
Exa's code context tool is purpose-built for finding library docs, API examples, and SDK references.

### Deep Research: `tavily_research`
For comprehensive multi-source research reports, Tavily's research tool automates the multi-step process.

### Site Exploration: `tavily_crawl` + `tavily_map`
Unique to Tavily -- no other MCP provides crawling/mapping capabilities.

### Company Intel: `company_research_exa`
Exa's dedicated company research returns curated business information.

### Fallback Strategy
If one service fails (rate limit, timeout, API key issue), fall back to another:
1. Search: tavily_search -> you-search -> web_search_exa -> jina_search
2. Extract: tavily_extract -> you-contents -> jina_reader -> crawling_exa
