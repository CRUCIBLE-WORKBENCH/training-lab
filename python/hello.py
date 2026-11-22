# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/python/hello.py
# Created     : 2026-11-22
# Description : Basic Python script: prints the AND-gate truth table and checks it.
# ===============================================================================
"""Run it two ways and compare:

    igny run script python/hello.py
    python3 python/hello.py

Exit status is 0 when every row matches, 1 otherwise.
"""
import sys


def and_gate(a: int, b: int) -> int:
    return a & b


def main() -> int:
    print(f"Python {sys.version.split()[0]} running: {sys.argv[0]}")
    print(" a b | y")
    bad = 0
    for i in range(4):
        a, b = (i >> 1) & 1, i & 1
        y = and_gate(a, b)
        ok = y == (1 if (a == 1 and b == 1) else 0)
        bad += not ok
        print(f" {a} {b} | {y}{'' if ok else '  MISMATCH'}")
    if bad:
        print(f"FAIL: {bad} mismatch(es)")
        return 1
    print("PASS: 4 input combinations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
