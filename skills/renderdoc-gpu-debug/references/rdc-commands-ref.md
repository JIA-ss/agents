# rdc-cli Core Commands Reference

Quick reference for the most commonly used `rdc-cli` commands. Full reference: 66 commands total.

## Session Management

| Command | Description | Example |
|---------|-------------|---------|
| `rdc open <file>` | Open a .rdc capture | `rdc open frame.rdc` |
| `rdc close` | Close current capture | `rdc close` |
| `rdc status` | Show session status | `rdc status` |
| `rdc doctor` | Verify RenderDoc setup | `rdc doctor` |

## Frame Overview

| Command | Description | Example |
|---------|-------------|---------|
| `rdc info` | Capture metadata (API, resolution) | `rdc info` |
| `rdc stats` | Frame statistics | `rdc stats` |
| `rdc count` | Draw call and event counts | `rdc count` |
| `rdc passes` | List render passes | `rdc passes` |
| `rdc gpus` | List available GPUs | `rdc gpus` |

## Event Navigation

| Command | Description | Example |
|---------|-------------|---------|
| `rdc draws` | List draw calls | `rdc draws` |
| `rdc draw <EID>` | Detail for one draw call | `rdc draw 142` |
| `rdc events` | List all API events | `rdc events` |
| `rdc event <EID>` | Detail for one event | `rdc event 142` |

## Pipeline State

| Command | Description | Example |
|---------|-------------|---------|
| `rdc pipeline <EID>` | Full pipeline state | `rdc pipeline 142` |
| `rdc bindings <EID> <stage>` | Shader bindings | `rdc bindings 142 pixel` |

## Shader Inspection

| Command | Description | Example |
|---------|-------------|---------|
| `rdc shader <EID> <stage>` | Shader source/disasm | `rdc shader 142 pixel` |
| `rdc shaders` | List all shaders | `rdc shaders` |
| `rdc search <pattern>` | Search shader source | `rdc search "shadowMap"` |
| `rdc shader-map` | Shader to draw call mapping | `rdc shader-map` |

## Visual Export

| Command | Description | Example |
|---------|-------------|---------|
| `rdc rt <EID> -o <file>` | Export render target | `rdc rt 142 -o rt.png` |
| `rdc texture <ID> -o <file>` | Export a texture | `rdc texture 5 -o tex.png` |
| `rdc thumbnail -o <file>` | Capture thumbnail | `rdc thumbnail -o thumb.png` |
| `rdc mesh <EID> -o <file>` | Export mesh data | `rdc mesh 142 -o mesh.obj` |
| `rdc buffer <ID> -o <file>` | Export buffer data | `rdc buffer 3 -o buf.bin` |

## Pixel Debugging

| Command | Description | Example |
|---------|-------------|---------|
| `rdc pick-pixel <X> <Y>` | Read pixel value | `rdc pick-pixel 256 300` |
| `rdc pixel <ID> <X> <Y>` | Pixel modification history | `rdc pixel 0 256 300` |
| `rdc debug pixel <EID> <X> <Y>` | Trace pixel shader | `rdc debug pixel 142 256 300` |
| `rdc debug vertex <EID> <VTX>` | Trace vertex shader | `rdc debug vertex 142 0` |

## Resource Inspection

| Command | Description | Example |
|---------|-------------|---------|
| `rdc resources` | List all resources | `rdc resources` |
| `rdc resource <ID>` | Resource details | `rdc resource 5` |
| `rdc usage <ID>` | Resource usage across events | `rdc usage 5` |
| `rdc tex-stats` | Texture memory statistics | `rdc tex-stats` |

## Shader Edit & Replay

| Command | Description | Example |
|---------|-------------|---------|
| `rdc shader-build <file>` | Compile modified shader | `rdc shader-build mod.hlsl` |
| `rdc shader-replace <EID> <stage> <file>` | Replace shader | `rdc shader-replace 142 pixel mod.hlsl` |
| `rdc shader-restore <EID> <stage>` | Restore original | `rdc shader-restore 142 pixel` |

## Frame Capture

| Command | Description | Example |
|---------|-------------|---------|
| `rdc capture <exe>` | Capture from executable | `rdc capture ./myapp` |
| `rdc attach <PID>` | Attach to running process | `rdc attach 12345` |
| `rdc trigger` | Trigger capture on attached | `rdc trigger` |
| `rdc list` | List available captures | `rdc list` |

## Frame Comparison

| Command | Description | Example |
|---------|-------------|---------|
| `rdc diff <a.rdc> <b.rdc>` | Compare two captures | `rdc diff a.rdc b.rdc` |

## Assertions (CI/CD)

| Command | Description | Example |
|---------|-------------|---------|
| `rdc assert-pixel <EID> <X> <Y> <R> <G> <B> <A>` | Assert pixel color | |
| `rdc assert-image <EID> <ref.png>` | Assert against reference | |
| `rdc assert-state <EID> <key> <value>` | Assert pipeline state | |
| `rdc assert-clean` | Assert no debug messages | |
| `rdc assert-count <max>` | Assert max draw calls | |

## Virtual Filesystem

| Command | Description | Example |
|---------|-------------|---------|
| `rdc ls [path]` | List VFS path | `rdc ls /` |
| `rdc tree [path]` | Tree view | `rdc tree /draws` |
| `rdc cat <path>` | Read VFS node | `rdc cat /draws/142` |
