
extends StaticBody2D
class_name WeightedDoor

# =============================================================================
# WEIGHTED DOOR
# =============================================================================
# Opens or closes in response to external puzzle mechanisms.
#
# Responsibilities:
#   - Track whether the door is open or closed.
#   - Update door visibility.
#   - Enable or disable physical collision.
#
# Dependencies:
#   - Polygon2D child for visual representation.
#   - CollisionShape2D child for physical collision.
#
# The door does not directly depend on a pressure plate.
# Other systems control it through set_open().
# =============================================================================


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var door_visual: Polygon2D = $Polygon2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


# -----------------------------------------------------------------------------
# STATE
# -----------------------------------------------------------------------------
@onready var art: Sprite2D = get_node_or_null("DoorArt") as Sprite2D
var is_open: bool = false


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    if art != null and art.texture != null and collision_shape.shape is RectangleShape2D:
        # DoorVisible.tres crops the transparent border from the source PNG.
        # Fit that visible artwork exactly to the collision rectangle for
        # both normal and tall door scene variants.
        var size: Vector2 = (collision_shape.shape as RectangleShape2D).size
        var art_size: Vector2 = art.texture.get_size()
        if art_size.x > 0.0 and art_size.y > 0.0:
            art.scale = size / art_size
            art.position = collision_shape.position
    _update_door()


# -----------------------------------------------------------------------------
# DOOR CONTROL
# -----------------------------------------------------------------------------

## Opens or closes the door.
## Called by puzzle mechanisms when their activation state changes.
func set_open(open: bool) -> void:
    is_open = open
    _update_door()


# -----------------------------------------------------------------------------
# STATE UPDATES
# -----------------------------------------------------------------------------

## Synchronizes visual appearance and physical collision.
func _update_door() -> void:
    door_visual.visible = false if art != null else not is_open
    if art != null:
        art.visible = not is_open

    # Defer physics changes to avoid modifying collision shapes
    # while Godot is processing physics queries.
    collision_shape.set_deferred("disabled", is_open)
