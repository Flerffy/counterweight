# Terrain and Parallax Repair — Counterweight

## What changed
- Rebuilt the solid floors/walls of all 15 level scenes using serialized `StaticBody2D` nodes.
- Each `TerrainSectionNN` has an explicit `CollisionShape2D` rectangle and renders the
  artist's **32×32 orange floor tile** directly from `Assets/Art/Tileset.png`.
- No gameplay level relies on packed `TileMapLayer.tile_map_data` to create its floor.
- Replaced repeated background tiles with **one `Parallax2D` per level**, containing a
  single `Sprite2D` of the supplied `BG.png`. Its `repeat_size` is `(0, 0)`.
- The main menu also shows the background as a single cover-scaled image.
- Existing HUD, options, autosave, doors, hazards, blocks, and scene transitions are kept.

## Editor workflow
1. Open `Scenes/Levels/level_01.tscn` and expand its `Terrain` node.
2. Select any `TerrainSectionNN` to see its editable shape and pixel-art drawing.
3. Add/move/resize terrain sections to adjust platforms. When resizing, update both
   the `columns` / `rows` drawing properties **and** the collision rectangle size.
4. The backdrop is `Backdrop (Parallax2D) > BackgroundArt (Sprite2D)`.
   `BG.png` is not a terrain tile and does **not** repeat.

## Collision layout
The footprint of all pre-existing floor and ledge cells was reconstructed from the
15-level plan (32×32 grid, world origin at the top-left). Each tile appears exactly
once across the serialized rectangular terrain sections. All surfaces are on layer 1.

## Validation limitations
Scene geometry/resource references are checked statically. Godot's runtime is not
available in this execution environment, so you must run and playtest each room
before merging. In particular check the 15-level greybox puzzles for solvability.

## Level breakdown
| Room | Filled terrain cells | Solid terrain sections |
|---|---:|---:|
| 01 | 83 | 2 |
| 02 | 83 | 2 |
| 03 | 85 | 2 |
| 04 | 81 | 2 |
| 05 | 75 | 2 |
| 06 | 98 | 2 |
| 07 | 98 | 2 |
| 08 | 100 | 3 |
| 09 | 98 | 2 |
| 10 | 226 | 6 |
| 11 | 98 | 2 |
| 12 | 98 | 2 |
| 13 | 98 | 2 |
| 14 | 190 | 3 |
| 15 | 260 | 5 |
