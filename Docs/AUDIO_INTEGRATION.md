# Counterweight — Background Music Integration

## What is installed

- `Audio/Music/counterweight_bgm.ogg` — compressed copy of the supplied `test.wav` (stereo 44.1 kHz; about 1:54).
- `Scripts/Systems/music_manager.gd` — autoloaded continuous audio player, playing on the existing `Music` bus.
- `project.godot` — adds `MusicManager` after `GameState` in the autoload list.
- `Scripts/UI/game_menu.gd` — updates options-menu copy; existing volume sliders and save logic are unchanged.

## Playback behavior

- Starts once at boot, including main menu, and does not restart when changing levels or opening the options menu.
- Uses native `AudioStreamOggVorbis.loop` (not polling `finished` or manually restarting playback).
- Continues during the pause menu.
- The existing **Master** slider changes all sound. The **Music** slider changes this track only; **SFX** remains separate.
- Volumes remain saved in `user://counterweight_save.cfg` by `GameState`.

## Playtest checklist

1. Launch at the main menu: confirm music starts (on web, browsers may require a user gesture before audio is audible).
2. Select a level and return to the menu: music should *not* restart.
3. Move Music slider to 0%: BGM should mute; restore to 50%: it should return.
4. Move Master slider to 0%: everything should mute; restore it.
5. Restart game: verify music volume persists.
6. Pause/unpause: music should continue uninterrupted.
7. Let the entire track loop: listen for any undesirable silence or click at the loop point.

## Note for the composer

The provided WAV contains roughly 0.24 seconds of near-silence at the end. This integration retains that audio as supplied. If the repeat sounds like a pause, obtain an exact looping master or loop-point recommendation from the composer; do not guess the musical boundary.

Keep this on its own audio integration branch and test before merging into `main`.
