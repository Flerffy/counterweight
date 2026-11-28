# Counterweight — Game Off 2026

Godot 4.6 · 2D weight-transfer puzzle platformer · 32×32 base tile grid.

## Play

Open `project.godot` in Godot 4.6 and press **F5**. The game opens to the **main menu**.
Select **Start from Level 01**, or **Continue** a saved game. The **Level Select**
menu shows the 15 levels and locks unfinished rooms. Press F6 in any level scene
for targeted playtests. `Scenes/Rooms/test_room.tscn` is preserved.

## Controls

| Key | Action |
|---|---|
| A / D | Move |
| Space | Jump (depends on intrinsic player weight) |
| Q / E | Give / take weight |
| F | Pick up / drop (carry capacity = 2) |
| R | Restart current level |
| Escape | Pause / resume |

## New UI and persistence

- Shape-drawn HUD displays the player's weight, carried and applied weight,
  the level objective, movement keys and contextual action prompts.
- Main Menu, Pause, Level Select, Options, and Credits are implemented with
  reusable Godot interface controls and simple shapes, **not GUI image files**.
- Options configure Master/Music/SFX volumes, fullscreen, hints, and prompts.
- The game autosaves unlocked levels and preferences at
  `user://counterweight_save.cfg`. Room object placement is intentionally not
  saved: restarting always returns to a room's initial state.
- Music/SFX buses are ready for the team audio files; no tracks were supplied.
- Replace artist/composer placeholders in `Scripts/UI/game_menu.gd` before release.

## Artwork

The supplied team sprites are integrated: orange floor tiles, teal alternate
terrain, recolored small physics blocks, door sprites, a single non-repeating
parallax background, two-state gold buttons and three-frame electric-floor hazards. Gray
platform artwork is available as a reusable one-way platform and as trim on
select ledges. See `Docs/INTEGRATION.md`.

## Existing mechanics

Three button behaviors: Toggle, Timed and Momentary. Each can have a weight
threshold, and pressure plates count block stacks, players and carried weight.
`SequenceController` handles the memory game. The original 15-level design is
in `Docs/LEVEL_GUIDE.md`.

## Development and review

This is an **integrated greybox**. All scene-resource references were checked
statically, but the modified game has **not been run in Godot in this environment**.
Playtest, review the PR, and resolve any changes by Flocos before merging.
