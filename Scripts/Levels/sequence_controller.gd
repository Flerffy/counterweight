extends Node2D
class_name SequenceController

# =============================================================================
# SEQUENCE CONTROLLER
# =============================================================================
# Memory minigame using the same ordinary PuzzleButtons as other rooms.
# Each sequence is generated once when the room loads; errors replay it.
# =============================================================================

signal state_changed(active: bool)

@export var button_group: StringName = &"memory_09"
@export_range(2, 8) var sequence_length: int = 4
@export_range(0.2, 1.0) var flash_seconds: float = 0.55

@onready var status_label: Label = $StatusLabel
var buttons: Array[PuzzleButton] = []
var sequence: Array[int] = []
var progress: int = 0
var accepting: bool = false
var solved: bool = false
var playback_version: int = 0

func _ready() -> void:
    for candidate: Node in get_tree().get_nodes_in_group(button_group):
        if candidate is PuzzleButton:
            buttons.append(candidate as PuzzleButton)
    buttons.sort_custom(func(a: PuzzleButton, b: PuzzleButton) -> bool:
        return a.global_position.x < b.global_position.x
    )
    for index: int in range(buttons.size()):
        buttons[index].pressed.connect(_on_pressed.bind(index))
    if buttons.size() != 4:
        status_label.text = "Sequence setup needs four buttons"
        push_warning("Memory controller %s needs 4 tagged buttons, found %d" % [name, buttons.size()])
        return
    for i: int in range(sequence_length):
        sequence.append(randi_range(0, buttons.size() - 1))
    call_deferred("_play_sequence")

func _play_sequence() -> void:
    if solved:
        return
    playback_version += 1
    var version: int = playback_version
    accepting = false
    progress = 0
    status_label.text = "WATCH THE BUTTONS"
    await get_tree().create_timer(0.8).timeout
    for button_index: int in sequence:
        if version != playback_version or not is_inside_tree():
            return
        buttons[button_index].set_flash(true)
        await get_tree().create_timer(flash_seconds).timeout
        if version != playback_version or not is_inside_tree():
            return
        buttons[button_index].set_flash(false)
        await get_tree().create_timer(0.22).timeout
    if version != playback_version or not is_inside_tree():
        return
    accepting = true
    status_label.text = "REPEAT: 0 / %d" % sequence_length

func _on_pressed(index: int) -> void:
    if not accepting or solved:
        return
    if index != sequence[progress]:
        accepting = false
        status_label.text = "WRONG ORDER · WATCH AGAIN"
        _replay_after_error()
        return
    progress += 1
    status_label.text = "REPEAT: %d / %d" % [progress, sequence_length]
    if progress >= sequence.size():
        solved = true
        accepting = false
        status_label.text = "SEQUENCE COMPLETE"
        for button: PuzzleButton in buttons:
            button.set_flash(true)
        state_changed.emit(true)

func _replay_after_error() -> void:
    await get_tree().create_timer(0.9).timeout
    if not solved and is_inside_tree():
        _play_sequence()
