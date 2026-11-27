extends Sprite2D

# Uses the two 16×16 supplied block images without altering 32×32 physics.
const ORANGE: Texture2D = preload("res://Assets/Art/BlockOrange.tres")
const TEAL: Texture2D = preload("res://Assets/Art/BlockTeal.tres")
@onready var weight: WeightComponent = $"../WeightComponent"

func _ready() -> void:
    weight.weight_changed.connect(_on_weight_changed)
    _on_weight_changed(0, weight.current_weight)

func _on_weight_changed(_old: int, value: int) -> void:
    texture = TEAL if value == 1 else ORANGE
    modulate = Color(1.0, 0.82, 0.72) if value == 3 else Color.WHITE
