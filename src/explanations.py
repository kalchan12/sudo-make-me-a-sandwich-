#!/usr/bin/env python3
"""Tool explanations — calls bash explanations.sh"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))


def explain(name: str) -> int:
    from src.core.bash import call

    code, out, err = call("_explain_tool", name)
    if out.strip():
        print(out)
    if err.strip():
        print(err, file=sys.stderr)
    return code


def explain_by_index(tools_list: list, idx: int) -> int:
    if 0 <= idx < len(tools_list):
        name = tools_list[idx][0]
        return explain(name)
    print(f"Invalid index: {idx}")
    return 1


if __name__ == "__main__":
    from src.core.bash import setup as bash_setup

    bash_setup(os.path.join(os.path.dirname(__file__), ".."))

    if len(sys.argv) < 2:
        print("Usage: explanations.py <tool_name>")
        sys.exit(1)

    sys.exit(explain(" ".join(sys.argv[1:])))
