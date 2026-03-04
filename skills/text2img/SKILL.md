---
name: text2img
description: 文生图/图片编辑工具。调用图像生成 API，支持纯文生图和基于参考图的编辑。当用户要求"画"、"生成图片"、"文生图"、"修改图片"、"编辑图片"、"draw"、"generate image"、"画一张"、"帮我画"时使用。
---

# Text2Image

通过 OpenAI 兼容接口调用图像生成模型，支持两种模式：
1. **纯文生图**：根据文字描述生成图片
2. **图片编辑**：基于参考图 + 文字指令进行编辑/合成

---

## 环境变量

| 变量 | 必须 | 说明 |
|------|------|------|
| `TEXT_2_IMAGE_BASE_URL` | 是 | API Base URL |
| `TEXT_2_IMAGE_API_KEY` | 是 | API Key |

## 脚本

| 脚本 | 用途 |
|------|------|
| `scripts/generate.py` | 纯文生图 |
| `scripts/edit.py` | 图片编辑（传入参考图） |

---

## 执行流程

### Phase 0: PREFLIGHT（环境检查）

检查环境变量和依赖：
```bash
echo "TEXT_2_IMAGE_BASE_URL=${TEXT_2_IMAGE_BASE_URL:-<not set>}"
echo "TEXT_2_IMAGE_API_KEY=${TEXT_2_IMAGE_API_KEY:+set}"
python -c "import openai" 2>/dev/null || pip install openai -i https://pypi.org/simple/
```

如果环境变量未设置，提示用户配置后再试。

### Phase 1: PARSE（解析需求）

从用户输入中提取：
1. **模式判断**：是否有参考图片
   - 无参考图 → **文生图模式** → 用 `scripts/generate.py`
   - 有参考图 → **图片编辑模式** → 用 `scripts/edit.py`
2. **图片描述 (prompt)**：用户想要生成/编辑的内容描述
3. **参考图片路径**：编辑模式下的参考图片（支持多张）
4. **输出文件名**：可选，默认为 `generated_<描述>.png`

如果用户描述模糊，用简短追问澄清画面内容。
prompt 建议使用英文以获得更好效果，如果用户用中文描述，帮用户翻译成英文。

### Phase 2: GENERATE（生成图片）

**脚本路径基于此 skill 的 base directory。**

#### 模式 A：纯文生图

```bash
python <SKILL_BASE_DIR>/scripts/generate.py "<PROMPT>" -o "<OUTPUT_FILE>"
```

#### 模式 B：图片编辑

```bash
python <SKILL_BASE_DIR>/scripts/edit.py "<EDIT_INSTRUCTION>" -i <REF_IMG1> [<REF_IMG2> ...] -o "<OUTPUT_FILE>"
```

### Phase 3: REPORT（输出结果）

1. 确认图片已生成，告知用户文件路径
2. 使用 Read 工具读取生成的图片展示给用户
3. 如果生成失败，报告错误信息并建议调整 prompt 重试

---

## 注意事项

- 模型默认使用 `gemini-3.1-flash-image-preview`，可通过 `-m` 参数切换
- 输出格式为 PNG
- 优先使用 `python`，如果不可用尝试 `python3`
- **图片编辑模式不支持 `images.edit` 端点**，脚本使用 `chat.completions` 多模态接口
- 编辑模式的响应图片在 `response.model_dump()['choices'][0]['message']['images']` 中
