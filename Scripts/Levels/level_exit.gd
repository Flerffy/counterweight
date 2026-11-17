extends Area2D
class_name LevelExit

# Emits when the player touches the designated level exit.
signal reached
var claimed: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if claimed or not (body is CharacterBody2D):
        return
    if not body.has_node("WeightComponent"):
        return
    claimed = true
    reached.emit()
