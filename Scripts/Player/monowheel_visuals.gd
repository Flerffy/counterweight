extends Node2D
class_name MonowheelVisuals

# =============================================================================
# MONOWHEEL VISUALS
# =============================================================================
# Visual-only animation of the robot body, tire, hubcap, and suspension.
# Player physics and collision are entirely managed by player.gd.
#
# Sprite sheet layout (Tires.png, 11 columns x 2 rows of 32px frames):
#   Row 0: 7 hubcap frames (columns 0–6)
#   Row 1: 11 tire frames (columns 0–10)
# =============================================================================

const TIRE_FRAMES: int = 11
const HUBCAP_FRAMES: int = 7
const BASE_WHEEL_Y: float = -14.0
const BASE_PIVOT_Y: float = -16.0

@export_group("Wheel")
@export_range(5.0, 24.0, 0.5) var tire_radius: float = 11.5 ## Approximate visible tire radius, in pixels.

@export_group("Body Lean")
@export_range(0.0, 15.0, 0.5) var max_lean_degrees: float = 7.0 ## Lean while moving left or right.
@export_range(1.0, 30.0, 1.0) var lean_response: float = 11.0 ## How quickly the body tilts/recovers.

@export_group("Suspension")
@export_range(0.0, 12.0, 0.5) var air_extension: float = 6.0 ## About 25% of the tire's visible diameter.
@export_range(0.0, 12.0, 0.5) var landing_compression: float = 5.0 ## Maximum landing recoil, in pixels.
@export_range(1.0, 40.0, 1.0) var suspension_response: float = 24.0 ## Follow speed for the tire and hubcap.
@export_range(1.0, 40.0, 1.0) var recoil_recovery: float = 12.0 ## How quickly landing compression fades.

@onready var tire: Sprite2D = $Tire
@onready var hubcap: Sprite2D = $Hubcap
@onready var body_pivot: Node2D = $BodyPivot
@onready var body: Sprite2D = $BodyPivot/Body

var _travel_distance: float = 0.0
var _wheel_offset: float = 0.0
var _recoil: float = 0.0


## Called by the player once per physics frame, after move_and_slide().
## Animation follows actual displacement, not just input, so a blocked wheel
## does not keep spinning into a wall.
func update_motion(
	delta: float,
	travelled_x: float,
	direction: float,
	grounded: bool,
	just_landed: bool,
	impact_speed: float
) -> void:
	# One full animation cycle corresponds to one wheel revolution.
	_travel_distance += travelled_x
	var circumference: float = TAU * tire_radius
	var turns: float = _travel_distance / circumference
	var tire_frame: int = posmod(int(floor(turns * TIRE_FRAMES)), TIRE_FRAMES)
	var hub_frame: int = posmod(int(floor(turns * HUBCAP_FRAMES)), HUBCAP_FRAMES)
	tire.frame_coords = Vector2i(tire_frame, 1)
	hubcap.frame_coords = Vector2i(hub_frame, 0)

	# Face the last direction of travel, including when stopped.
	if not is_zero_approx(direction):
		body.flip_h = direction < 0.0

	# A clockwise rotation leans right in Godot's downward-positive Y axis.
	var lean_target: float = deg_to_rad(max_lean_degrees) * direction
	body_pivot.rotation = lerp_angle(
		body_pivot.rotation, lean_target, minf(1.0, delta * lean_response)
	)

	# Extend the tire below the chassis in the air. On landing, briefly
	# compress it up into the chassis, then let it return to its rest pose.
	if just_landed:
		_recoil = minf(landing_compression, maxf(2.0, impact_speed * 0.012))
	var target_offset: float = air_extension if not grounded else -_recoil
	_wheel_offset = lerpf(
		_wheel_offset, target_offset, minf(1.0, delta * suspension_response)
	)
	tire.position.y = BASE_WHEEL_Y + _wheel_offset
	hubcap.position.y = BASE_WHEEL_Y + _wheel_offset

	# A little body drop makes a heavy landing visually legible.
	body_pivot.position.y = BASE_PIVOT_Y + minf(_recoil * 0.35, 2.0)
	_recoil = move_toward(_recoil, 0.0, delta * recoil_recovery)
