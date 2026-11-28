
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
@onready var monowheel_visuals: MonowheelVisuals = $MonowheelVisuals

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
    var was_grounded: bool = is_on_floor()

    if not was_grounded:
        velocity.y += gravity * delta

    if was_grounded and Input.is_action_just_pressed("jump"):
        # Negative Y is upward in Godot.
        velocity.y = -_get_jump_speed()

    var direction: float = Input.get_axis("move_left", "move_right")
    velocity.x = direction * move_speed

    # Record the speed before the collision response, so the suspension
    # can react to the force of a landing rather than the stopped velocity.
    var impact_speed: float = velocity.y
    var previous_x: float = global_position.x
    move_and_slide()

    var grounded: bool = is_on_floor()
    var just_landed: bool = not was_grounded and grounded and impact_speed > 0.0
    var travelled_x: float = global_position.x - previous_x

    monowheel_visuals.update_motion(
        delta, travelled_x, direction, grounded, just_landed, impact_speed
    )

    # Wheel audio runs only while physically rolling on the ground.
    var should_roll: bool = grounded and absf(travelled_x) > 0.01
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
