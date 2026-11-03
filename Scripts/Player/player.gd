
extends CharacterBody2D

# =============================================================================
# PLAYER CONTROLLER
# =============================================================================
# Handles basic 2D platforming movement.
#
# Responsibilities:
#   - Horizontal movement using player input.
#   - Gravity while airborne.
#   - Jumping while grounded.
#   - Collision-aware movement.
#
# Dependencies:
#   - Input actions: move_left, move_right, jump.
#   - A CollisionShape2D child for physical collision.
#
# This controller currently uses fixed movement values.
# Weight-dependent movement will be integrated later.
# =============================================================================


# -----------------------------------------------------------------------------
# MOVEMENT CONFIGURATION
# -----------------------------------------------------------------------------
@export var move_speed: float = 180.0 ## Horizontal movement speed in pixels per second

@export var jump_speed: float = 350.0 ## Initial upward velocity applied when jumping.

@export var gravity: float = 900.0 ## Downward acceleration in pixels per second squared.


# -----------------------------------------------------------------------------
# PHYSICS
# -----------------------------------------------------------------------------
func _physics_process(delta: float) -> void:

    if not is_on_floor(): ## Apply gravity only while airborne.
        velocity.y += gravity * delta

    if is_on_floor() and Input.is_action_just_pressed("jump"): ## Simple floor-check
        velocity.y = -jump_speed ## Isn't it werid that up is NEGATIVE Y in godot? :P

    var direction: float = Input.get_axis( ## Get horizontal input axis from -1 to 1.
        "move_left",
        "move_right"
    )

    velocity.x = direction * move_speed

    move_and_slide() ## Apply velocity while resolving collisions against the world.
