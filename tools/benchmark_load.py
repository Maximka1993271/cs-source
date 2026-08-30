#!/usr/bin/env python3
"""Offline algorithmic load model; not a Source engine benchmark."""
from random import seed, uniform

PLAYERS = 32
SMOKES = 20
WALLHACK_MAX_TRACES = 192
CELL = 256.0
seed(1)
smoke = [(uniform(-4096, 4096), uniform(-4096, 4096)) for _ in range(SMOKES)]
players = [(uniform(-4096, 4096), uniform(-4096, 4096)) for _ in range(PLAYERS)]

def cell(v): return int(v // CELL)
def h(cx, cy): return ((cx * 73856093) ^ (cy * 19349663)) & 63

grid = [[] for _ in range(64)]
for i, (x, y) in enumerate(smoke):
    grid[h(cell(x), cell(y))].append(i)

naive = PLAYERS * SMOKES
candidates = 0
for x, y in players:
    seen = set()
    cx, cy = cell(x), cell(y)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for idx in grid[h(cx + dx, cy + dy)]:
                if idx not in seen:
                    seen.add(idx); candidates += 1
print(f"players={PLAYERS} smokes={SMOKES}")
print(f"naive checks={naive}")
print(f"grid candidate checks={candidates}")
print(f"reduction={(1 - candidates / naive) * 100.0:.1f}%")


# Bounded wallhack pressure model (not a Source-engine CPU benchmark).
max_pairs = PLAYERS * (PLAYERS - 1)
max_three_point_traces = max_pairs * 3
print(f"wallhack player pairs={max_pairs}")
print(f"wallhack worst-case 3-point traces={max_three_point_traces}")
print(f"wallhack budget={WALLHACK_MAX_TRACES} traces/window")
print(f"wallhack budget coverage={WALLHACK_MAX_TRACES / max_three_point_traces * 100.0:.1f}% of worst-case")
