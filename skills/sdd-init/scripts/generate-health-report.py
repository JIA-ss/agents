#!/usr/bin/env python3
"""Skill 健康报告生成脚本：扫描 .claude/skills/*/ 并输出 Markdown 健康报告。"""
import sys, os, re, argparse
from pathlib import Path
from datetime import datetime, timedelta
from glob import glob

# 默认阈值（天）
STALE_DAYS = 30      # 超过此天数未更新视为"需关注"
YOUNG_DAYS = 14       # 创建不足此天数视为"数据不足"


def load_config(skill_dir):
    """从 .evolution/config.yaml 读取阈值覆盖（纯正则，无需 yaml 库）。"""
    cfg = skill_dir / ".evolution" / "config.yaml"
    if not cfg.exists():
        return {}
    text = cfg.read_text(encoding="utf-8")
    result = {}
    # 简易提取 stale_days / young_days
    for key in ("stale_days", "young_days"):
        m = re.search(rf"^\s*{key}\s*:\s*(\d+)", text, re.MULTILINE)
        if m:
            result[key] = int(m.group(1))
    return result


def parse_frontmatter_name(skill_md):
    """解析 SKILL.md frontmatter 中的 name 字段。"""
    text = skill_md.read_text(encoding="utf-8")
    fm = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not fm:
        return skill_md.parent.name
    m = re.search(r"^name:\s*(.+)$", fm.group(1), re.MULTILINE)
    return m.group(1).strip().strip("\"'") if m else skill_md.parent.name


def parse_changelog(changelog_path):
    """解析 changelog.md 表格，返回 (最后更新日期, 更新次数, 最早日期)。"""
    if not changelog_path.exists():
        return None, 0, None
    text = changelog_path.read_text(encoding="utf-8")
    # 匹配表格行中的日期 YYYY-MM-DD
    dates = re.findall(r"\|\s*(\d{4}-\d{2}-\d{2})\s*\|", text)
    if not dates:
        return None, 0, None
    parsed = sorted(set(datetime.strptime(d, "%Y-%m-%d") for d in dates))
    return parsed[-1], len(dates), parsed[0]


def count_failures(skill_dir):
    """统计 .evolution/failures/ 下的失败记录文件数。"""
    fdir = skill_dir / ".evolution" / "failures"
    if not fdir.is_dir():
        return 0
    return len([f for f in fdir.iterdir() if f.is_file()])


def determine_status(last_update, first_date, now, stale, young):
    """判定状态：健康 / 需关注 / 数据不足。"""
    if first_date and (now - first_date).days < young:
        return "数据不足"
    if last_update is None or (now - last_update).days > stale:
        return "需关注"
    return "健康"


def build_report(records, now):
    """生成完整的 Markdown 健康报告。"""
    lines = [f"# Skill 健康报告", "", f"> 生成时间: {now.strftime('%Y-%m-%d %H:%M')}", ""]
    # 概览统计
    total = len(records)
    healthy = sum(1 for r in records if r["status"] == "健康")
    attention = sum(1 for r in records if r["status"] == "需关注")
    insufficient = sum(1 for r in records if r["status"] == "数据不足")
    lines += [f"## 概览", "",
              f"- 总计: {total} 个 Skill",
              f"- 健康: {healthy} | 需关注: {attention} | 数据不足: {insufficient}", ""]
    # 概览表
    lines += ["## 详情", "",
              "| Skill | 最后更新 | 更新次数 | 失败记录 | 状态 |",
              "|-------|----------|----------|----------|------|"]
    for r in sorted(records, key=lambda x: x["name"]):
        last = r["last_update"].strftime("%Y-%m-%d") if r["last_update"] else "N/A"
        fails = str(r["failures"]) if r["failures"] else "-"
        lines.append(f"| {r['name']} | {last} | {r['count']} | {fails} | {r['status']} |")
    lines.append("")
    # 需关注列表及建议
    need_attn = [r for r in records if r["status"] == "需关注"]
    if need_attn:
        lines += ["## 需关注的 Skill", ""]
        for r in sorted(need_attn, key=lambda x: x["name"]):
            days = (now - r["last_update"]).days if r["last_update"] else -1
            lines.append(f"### {r['name']}")
            if r["last_update"] is None:
                lines.append("- 缺少 changelog，建议启用 self-evolution 并记录变更。")
            else:
                lines.append(f"- 已 {days} 天未更新，建议审视是否需要迭代或标记为稳定。")
            if r["failures"]:
                lines.append(f"- 存在 {r['failures']} 条失败记录，建议优先处理。")
            lines.append("")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description="生成 Skill 健康报告")
    ap.add_argument("skills_dir", help="skills 根目录路径（含 */SKILL.md）")
    ap.add_argument("-o", "--output", help="输出文件路径（默认输出到 stdout）")
    args = ap.parse_args()

    skills_dir = Path(args.skills_dir)
    now = datetime.now()
    pattern = str(skills_dir / "*" / "SKILL.md")
    files = glob(pattern)
    if not files:
        print(f"[警告] 未找到 SKILL.md: {pattern}", file=sys.stderr)
        sys.exit(0)

    records = []
    for f in files:
        sd = Path(f).parent
        # 跳过 .system 等隐藏目录
        if sd.name.startswith("."):
            continue
        # 加载每个 skill 独立的阈值配置
        cfg = load_config(sd)
        stale = cfg.get("stale_days", STALE_DAYS)
        young = cfg.get("young_days", YOUNG_DAYS)

        name = parse_frontmatter_name(Path(f))
        cl = sd / ".evolution" / "changelog.md"
        last_update, count, first_date = parse_changelog(cl)
        failures = count_failures(sd)
        status = determine_status(last_update, first_date, now, stale, young)
        records.append({"name": name, "last_update": last_update,
                        "count": count, "failures": failures, "status": status})

    report = build_report(records, now)
    if args.output:
        Path(args.output).write_text(report, encoding="utf-8")
        print(f"[完成] 报告已写入: {args.output}", file=sys.stderr)
    else:
        print(report)


if __name__ == "__main__":
    main()
