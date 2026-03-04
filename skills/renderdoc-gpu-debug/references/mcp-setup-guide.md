# RenderDoc MCP Setup Guide

Three RenderDoc MCP server options are available. Choose based on your needs.

## Option A: renderdoc-mcp (Recommended for beginners)

**19 tools, 3 prompts, headless, pure Python.**

### Install

```bash
git clone https://github.com/Linkingooo/renderdoc-mcp.git
cd renderdoc-mcp
pip install -e .
```

### Configure Claude Code

Add to `.claude/settings.json` or `~/.claude.json`:

```json
{
  "mcpServers": {
    "renderdoc": {
      "command": "python",
      "args": ["-m", "renderdoc_mcp"],
      "env": {
        "RENDERDOC_MODULE_PATH": "C:\\Program Files\\RenderDoc"
      }
    }
  }
}
```

### Tool Categories

| Category | Tools | Purpose |
|----------|-------|---------|
| Session | open_capture, close_capture, get_capture_info | Lifecycle |
| Navigation | list_actions, get_action, set_event, search_actions | Event browsing |
| Pipeline | get_pipeline_state, get_shader_bindings, get_vertex_inputs | State inspection |
| Resources | list_textures, list_buffers, list_resources, get_resource_usage | Resource analysis |
| Data | save_texture, get_buffer_data, pick_pixel, get_texture_stats | Export/read |
| Shaders | disassemble_shader, get_shader_reflection, get_cbuffer_contents | Shader analysis |
| Advanced | pixel_history, get_post_vs_data | Deep debugging |

---

## Option B: agentic-renderdoc (Recommended for advanced users)

**3 tools, RenderDoc extension, live session access.**

### Install

1. Copy `src/extension/` to RenderDoc's extensions directory as `agentic_renderdoc`:
   - Windows: `%APPDATA%\qrenderdoc\extensions\`
   - Linux: `~/.local/share/qrenderdoc/extensions/`
2. In RenderDoc: Tools > Manage Extensions > Enable `agentic-renderdoc` > Restart
3. Install MCP server: `python scripts/install.py`

### Configure

```json
{
  "mcpServers": {
    "renderdoc": {
      "command": "agentic-renderdoc"
    }
  }
}
```

### Tools

| Tool | Purpose |
|------|---------|
| **Eval** | Execute Python in RenderDoc replay session |
| **Search API** | Search RenderDoc Python API reference |
| **Instance** | List/connect/disconnect RenderDoc instances |

---

## Option C: renderdoc-skill + MCP (CLI-based)

**14 MCP tools wrapping 66 rdc-cli commands.**

### Install

```bash
pip install rdc-cli
# Clone skill
git clone https://github.com/rudybear/renderdoc-skill .claude/skills/renderdoc-gpu-debug
# Register MCP
claude mcp add rdc-tools -- python /path/to/mcp_server/server.py
```

### Set RenderDoc module path

```bash
export RENDERDOC_PYTHON_PATH=/path/to/renderdoc/module  # Linux/macOS
set RENDERDOC_PYTHON_PATH=C:\Program Files\RenderDoc     # Windows
```

### Verify

```bash
rdc doctor
```

---

## Prerequisites (All Options)

| Requirement | Notes |
|-------------|-------|
| [RenderDoc](https://renderdoc.org/) | v1.0+, need `renderdoc.pyd` (Win) or `renderdoc.so` (Linux) |
| Python 3.10+ | Must match renderdoc.pyd build version |
| Supported APIs | Vulkan, D3D11, D3D12, OpenGL, OpenGL ES |

## Not Supported

- Metal (Apple) — RenderDoc does not support Metal
- Console-specific APIs (unless via Vulkan/D3D12)
