#!/usr/bin/env python3
"""Skill 索引自动生成脚本：扫描 SKILL.md 并生成 Markdown 索引表。"""
import sys, os, re
from pathlib import Path
from glob import glob

# 确保 stdout/stderr 使用 UTF-8 编码（Windows 兼容）
sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

START_MARK = "<!-- SKILL-INDEX-START -->"
END_MARK = "<!-- SKILL-INDEX-END -->"

def parse_skill(filepath):
    """解析单个 SKILL.md，提取 frontmatter 和功能域。"""
    text = Path(filepath).read_text(encoding="utf-8")
    # 提取 YAML frontmatter
    fm = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not fm:
        print(f"[警告] 无 frontmatter，已跳过: {filepath}", file=sys.stderr)
        return None
    body = fm.group(1)
    # 提取 name
    m_name = re.search(r"^name:\s*(.+)$", body, re.MULTILINE)
    name = m_name.group(1).strip().strip("\"'") if m_name else Path(filepath).parent.name
    # 提取 description（截取前80字符）
    m_desc = re.search(r"^description:\s*(.+)$", body, re.MULTILINE)
    desc = m_desc.group(1).strip().strip("\"'")[:80] if m_desc else ""
    # 提取 deprecated 标记
    m_dep = re.search(r"^deprecated:\s*(.+)$", body, re.MULTILINE)
    deprecated = m_dep and m_dep.group(1).strip().lower() in ("true", "yes", "1")
    # 从正文 ## Overview 段落提取第一句话作为功能域
    content_after_fm = text[fm.end():]
    m_overview = re.search(r"##\s+Overview\s*\n+(.*?)(?:\n\n|\n##|\Z)", content_after_fm, re.DOTALL)
    if m_overview:
        first_sentence = re.split(r"[。.！!？?\n]", m_overview.group(1).strip())[0]
        domain = first_sentence.strip()
    else:
        # 回退：取 frontmatter 后第一个非空非标题行
        lines = [l.strip() for l in content_after_fm.splitlines() if l.strip() and not l.strip().startswith("#") and not l.strip() == "---"]
        domain = re.split(r"[。.！!？?\n]", lines[0])[0].strip() if lines else desc
    return {"name": name, "desc": desc, "deprecated": deprecated, "domain": domain}

def build_table(skills):
    """生成 Markdown 三列索引表。"""
    rows = ["| Skill | 功能域 | 状态 |", "|-------|--------|------|"]
    for s in sorted(skills, key=lambda x: x["name"]):
        status = "[废弃]" if s["deprecated"] else "-"
        rows.append(f"| {s['name']} | {s['domain']} | {status} |")
    return "\n".join(rows)

def inject_into_file(md_path, table):
    """幂等注入索引表到 CLAUDE.local.md（通过标记注释替换）。"""
    block = f"{START_MARK}\n{table}\n{END_MARK}"
    p = Path(md_path)
    if p.exists():
        content = p.read_text(encoding="utf-8")
        # 幂等替换已有标记区域
        pattern = re.compile(re.escape(START_MARK) + r".*?" + re.escape(END_MARK), re.DOTALL)
        if pattern.search(content):
            content = pattern.sub(block, content)
        else:
            content = content.rstrip("\n") + "\n\n" + block + "\n"
    else:
        content = block + "\n"
    p.write_text(content, encoding="utf-8")
    print(f"[完成] 索引已写入: {md_path}", file=sys.stderr)

def main():
    if len(sys.argv) < 2:
        print("用法: python generate-skill-index.py <skills-dir> [claude-md-path]", file=sys.stderr)
        sys.exit(1)
    skills_dir = Path(sys.argv[1])
    claude_md = sys.argv[2] if len(sys.argv) > 2 else None
    # 扫描所有 SKILL.md（跨平台兼容）
    pattern = str(skills_dir / "*" / "SKILL.md")
    files = glob(pattern)
    if not files:
        print(f"[警告] 未找到 SKILL.md 文件: {pattern}", file=sys.stderr)
        sys.exit(0)
    # 解析所有 skill
    skills = []
    for f in files:
        info = parse_skill(f)
        if info:
            skills.append(info)
    table = build_table(skills)
    if claude_md:
        inject_into_file(claude_md, table)
    else:
        print(table)

if __name__ == "__main__":
    main()
