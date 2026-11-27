extends Control

# Progress is saved as soon as the final exit is touched by LevelRoom.
func _ready() -> void:
    var column: VBoxContainer = $CenterContainer/VBoxContainer
    for item: String in ["MAIN MENU", "LEVEL SELECT", "PLAY AGAIN"]:
        var b: Button = Button.new()
        b.text = item
        b.custom_minimum_size = Vector2(300, 45)
        b.pressed.connect(_on_navigation.bind(item))
        column.add_child(b)
    $CenterContainer/VBoxContainer/Restart.text = "Your progress has been saved."

func _on_navigation(action: String) -> void:
    match action:
        "MAIN MENU":
            get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
        "LEVEL SELECT":
            # Open the menu with level select visible using a simple shared flag.
            GameState.open_level_select = true
            get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
        "PLAY AGAIN":
            get_tree().change_scene_to_file(GameState.level_path(1))

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
