#!/usr/bin/env python3
"""Shared catalog loader — parses catalog/<group>/<category>[/<subgroup>]/<id>.sh.

Mirrors core/catalog.sh so the bash, Python TUI and GUI all render the same
tool tree from a single source of truth. Tool installers are the bash
functions defined by the catalog files themselves (install_<id>), invoked
through the existing src.core.bash bridge.
"""

from dataclasses import dataclass
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
CATALOG_ROOT = PROJECT_ROOT / "catalog"
PRESETS_DIR = PROJECT_ROOT / "presets"

GROUP_ORDER = ["general", "development", "security"]
GROUP_TITLES = {"general": "General", "development": "Development", "security": "Security"}

SEGMENT_TITLES = {
    "browsers": "Browsers",
    "terminal_shells": "Terminal & Shell",
    "cli_utilities": "CLI Utilities",
    "apps": "Apps",
    "privacy": "Privacy",
    "editors_ides": "Editors & IDEs",
    "languages": "Languages",
    "app_frameworks": "App Frameworks",
    "containers": "Containers",
    "recon_osint": "Recon & OSINT",
    "network": "Network",
    "web": "Web",
    "credentials": "Credentials",
    "wireless": "Wireless",
    "reverse_forensics": "Reverse Engineering & Forensics",
    "terminals": "Terminals",
    "multiplexers": "Multiplexers",
    "shells": "Shells",
    "editors": "Editors",
    "ides": "IDEs",
    "ai_coding": "AI Coding",
    "subdomains": "Subdomains",
    "osint": "OSINT",
    "fingerprinting": "Fingerprinting",
    "exploit_lookup": "Exploit Lookup",
    "scanning": "Scanning",
    "sniffing": "Sniffing & MITM",
    "utilities": "Utilities",
    "proxies": "Proxies",
    "discovery": "Discovery & Fuzzing",
    "scanners": "Scanners",
    "exploitation": "Exploitation",
    "online": "Online Attacks",
    "offline": "Offline Cracking",
    "reverse": "Reverse Engineering",
    "forensics": "Forensics",
    "mainstream": "Mainstream",
    "passwords": "Passwords & Vaults",
}

CATEGORY_ICONS = {
    "browsers": "🌐",
    "terminal_shells": "🖥️",
    "apps": "💼",
    "privacy": "🕶️",
    "cli_utilities": "🔧",
    "editors_ides": "💻",
    "languages": "📜",
    "app_frameworks": "🧱",
    "containers": "🐳",
    "recon_osint": "🔍",
    "network": "📡",
    "web": "🌍",
    "credentials": "🔑",
    "wireless": "📶",
    "reverse_forensics": "🧬",
}


def title_of(node_path: str) -> str:
    segments = node_path.split("/") if node_path else []
    parts = []
    for i, seg in enumerate(segments):
        if i == 0:
            parts.append(GROUP_TITLES.get(seg, seg.replace("_", " ").title()))
        else:
            parts.append(SEGMENT_TITLES.get(seg, seg.replace("_", " ").title()))
    return " & ".join(parts)


def icon_of(node_path: str) -> str:
    for seg in reversed(node_path.split("/")):
        if seg in CATEGORY_ICONS:
            return CATEGORY_ICONS[seg]
    return "🧰"


@dataclass
class Tool:
    id: str
    name: str
    desc: str
    method: str
    tags: list[str]
    fn: str
    pkg: str
    path: str

    @property
    def bin_names(self) -> list[str]:
        bins = []
        if self.pkg:
            bins.append(self.pkg)
        id_bin = self.id.replace("_", "-")
        if id_bin not in bins:
            bins.append(id_bin)
        return bins


def _parse_tool(sh_file: Path) -> Tool | None:
    meta: dict[str, str] = {}
    try:
        content = sh_file.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return None
    for line in content.splitlines():
        line = line.strip()
        if not line.startswith("#") and line:
            break
        m_line = line[1:].strip()
        if ":" in m_line:
            key, _, value = m_line.partition(":")
            key = key.strip()
            if key in ("id", "name", "desc", "method", "pkg", "tags"):
                meta[key] = value.strip()
    tool_id = meta.get("id", sh_file.stem)
    tags = [t.strip() for t in meta.get("tags", "").split(",") if t.strip()]
    rel = sh_file.parent.relative_to(CATALOG_ROOT)
    return Tool(
        id=tool_id,
        name=meta.get("name", tool_id),
        desc=meta.get("desc", ""),
        method=meta.get("method", "unknown"),
        tags=tags,
        fn=f"install_{tool_id}",
        pkg=meta.get("pkg", ""),
        path=str(rel),
    )


_CACHE: list[Tool] | None = None


def all_tools() -> list[Tool]:
    """Return every Tool in the catalog, sorted by node path (stable)."""
    global _CACHE
    if _CACHE is not None:
        return _CACHE
    tools: list[Tool] = []
    if CATALOG_ROOT.is_dir():
        for sh_file in sorted(CATALOG_ROOT.glob("*/*/*.sh")) + sorted(CATALOG_ROOT.glob("*/*/*/*.sh")):
            t = _parse_tool(sh_file)
            if t is not None:
                tools.append(t)
    tools.sort(key=lambda t: t.path)
    _CACHE = tools
    return tools


def groups() -> list[str]:
    return list(GROUP_ORDER)


def group_path(group: str) -> str:
    return group


def categories(group: str) -> list[str]:
    cats = set()
    for t in all_tools():
        if t.path.startswith(group + "/"):
            cats.add(group + "/" + t.path.split("/")[1])
    return sorted(cats)


def subgroups(category_path: str) -> list[str]:
    subs = set()
    for t in all_tools():
        if t.path.startswith(category_path + "/"):
            subs.add("/".join(t.path.split("/")[:3]))
    return sorted(subs)


def tools_at(node_path: str) -> list[Tool]:
    return [t for t in all_tools() if t.path == node_path]


def tools_under(node_path: str) -> list[Tool]:
    return [t for t in all_tools() if t.path == node_path or t.path.startswith(node_path + "/")]


def tool_by_id(tool_id: str) -> Tool | None:
    for t in all_tools():
        if t.id == tool_id:
            return t
    return None


def presets() -> list[str]:
    """Available profile names from presets/*.list."""
    if not PRESETS_DIR.is_dir():
        return []
    return sorted(p.stem for p in PRESETS_DIR.glob("*.list"))


def preset_tools(name: str) -> list[Tool]:
    """Tools listed in presets/<name>.list (one id per line, '#' comments)."""
    file = PRESETS_DIR / f"{name}.list"
    if not file.exists():
        return []
    content = file.read_text(encoding="utf-8", errors="ignore")
    tools = []
    for line in content.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        t = tool_by_id(line)
        if t is not None:
            tools.append(t)
    return tools


def leaf_nodes() -> list[tuple[str, str, str]]:
    """(path, title, icon) for every category/subgroup holding tools — GUI sidebar."""
    nodes = []
    for group in GROUP_ORDER:
        for cat in categories(group):
            subs = subgroups(cat)
            cat_label = title_of(cat).split(" & ")[-1]
            if subs:
                for sub in subs:
                    sub_label = title_of(sub).split(" & ")[-1]
                    nodes.append((sub, sub_label if sub_label == cat_label else f"{cat_label}: {sub_label}", icon_of(sub)))
            else:
                nodes.append((cat, title_of(cat), icon_of(cat)))
    return nodes
