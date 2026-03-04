---
name: renderdoc-gpu-debug
description: GPU frame debugging with RenderDoc via MCP or rdc-cli. Captures, inspects, and debugs GPU frames for Vulkan, D3D11, D3D12, and OpenGL applications. Use when user mentions RenderDoc, GPU debugging, frame capture analysis, draw call inspection, shader debugging, pixel history, render target export, pipeline state, or describes rendering bugs such as wrong colors, missing objects, broken shadows, or performance issues. Also responds to "GPU调试", "帧捕获", "图形调试", "渲染调试", "管线状态", "着色器调试", "像素调试".
---

# RenderDoc GPU Debug

GPU frame debugging skill that integrates with RenderDoc via MCP servers or rdc-cli to diagnose rendering issues, inspect pipeline state, trace shaders, and analyze performance.

---

## Execution Flow

**When this skill is triggered, you must follow this flow:**

### Immediate Action

1. Identify the user's rendering problem or debugging request
2. Begin Phase 1: SETUP to verify environment
3. Follow the phase workflow sequentially

### Progress Checklist

```
- [ ] Phase 1: SETUP → Verify RenderDoc environment and MCP/CLI availability
- [ ] Phase 2: CAPTURE → Open .rdc file or capture a frame
- [ ] Phase 3: NAVIGATE → Browse events and find relevant draw calls
- [ ] Phase 4: INSPECT → Check pipeline state, shaders, bindings, textures
- [ ] Phase 5: DIAGNOSE → Analyze data, identify root cause
- [ ] Phase 6: REPORT → Present findings with fix suggestions
```

### Phase Completion Verification

| Phase | Completion Condition | Next Step |
|-------|---------------------|-----------|
| SETUP | RenderDoc MCP or rdc-cli confirmed available | CAPTURE |
| CAPTURE | .rdc file opened successfully | NAVIGATE |
| NAVIGATE | Relevant draw call(s) identified | INSPECT |
| INSPECT | Pipeline state and visual data collected | DIAGNOSE |
| DIAGNOSE | Root cause identified | REPORT |
| REPORT | User receives diagnosis + fix suggestion | Done |

---

## Phase Details

### Phase 1: SETUP (Environment Check)

**You must:**

1. **Check for RenderDoc MCP server** — Look for `renderdoc` in available MCP tools
2. **Check for rdc-cli** — Run `rdc doctor` or `rdc status` to verify CLI availability
3. **If neither available** — Read [references/mcp-setup-guide.md](references/mcp-setup-guide.md) and guide user through installation
4. **Determine backend** — Use MCP tools if available, fall back to rdc-cli bash commands

**Backend priority:**

| Priority | Backend | Detection | How to use |
|----------|---------|-----------|------------|
| 1 | renderdoc MCP (19 tools) | MCP tools `open_capture`, `list_actions` available | Call MCP tools directly |
| 2 | agentic-renderdoc MCP (3 tools) | MCP tool `Eval` available | Execute Python via Eval tool |
| 3 | rdc-cli | `rdc doctor` succeeds | Run bash commands |
| 4 | None | All above fail | Guide user to install |

**Completion marker**: RenderDoc backend confirmed and ready

---

### Phase 2: CAPTURE (Open or Capture Frame)

**You must:**

1. **If user provides .rdc file path** — Open it:
   - MCP: `open_capture("path/to/frame.rdc")`
   - CLI: `rdc open path/to/frame.rdc`
2. **If no .rdc file** — Guide capture:
   - Ask user for application executable path
   - MCP: Use capture tools
   - CLI: `rdc capture ./executable` or `rdc attach PID` + `rdc trigger`
3. **Verify capture opened** — Check capture info (API type, action count, resolution)

**Completion marker**: Capture opened, frame info displayed

---

### Phase 3: NAVIGATE (Find Relevant Draw Calls)

**You must:**

1. **Get frame overview**:
   - MCP: `list_actions()`, `get_capture_info()`
   - CLI: `rdc draws`, `rdc info`, `rdc passes`
2. **Search for relevant draws** based on user's problem:
   - By name: `search_actions(name_pattern="shadow")` or `rdc search "shadow"`
   - By pass: Identify the render pass containing the issue
3. **Navigate to target event**:
   - MCP: `set_event(eid)` — **required before any pipeline query**
   - CLI: (implicit in subsequent commands with EID argument)

