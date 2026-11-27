# Counterweight — Art, HUD, Menus & Saves

## Integration baseline
Built from `counterweight_15_levels.zip`, which was verified to match the
public `main` repository file hashes when work began. Keep the changes in a
new branch and resolve any subsequent contributions from Flocos before merge.

## Supplied art
- `Assets/Art/Tileset.png`: 32×32 orange terrain (drawn by solid `TerrainSection` nodes in all 15 levels),
  32×32 teal alternative tile (available in TileSet), 16×16 orange/teal blocks
  (displayed at 2× to preserve the existing 32×32 physics), 32×6 gray platform
  (new reusable `Scenes/Objects/one_way_platform.tscn`, with visual trim on early raised ledges), and 32×2 yellow button.
- `Assets/Art/Door.png`: scaled into existing 32×64 and 32×128 door colliders;
  tall variation is stretched vertically, which can be replaced if more art arrives.
- `Assets/Art/BG.png`: a single, non-repeating image in each level’s `Parallax2D`; on the main menu it is uniformly cover-scaled, not tiled.
- `Assets/Art/Hazards/e-floor-source.gif`: original animated hazard. Since a Godot
  AnimatedSprite2D uses SpriteFrames textures, it was split into three transparent
  PNG frames, each played at 10 frames/second. Spike hazard colliders remain.
- Pixel sprites set texture filtering to nearest. No HUD/menu images were added.

## UI
- HUD `Scripts/UI/game_hud.gd`: draws shapes and text using Godot CanvasItem,
  shows level title/objective, intrinsic weight, carried and applied weight,
  keyboard shortcuts and context prompts near the player.
- Escape: pause panel (Resume, Restart, Options, Main Menu).
- Main menu: Continue, Start from 01, Level Select, Options, Credits, Quit.
- Level Select shows all 15 levels; incomplete levels are locked.
- Options: Master/Music/SFX volumes, Fullscreen, Hints, Context Prompts.
  The supplied artwork contains no music or sound: music/SFX buses are ready but
  silent until the team's audio files are integrated.
- Credits include placeholders for artist/composer names; replace before release.

## Saving
`GameState` is an autoload configured in `project.godot`. Progress and options
are stored in `user://counterweight_save.cfg` via `ConfigFile`. A checkpoint is
saved when the exit is reached, then the next room loads. Exiting the game in
mid-room restores that level from its starting state, not the position of boxes
or the player. `R` reloads the current room without changing the unlock state.

## Hand-off acceptance test
1. Launch F5 and see the main menu.
2. Start Level 01; confirm supplied terrain/block/background visuals and HUD.
3. Carry a block; verify context prompt and applied-weight readout.
4. Visit a level with buttons/doors, confirm art and activation.
5. Visit Level 05, check hazard animation and reset on contact.
6. Complete Level 01 and return to menu; Level 02 becomes selectable.
7. Exit/relaunch; confirm Continue and Level 02 persist.
8. Change volume, fullscreen and hints; relaunch to confirm persistence.
9. Press Esc in a room; verify pause/resume and menu navigation.
10. Complete Level 15 and confirm victory and navigation.

## Terrain repair
The earlier packed TileMapLayer data has been removed from all 15 levels.
Solid geometry was rebuilt as `StaticBody2D` terrain sections with serialized
`CollisionShape2D` rectangles and 32×32 art drawing. See `TERRAIN_REPAIR.md`.
Verify all stages and their collisions in the Godot editor before merging.

## Unverified
No full automated Godot runtime test or manual solvability playtest was possible
in this build environment. Check all 15 puzzles before release. Level 10/14/15
are especially important, and door art is still stretched for tall variants.
