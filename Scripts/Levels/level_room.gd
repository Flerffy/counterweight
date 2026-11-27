extends Node2D
class_name LevelRoom

# =============================================================================
# LEVEL ROOM
# =============================================================================
# Coordinates player weight transfer, HUD, pause and checkpoint-style autosave.
# =============================================================================

const PAUSE_OVERLAY: PackedScene = preload("res://Scenes/UI/pause_overlay.tscn")

@export_range(1, 15) var level_number: int = 1
@export var level_title: String = "Puzzle"
@export_multiline var hint: String = ""
@export_file("*.tscn") var next_scene: String = ""

@onready var player_interaction: PlayerInteraction = $Player/PlayerInteraction
@onready var balance_controller: BalanceController = $BalanceController
@onready var exit: LevelExit = $Exit
@onready var hud: GameHUD = $HUD/GameHUD
var pause_layer: CanvasLayer

func _ready() -> void:
    player_interaction.balance_controller = balance_controller
    exit.reached.connect(_on_exit_reached)
    hud.setup(level_number, level_title, hint)
    GameState.enter_level(level_number)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_echo():
        return
    if event.is_action_pressed("reset_room"):
        get_viewport().set_input_as_handled()
        get_tree().call_deferred("reload_current_scene")
    elif event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        if not is_instance_valid(pause_layer):
            pause_layer = PAUSE_OVERLAY.instantiate() as CanvasLayer
            add_child(pause_layer)
            get_tree().paused = true

func _on_exit_reached() -> void:
    # Saved immediately upon reaching the exit, before the next scene loads.
    GameState.complete_level(level_number)
    var target: String = next_scene
    if target.is_empty():
        target = "res://Scenes/Levels/victory.tscn"
    get_tree().call_deferred("change_scene_to_file", target)
