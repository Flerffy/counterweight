# Door and button visual alignment fix

- Door.png has visible pixels only in x=13..50 and y=4..70. `DoorVisible.tres` crops the alpha padding; `weighted_door.gd` fits the cropped artwork to the existing collider so puzzle geometry remains unchanged. This applies to both door sizes.
- Tileset.png has two distinct button states: released at x=64..79, y=46..47 and depressed at x=80..95, y=46..47. The former is on row 46; the latter appears on row 47.
- `PressurePlate` changes the button texture based on actual weight/pressure. Toggle and timed buttons return to released artwork after the player steps off, even when the connected door remains latched open.
- No terrain or level layouts are changed.

## In-engine tests
1. In level 6 stand on and leave the toggle button: texture should depress and release, while the door remains open.
2. In level 7 confirm timed buttons visibly return to released artwork after stepping off.
3. In level 11 test the weighted button with insufficient and sufficient weight.
4. Inspect normal and tall door colliders with Debug > Visible Collision Shapes; the visible door outline should match the rectangle.
5. Confirm door open/close still removes and restores collision.

This package received static validation only; Godot is not available in the build environment.
