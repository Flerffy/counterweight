
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
@onready var player_sprite: Sprite2D = $Sprite2D

const WHEEL_SOUND: AudioStreamWAV = preload("res://Audio/SFX/Wheel_sound.wav")
var wheel_player: AudioStreamPlayer

func _ready() -> void:
    # Duplicate the WAV before modifying its loop setting: the imported asset
    # stays unchanged and each player instance owns its playback resource.
    var wheel_loop: AudioStreamWAV = WHEEL_SOUND.duplicate() as AudioStreamWAV
    wheel_loop.loop_mode = AudioStreamWAV.LOOP_FORWARD

    wheel_player = AudioStreamPlayer.new()
    wheel_player.name = "WheelAudio"
    wheel_player.bus = &"SFX"
    wheel_player.volume_db = -6.0
    wheel_player.stream = wheel_loop
    add_child(wheel_player)


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

    if direction > 0.0:
        player_sprite.flip_h = false
    elif direction < 0.0:
        player_sprite.flip_h = true
    # Keep the last facing direction when idle.

    move_and_slide()

    # Wheel audio runs only while moving on the ground, never in midair.
    var should_roll: bool = not is_zero_approx(direction) and is_on_floor()
    if should_roll and not wheel_player.playing:
        wheel_player.play()
    elif not should_roll and wheel_player.playing:
        wheel_player.stop()


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
