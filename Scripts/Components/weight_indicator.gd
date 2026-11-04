
extends Label
class_name WeightIndicator

# =============================================================================
# WEIGHT INDICATOR
# =============================================================================
# Displays the current weight of an object.
#
# Responsibilities:
#   - Read weight from the parent object's WeightComponent.
#   - Update the display whenever weight changes.
#
# Dependencies:
#   - WeightComponent as a sibling node.
#
# This is a temporary debug display.
# It can be replaced with final UI artwork later.
# =============================================================================


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var weight_component: WeightComponent = $"../WeightComponent"


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void: 
    weight_component.weight_changed.connect(_on_weight_changed)
    _update_display(weight_component.current_weight)


# -----------------------------------------------------------------------------
# DISPLAY
# -----------------------------------------------------------------------------
func _on_weight_changed(_old_weight: int, new_weight: int) -> void:
    _update_display(new_weight)


## Updates the displayed weight value.
func _update_display(weight: int) -> void:
    text = str(weight)
