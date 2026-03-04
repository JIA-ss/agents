# RenderDoc Debugging Recipes

Six standard debugging workflows for common GPU rendering issues.

---

## Recipe 1: Object Is Invisible

**Symptoms**: Expected geometry not appearing in the final render.

### Steps

1. **Find the draw call** — Search for the object's draw call by mesh name or shader
2. **Check vertex data** — Export post-VS data, verify positions are in view
3. **Check culling** — Inspect rasterizer state: cull mode, front face winding
4. **Check depth** — Inspect depth state: depth test enabled? depth write? depth func?
5. **Check blend** — Inspect blend state: is alpha zero? is blend mode discarding?
6. **Check scissor/viewport** — Are they clipping the object?
7. **Export render target** — View output at the draw call's EID

### Key Commands (rdc-cli)

```bash
rdc draws                          # List all draw calls
rdc search --name "ObjectName"     # Find specific draw
rdc pipeline EID                   # Full pipeline state
rdc rt EID -o output.png           # Export render target
```

### Key Tools (MCP)

```
search_actions(name_pattern="ObjectName")
set_event(eid)
get_pipeline_state()
save_texture(resource_id, "output.png")
```

---

## Recipe 2: Colors Are Wrong

**Symptoms**: Object renders but with incorrect colors/shading.

### Steps

1. **Navigate to the draw call** for the affected object
2. **Check shader bindings** — Are the correct textures bound?
3. **Read constant buffer** — Are material parameters (colors, roughness) correct?
4. **Check blend state** — Is blending modifying the output?
5. **Trace the pixel shader** — Step through shader execution at a wrong pixel
6. **Export textures** — View bound textures to verify content

### Key Commands

```bash
rdc bindings EID pixel             # Shader resource bindings
rdc shader EID pixel               # Pixel shader source
rdc debug pixel EID X Y            # Trace pixel shader execution
rdc texture RESOURCE_ID -o tex.png # Export bound texture
```

---

## Recipe 3: Shadows Are Broken

**Symptoms**: Shadow acne, peter-panning, blocky shadows, missing shadows.

### Steps

1. **Find the shadow pass** — Search for shadow map render pass
2. **Export shadow map** — View depth texture used as shadow map
3. **Check depth bias** — Inspect rasterizer depth bias settings
4. **Check light matrices** — Read constant buffer for view/projection matrices
5. **Check PCF/filtering** — Review sampler state on shadow map
6. **Check shadow map resolution** — Is it large enough for the scene?

### Key Commands

```bash
rdc passes                         # List render passes
rdc search --name "shadow"         # Find shadow-related draws
rdc rt SHADOW_PASS_EID -o shadow.png
rdc pipeline SHADOW_PASS_EID       # Check depth bias
```

---

## Recipe 4: Performance Is Bad

**Symptoms**: Low FPS, stuttering, GPU-bound performance.

### Steps

1. **Count draw calls** — Are there too many? (>2000 is suspicious)
2. **Check resource sizes** — Are textures oversized?
3. **Find redundant draws** — Same state, same mesh, drawn multiple times
4. **Check overdraw** — Multiple draws to the same pixel region
5. **Review render passes** — Unnecessary passes or redundant clears
6. **Check GPU counters** — If available, review hardware counters

### Key Commands

```bash
rdc count                          # Total draw/event counts
rdc stats                          # Frame statistics
rdc draws --verbose                # Detailed draw list
rdc tex-stats                      # Texture memory usage
```

---

## Recipe 5: What Changed Between Frames

**Symptoms**: Regression between two captures, need to find the difference.

### Steps

1. **Open both captures**
2. **Diff the frames** — Compare draw call lists
3. **Compare specific draws** — Same EID, different state
4. **Export render targets** — Visual comparison at key stages
5. **Diff pipeline state** — Find changed settings

### Key Commands

```bash
rdc diff capture_a.rdc capture_b.rdc
rdc rt EID -o frame_a.png          # From capture A
rdc rt EID -o frame_b.png          # From capture B
```

---

## Recipe 6: Debug This Pixel

**Symptoms**: A specific pixel has the wrong color, need to trace why.

### Steps

1. **Pick the pixel** — Get its coordinates and current RGBA value
2. **Pixel history** — Find ALL draw calls that wrote to this pixel
3. **For each write** — Check which draw, what shader, what inputs
4. **Trace the shader** — Step through the pixel shader at that coordinate
5. **Inspect variables** — Check intermediate values at each instruction

### Key Commands

```bash
rdc pick-pixel X Y                 # Get pixel value
rdc pixel RESOURCE_ID X Y          # Full pixel history
rdc debug pixel EID X Y            # Shader trace at pixel
```

### Key Tools (MCP)

```
pick_pixel(resource_id, x, y)
pixel_history(resource_id, x, y)
set_event(eid)
get_cbuffer_contents("pixel", 0)
```
