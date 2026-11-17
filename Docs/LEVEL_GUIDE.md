# Counterweight — 15 Level Greybox Handoff

This is an **editable 15-room greybox**, made using the uploaded project's
existing 32×32 terrain, character, weight blocks, transfer mechanics, and
stacked/carried-weight calculations. Gameplay balance and full solvability
still need interactive Godot playtesting.

## Running

Open `project.godot` in Godot 4.6 and press F6 on any
`Scenes/Levels/level_XX.tscn`, or F5 to begin at Level 1.
`Scenes/Rooms/test_room.tscn` is unchanged and remains available.

**Controls:** A/D move, Space jump, Q give weight, E take weight,
F pick up/drop, R reset.

Each level scene contains its own player instance, terrain, weight blocks,
exit, optional PuzzleButtons and doors, plus a CanvasLayer hint.
The last exit opens the victory scene; Space/F there restarts the game.

## Button modes

- **T**: toggles on or off each time the threshold is met.
- **S**: timer starts on threshold press, counts down, then shuts off.
- **H**: only active while sufficient combined weight rests on it.

All three reuse the existing `PressurePlate` and therefore count stacks,
players, and carried weight. The memory game is a separate `SequenceController`
and uses four ordinary H buttons. The sequence flashes in yellow, and
wrong inputs replay the same randomly generated sequence.

## Level breakdown

| Level | Title | Main challenge |
|---|---|---|
| 01 | A Step Up | Carry one block as a step to the upper exit |
| 02 | Building Higher | Stack two blocks to reach the taller exit |
| 03 | Light on Your Feet | Give away player weight for higher jumping |
| 04 | The Long Way Across | Become light to clear a five-tile pit |
| 05 | The Ascent | Stack, shift weight, and jump past spikes |
| 06 | First Contact | Toggle button opens the door |
| 07 | Against the Clock | Timed button and short sprint |
| 08 | Two-Step Security | Two toggled gates in sequence |
| 09 | Remember the Order | Reproduce four flashed buttons |
| 10 | The Switchboard | Toggle, timed, chained, and memory chambers |
| 11 | The Extra Burden | Carry a block to supply a weight-4 toggle |
| 12 | Leave Something Behind | Leave block on a hold-to-open switch |
| 13 | The Price of Passage | Transfer into a block to hold a weight-3 plate |
| 14 | Balancing Act | Sustain two weight-3 plates with multiple blocks |
| 15 | Counterweight | Two distribution plates, sprint, and memory finale |

## Design and integration notes

- All backgrounds, objects, and terrain are programmer-art greyboxes.
- New level instances override player's normal/light jump speeds to 380/460
  px/s (original test room stays at its existing values), to avoid
  pixel-perfect introductory jumps. Tune before shipping.
- Existing `CarryComponent` positions blocks beside the player, not at
  an arbitrary cursor point. Stand on one block while carrying another
  to create a stack.
- Tall door collision is 128px, preventing a normal ground-level jump
  from bypassing it. It may still be bypassed via nearby stacked blocks,
  so playtest placement before production.
- The memory game *blinks physical buttons* rather than exposing its
  answer text. Sequence is random on level load and stable on retries.
- No sound, narrative cutscenes, or final art were supplied in this project.
- Keep these rooms on a separate branch and inspect/test before merging
  them into `main`, especially where Flocos may have changed shared scenes.

## Things to verify in Godot

1. All level scenes open cleanly and the level exits advance correctly.
2. Levels 1–5 can be solved without jumping around required challenges.
3. Falling into the pit or touching spikes resets the room.
4. Buttons activate with player, block, stack, and carried weight.
5. Timed gates remain open long enough at intended run speed.
6. Memory flashes, input detection, and error replay function as intended.
7. The long Levels 10, 14 and 15 scroll correctly with Camera2D.
8. Total weight budgets in Levels 14 and 15 permit the intended solution.
