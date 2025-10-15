#!/usr/bin/env python3

from collections import defaultdict


def nest() -> defaultdict:
    return defaultdict(nest)


def tree_to_lines(name: str, content: dict,
                  indent: int = 0) -> tuple[list[str], float]:
    lines = []
    total = 0

    for k, v in content.items():
        if isinstance(v, dict):
            l, t = tree_to_lines(k, v, indent + 1)
            lines.extend(l)
            total += t
        else:
            lines.append(f'{'    ' * (indent + 1)}{k}: {v:.2f}')
            total += v

    lines.insert(0, f'{'    ' * indent}{name}: {total:.2f}')

    return lines, total
