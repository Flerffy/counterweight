extends Control

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("jump") or event.is_action_pressed("carry"):
        get_tree().call_deferred("change_scene_to_file", "res://Scenes/Levels/level_01.tscn")
