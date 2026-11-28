# Conservative cleanup review — Counterweight

Baseline: `counterweight_visible_blocks_fixed.zip` (the last confirmed-working
project delivery). Apply changes only after backing up or committing local edits;
any uncommitted differences in your working tree may prevent patch application.

## Changes in this pass

- The player's overhead weight indicator is hidden **only in HUD-equipped levels**;
  weight remains visible in the HUD and the original test room keeps its label.
  `GameHUD.hide_player_world_indicator` can be disabled in the Inspector.
- The HUD caches scene-authored puzzle buttons once, instead of searching
  the scene-tree group each frame.
- Routine debug prints from carrying, transfer, contact detection and pressure
  plates are opt-in through each node's `debug_logging` Inspector property.
  Actual warning messages stay enabled.
- Pressure plates poll physics only when a detected object could have a stack
  or carried weight; direct contacts and weight changes still use signals.
- Reloading the same level no longer rewrites the unchanged progress save.
- Removed an unused button color assignment to its hidden polygon.
- README now correctly describes the single-image parallax background.

## Explicitly unchanged

- **All 15 level scene files** and terrain geometry/collision positions.
- Weight transfer/carry rules, object collision layers, door shape/art alignment,
  button activation, timer/sequence logic, exits, hazards and autosave format.
- Supplied art and background image resources.

## Local Godot checks before merging

1. Start Level 1; confirm the player has one weight display (HUD), blocks show
   weights, and all geometry/doors/buttons still line up.
2. Move/carry a block and shift weight. Confirm the HUD prompt and player weight
   update; verify the Output panel is quiet unless you enable debug logging.
3. Test stacked blocks, a player atop a block, and carried weight on a plate.
4. Test toggle, timed and momentary buttons; memory sequence; door opens/closes.
5. Press R repeatedly and confirm restart is correct; complete a room, quit,
   restart, and confirm progress and options persist.
6. Check a long room and pause/level-select/options UI at the target resolution.

## Known limitations intentionally not changed

- The stacking detector is a proximity overlap, not a contact-force sensor; a
  falling player may briefly contribute to a block stack.
- HUD is still redrawn every frame to follow the moving player and context
  prompts; the drawing is small, and no profiler evidence justified changing it.
- Level solvability, responsive scaling, and any visual polish requiring a live
  Godot run remain manual QA items. No scenes were redesigned in this pass.
