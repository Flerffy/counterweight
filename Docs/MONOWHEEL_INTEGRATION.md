# Monowheel robot integration

This feature replaces the placeholder player artwork with the supplied `Thrashy-Big.png` body and `Tires.png` 11×2 sprite sheet, without changing the player's collision or weight-transfer rules.

## Scene layout

- `Player/MonowheelVisuals/Tire` — row 1 of `Tires.png`, 11 cycling frames.
- `Player/MonowheelVisuals/Hubcap` — row 0 of `Tires.png`, first 7 frames.
- `Player/MonowheelVisuals/BodyPivot/Body` — robot body, drawn on top of the upper tire and hubcap.
- `Scripts/Player/monowheel_visuals.gd` — visual animation only; the existing `player.gd` owns movement/collisions and reports actual travel and landing speed.

The wheel/hubcap animation phase advances with actual horizontal distance; reversing direction reverses the animation. The body leans toward movement and mirrors when moving left. Airborne, the wheel extends down approximately 6 px (25% of its visible 23px diameter); landing briefly compresses it into the chassis and adds a small body dip. Tweak exported parameters on `MonowheelVisuals` in the Inspector.

## Playtest checklist

- [ ] Open player.tscn: body, tire and hubcap all visible; upper wheel appears behind chassis.
- [ ] Walk right then left: sprite mirrors, body leans, wheel/hubcap animate in reverse; movement audio still follows rolling.
- [ ] Run into a wall: wheel animation stops with actual travel.
- [ ] Jump: wheel extends down; body can still shift weight, and collision remains unchanged.
- [ ] Land lightly/heavily: suspension briefly compresses and recovers.
- [ ] Pick up/drop blocks and activate pressure plates: no collision or weight-transfer regressions.
- [ ] Reset room and switch levels: visuals return to their default state.

No Godot runtime test was possible in the integration environment; test locally before merging.
