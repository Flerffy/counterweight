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

@export var enable_boundaries: bool = true ## Invisible walls at the camera's world edges.
@export var pit_reset_margin: float = 128.0 ## Pixels below camera bottom before a fall resets the room.

@onready var player_body: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var player_interaction: PlayerInteraction = $Player/PlayerInteraction
@onready var balance_controller: BalanceController = $BalanceController
@onready var exit: LevelExit = $Exit
@onready var hud: GameHUD = $HUD/GameHUD
var pause_layer: CanvasLayer
var fall_reset_triggered: bool = false

func _ready() -> void:
    player_interaction.balance_controller = balance_controller
    exit.reached.connect(_on_exit_reached)
    hud.setup(level_number, level_title, hint)
    GameState.enter_level(level_number)
    if enable_boundaries:
        _create_level_boundaries()
    SoundManager.start_room_ambience()

func _exit_tree() -> void:
    SoundManager.stop_room_ambience()

func _physics_process(_delta: float) -> void:
    # Reset automatically if a gap has no explicit hazard trigger.
    if not fall_reset_triggered and player_body.global_position.y > camera.limit_bottom + pit_reset_margin:
        fall_reset_triggered = true
        get_tree().call_deferred("reload_current_scene")

## Invisible side walls and ceiling keep the player and physics blocks in bounds.
## The bottom intentionally stays open so falling still resets the room.
func _create_level_boundaries() -> void:
    var left: float = float(camera.limit_left)
    var right: float = float(camera.limit_right)
    var top: float = float(camera.limit_top)
    var bottom: float = float(camera.limit_bottom)
    var world_width: float = right - left
    var world_height: float = bottom - top
    if world_width <= 0.0 or world_height <= 0.0:
        push_warning("Level has invalid camera bounds; barriers not created.")
        return

    var bounds: Node2D = Node2D.new()
    bounds.name = "LevelBounds"
    add_child(bounds)
    var wall_height: float = world_height + pit_reset_margin + 192.0
    var mid_y: float = (top + bottom + pit_reset_margin) * 0.5
    _add_boundary(bounds, "LeftWall", Vector2(left - 16.0, mid_y), Vector2(32.0, wall_height))
    _add_boundary(bounds, "RightWall", Vector2(right + 16.0, mid_y), Vector2(32.0, wall_height))
    _add_boundary(bounds, "Ceiling", Vector2((left + right) * 0.5, top - 96.0), Vector2(world_width + 64.0, 64.0))

func _add_boundary(parent: Node2D, boundary_name: String, at: Vector2, size: Vector2) -> void:
    var body: StaticBody2D = StaticBody2D.new()
    body.name = boundary_name
    body.position = at
    body.collision_layer = 1
    parent.add_child(body)

    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var rectangle: RectangleShape2D = RectangleShape2D.new()
    rectangle.size = size
    shape_node.shape = rectangle
    body.add_child(shape_node)

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
