
extends CharacterBody2D

# =============================================================================
# PLAYER CONTROLLER
# =============================================================================
# Handles 2D platforming movement and weight-dependent jumping.
#
# Responsibilities:
#   - Horizontal player movement.
#   - Gravity and grounded jumping.
#   - Adjust jump strength based on player weight.
#   - Collision-aware movement.
#
# Dependencies:
#   - Input actions: move_left, move_right, jump.
#   - CollisionShape2D child.
#   - WeightComponent child.
# =============================================================================


# -----------------------------------------------------------------------------
# MOVEMENT CONFIGURATION
# -----------------------------------------------------------------------------
@export var move_speed: float = 180.0 ## Horizontal speed in pixels per second.
@export var gravity: float = 900.0 ## Downward acceleration.

@export_group("Jump Strength")
@export var light_jump_speed: float = 420.0 ## Jump velocity at weight 1.
@export var normal_jump_speed: float = 350.0 ## Jump velocity at weight 2.
@export var heavy_jump_speed: float = 270.0 ## Jump velocity at weight 3.


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var weight_component: WeightComponent = $WeightComponent


# -----------------------------------------------------------------------------
# PHYSICS
# -----------------------------------------------------------------------------
func _physics_process(delta: float) -> void:

    if not is_on_floor():
        velocity.y += gravity * delta

    if is_on_floor() and Input.is_action_just_pressed("jump"):
        # Negative Y is upward in Godot.
        velocity.y = -_get_jump_speed()

    var direction: float = Input.get_axis(
        "move_left",
        "move_right"
    )

    velocity.x = direction * move_speed

    move_and_slide()


# -----------------------------------------------------------------------------
# WEIGHT-DEPENDENT MOVEMENT
# -----------------------------------------------------------------------------

## Returns the jump velocity corresponding to the player's weight.
## Weight is sampled when jumping, so midair transfers do not
## retroactively change the jump's initial velocity.
func _get_jump_speed() -> float:
    match weight_component.current_weight:
        1:
            return light_jump_speed
        2:
            return normal_jump_speed
        3:
            return heavy_jump_speed

    return normal_jump_speed
