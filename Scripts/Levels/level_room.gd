extends Node2D
class_name LevelRoom

# =============================================================================
# LEVEL ROOM
# =============================================================================
# Connects the existing weight-transfer systems and linear level progression.
# R reloads the current level; the exit opens the next scene.
# =============================================================================

@export_range(1, 15) var level_number: int = 1
@export var level_title: String = "Puzzle"
@export_multiline var hint: String = ""
@export_file("*.tscn") var next_scene: String = ""

@onready var player_interaction: PlayerInteraction = $Player/PlayerInteraction
@onready var balance_controller: BalanceController = $BalanceController
@onready var exit: LevelExit = $Exit
@onready var hud_title: Label = $HUD/Header/LevelTitle
@onready var hud_hint: Label = $HUD/Header/Hint

func _ready() -> void:
    player_interaction.balance_controller = balance_controller
    exit.reached.connect(_on_exit_reached)
    hud_title.text = "%02d / 15  ·  %s" % [level_number, level_title]
    hud_hint.text = hint

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("reset_room") and not event.is_echo():
        get_tree().call_deferred("reload_current_scene")

func _on_exit_reached() -> void:
    var target: String = next_scene
    if target.is_empty():
        target = "res://Scenes/Levels/victory.tscn"
    get_tree().call_deferred("change_scene_to_file", target)
