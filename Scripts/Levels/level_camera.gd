extends Camera2D
class_name LevelCamera

# Tracks the player horizontally while keeping the 18-tile-high room in view.
# The room's Camera2D limits clamp movement at the beginning and end.
@export var vertical_offset: float = -240.0
@onready var target: Node2D = get_parent().get_node("Player") as Node2D

func _process(_delta: float) -> void:
    if is_instance_valid(target):
        global_position = target.global_position + Vector2(0.0, vertical_offset)
