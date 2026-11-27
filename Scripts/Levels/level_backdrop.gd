extends Node2D
class_name LevelBackdrop

# Repeats the supplied pixel-art factory walls behind the full level.
const BACKGROUND: Texture2D = preload("res://Assets/Art/BG.png")
@export var room_width: int = 1024
@export var room_height: int = 576

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0.0, 0.0, float(room_width), float(room_height)), Color("171318"))
    for y: int in range(0, room_height, 96):
        for x: int in range(0, room_width, 256):
            draw_texture(BACKGROUND, Vector2(x, y))