**Completion marker**: Target draw call(s) identified by EID

---

### Phase 4: INSPECT (Collect Debugging Data)

**You must** collect data relevant to the problem. Choose from these inspection patterns:

#### 4a. Pipeline State Inspection

```
MCP: get_pipeline_state()         → rasterizer, blend, depth, stencil, viewports
MCP: get_shader_bindings("pixel") → textures, buffers, samplers bound to pixel shader
MCP: get_vertex_inputs()          → vertex attributes, index buffer

CLI: rdc pipeline EID
CLI: rdc bindings EID pixel
```

#### 4b. Visual Inspection (Multimodal)

Export render targets/textures as PNG, then **view them using the Read tool** (Claude is multimodal):

```
MCP: save_texture(resource_id, "output.png", format="png")
CLI: rdc rt EID -o output.png

Then: Read the PNG file to visually inspect the rendered output
```

#### 4c. Shader Inspection

```
MCP: disassemble_shader()         → shader source/disassembly
MCP: get_shader_reflection()      → input/output signatures
MCP: get_cbuffer_contents("pixel", 0) → constant buffer values

CLI: rdc shader EID pixel
CLI: rdc debug pixel EID X Y      → trace pixel shader execution
```

#### 4d. Pixel Debugging

```
MCP: pick_pixel(resource_id, x, y)    → RGBA value
MCP: pixel_history(resource_id, x, y) → all events that wrote to this pixel

CLI: rdc pick-pixel X Y
CLI: rdc pixel RESOURCE_ID X Y
CLI: rdc debug pixel EID X Y
```

**Completion marker**: Relevant pipeline state, visuals, or shader data collected

---

### Phase 5: DIAGNOSE (Root Cause Analysis)

**You must:**

1. **Match symptoms to a debugging recipe** — Read [references/debugging-recipes.md](references/debugging-recipes.md) for the 6 standard recipes:
   - Object invisible → Recipe 1
   - Colors wrong → Recipe 2
   - Shadows broken → Recipe 3
   - Performance bad → Recipe 4
   - Regression → Recipe 5
   - Pixel wrong → Recipe 6
2. **Follow the recipe steps** systematically
3. **Correlate data** from Phase 4 with expected values
4. **Identify the root cause** — Specific misconfiguration, shader bug, or data error

**Completion marker**: Root cause identified with evidence

---

### Phase 6: REPORT (Present Findings)

**You must:**

1. **Summarize the diagnosis** in this structure:

```
## Diagnosis

**Problem**: [What the user reported]
**Root Cause**: [What is actually wrong and why]
**Evidence**: [Specific data points that confirm the diagnosis]
**Fix**: [Concrete steps to fix the issue]
```

2. **Include visual evidence** if render targets were exported
3. **Provide code-level fix** if the issue is in shader code or application setup
4. **Offer follow-up** — "Would you like me to check anything else in this capture?"

**Completion marker**: User has received the diagnosis and fix suggestion

---

## Supported APIs

| API | Capture | Replay | Notes |
|-----|---------|--------|-------|
| Vulkan | Yes | Yes | Register implicit layer for capture |
| D3D11 | Yes | Yes | Windows only |
| D3D12 | Yes | Yes | Windows only |
| OpenGL | Yes | Yes | Core profile recommended |
| OpenGL ES | Yes | Yes | Via Android or emulation |
| Metal | No | No | Not supported by RenderDoc |

---

## Error Handling

| Error | Response |
|-------|----------|
| RenderDoc not installed | Provide download link: https://renderdoc.org/ and setup guide |
| MCP server not configured | Read [references/mcp-setup-guide.md](references/mcp-setup-guide.md), guide configuration |
| .rdc file not found | Ask user for correct path, offer capture guidance |
| Capture won't open | Check API compatibility, file corruption, version mismatch |
| Python version mismatch | renderdoc.pyd requires matching Python version |

---

## Additional Resources

| Resource | Path | Content |
|----------|------|---------|
| MCP Setup Guide | [references/mcp-setup-guide.md](references/mcp-setup-guide.md) | 3 MCP server installation options |
| Debugging Recipes | [references/debugging-recipes.md](references/debugging-recipes.md) | 6 standard debugging workflows |
| Command Reference | [references/rdc-commands-ref.md](references/rdc-commands-ref.md) | rdc-cli core commands |
