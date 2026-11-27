extends Node2D
class_name PuzzleButton

# =============================================================================
# PUZZLE BUTTON
# =============================================================================
# Reuses PressurePlate's stacked/carried-weight detection.
# One scene supports toggled, timed, and momentary activation.
# =============================================================================

signal state_changed(active: bool)
signal pressed

enum Mode { TOGGLE, TIMED, MOMENTARY }

@export var mode: Mode = Mode.MOMENTARY
@export_range(1, 12) var required_weight: int = 1
@export_range(0.5, 20.0, 0.25) var active_duration: float = 4.0

@onready var plate: PressurePlate = $Plate
@onready var mode_label: Label = $ModeLabel
@onready var countdown: Timer = $Countdown

var is_active: bool = false
var is_flashing: bool = false

func _ready() -> void:
    plate.required_weight = required_weight
    plate.activation_changed.connect(_on_plate_changed)
    countdown.one_shot = true
    countdown.timeout.connect(_on_timeout)
    _refresh_visual()

func _process(_delta: float) -> void:
    if mode == Mode.TIMED and is_active:
        mode_label.text = "%.1f" % countdown.time_left

func _on_plate_changed(is_pressed: bool) -> void:
    # Rising edges are used for toggle, timed, and memory patterns.
    if is_pressed:
        pressed.emit()
        match mode:
            Mode.TOGGLE:
                _set_active(not is_active)
            Mode.TIMED:
                _set_active(true)
                countdown.start(active_duration)
            Mode.MOMENTARY:
                _set_active(true)
    elif mode == Mode.MOMENTARY:
        _set_active(false)
    _refresh_visual()

func _on_timeout() -> void:
    _set_active(false)

func _set_active(value: bool) -> void:
    if is_active == value:
        return
    is_active = value
    state_changed.emit(is_active)
    _refresh_visual()

## The sequence controller uses this only for playback feedback.
func set_flash(enabled: bool) -> void:
    is_flashing = enabled
    _refresh_visual()

func _refresh_visual() -> void:
    if plate.button_sprite != null:
        # Artwork shows contact state; only sequence playback flashes it.
        plate.button_sprite.modulate = Color(1.5, 1.45, 0.85) if is_flashing else Color.WHITE
    if mode != Mode.TIMED or not is_active:
        match mode:
            Mode.TOGGLE:
                mode_label.text = "T"
            Mode.TIMED:
                mode_label.text = "S"
            Mode.MOMENTARY:
                mode_label.text = "H"
