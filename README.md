# Counterweight — Game Off 2026

Godot 4.6 · 2D weight-transfer puzzle platformer · 32×32 tile grid.

## Start playing

Open `project.godot` in Godot 4.6 and press **F5** to begin at **Level 1**. The project now contains a linked 15-level greybox and a completion screen. To playtest an individual room, open `Scenes/Levels/level_XX.tscn` and press **F6**.

The original prototype room is preserved at `Scenes/Rooms/test_room.tscn`.

## Controls

| Key | Action |
|---|---|
| A / D | Move |
| Space | Jump (affected by intrinsic player weight) |
| Q / E | Give / take one weight unit |
| F | Pick up / drop a block (up to weight 2) |
| R | Reset the room |

## Button modes

- `T`: toggle — once pressed, retains state until pressed again.
- `S`: timed — remains active for a short interval after pressing.
- `H`: momentary — active only while enough weight is applied.

All button modes accept configurable required weights. They use the existing `PressurePlate`, so blocks, stacked bodies, players, and carried blocks contribute appropriately. A separate sequence controller implements the four-button memory challenge.

## Handoff and limitations

See [`Docs/LEVEL_GUIDE.md`](Docs/LEVEL_GUIDE.md) for all 15 rooms, intended solutions, design constraints, and the playtest checklist. These are **first-pass greybox rooms** with programmer art; source files were statically checked but require a Godot runtime playtest and design polish before merging to `main`.

Submit this work for team review using your existing feature-branch/PR process. Do not replace someone else's changes without inspecting the diff.
