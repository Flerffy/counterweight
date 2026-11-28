# SFX, Player Facing, and World Bounds

## Audio mappings

All sounds route through the existing **SFX** audio bus, so **Options → Sound Effects** and **Master** govern volume. Background music remains on the Music bus.

| Uploaded file | Trigger |
| --- | --- |
| `Step_sound.wav` | A normal, weighted, or puzzle-button pressure plate first activates |
| `Door_Open_sound.wav` | A door changes from closed to open |
| `Door_Close_sound.wav` | A door changes from open to closed |
| `Robot_Hand_sound.wav` | A successful Q/E weight transfer, F pickup, or F drop |
| `Wheel_sound.wav` | Player moves while grounded, as a loop; stops midair/idle |
| `ambience_sound_1.wav` … `ambience_sound_7.wav` | Random low-volume ambient event every 10–19 seconds during gameplay |
| `Steam_sound.wav` | Random low-volume steam event in the same rotation |

Room ambience does **not** play in the menus. WAVs are preserved. Tune effects in `sound_manager.gd` or `player.gd`.

## Player orientation

`player.gd` sets `Sprite2D.flip_h` only while moving left or right and preserves facing when idle. Movement physics and collision shapes are unchanged.

## Boundaries and falling

`LevelRoom` uses existing Camera2D limits to add runtime invisible StaticBody2D walls on the left/right and a ceiling. Bottom stays open for pits. If the player falls more than `pit_reset_margin` (default 128 px) beyond the camera bottom, the level restarts. Existing spike and void hazards are preserved and can trigger a reset sooner.

Wider rooms (10, 14, 15) use their own camera limits automatically. `LevelRoom.enable_boundaries` can be disabled per-room in Inspector.

## Godot 4.6 validation checklist

1. Run F5 from menu; confirm existing BGM continues across levels.
2. In Level 1, move left/right; sprite mirrors and wheel sound follows grounded motion. Jump stops wheel sound.
3. Open/close a door; distinct door sounds play once per change.
4. Step on a button; one step sound per activation, not continuously.
5. Transfer weight and carry/drop a block; robot-hand sound plays on successful actions only.
6. Wait in a level: sporadic quiet ambience and steam; return to menu: ambience stops.
7. Press against left/right edges in Levels 1, 10, 14, and 15; cannot leave the area.
8. Fall into Level 4's gap or any pit; automatic room restart, while R still works.
9. Options → Sound Effects changes wheel/button/door/ambient sound. Music volume affects only BGM.
10. Check stacked/carried weight pressure plates and run all 15 levels.

**Note:** This patch passed static file checks, but the build environment has no Godot runtime. Playtest before merging.
