extends Area2D
class_name LevelHazard

# Reset the scene when the player contacts spikes or falls out of bounds.
var triggered: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if triggered or not (body is CharacterBody2D):
        return
    if not body.has_node("WeightComponent"):
        return
    triggered = true
    get_tree().call_deferred("reload_current_scene")
