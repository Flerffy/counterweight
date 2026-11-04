
extends Node
class_name WeightComponent

# =============================================================================
# WEIGHT COMPONENT
# =============================================================================
# Stores and manages an object's weight.
#
# Responsibilities:
#   - Track weight using three discrete levels.
#   - Enforce minimum and maximum weight limits.
#   - Notify other systems when weight changes.
#
# Weight levels:
#   1 = Light
#   2 = Normal
#   3 = Heavy
#
# Weight conservation is handled by the transfer controller,
# not by this component.
# =============================================================================


# -----------------------------------------------------------------------------
# SIGNALS
# -----------------------------------------------------------------------------
signal weight_changed(old_weight: int, new_weight: int)


# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
const MIN_WEIGHT: int = 1 ## Minimum allowed weight level. (HARD LIMIT do NOT change this below 1)
const MAX_WEIGHT: int = 3 ## Maximum allowed weight level. (subject to change as needed)

@export_range(1, 3) var initial_weight: int = 2 ## Starting weight configured in the Inspector.

var current_weight: int = 2 ## Runtime weight. Change through set_weight().


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    current_weight = initial_weight


# -----------------------------------------------------------------------------
# WEIGHT MANAGEMENT
# -----------------------------------------------------------------------------


func can_set_weight(value: int) -> bool: ## Returns whether a requested weight is within the allowed range.
    return value >= MIN_WEIGHT and value <= MAX_WEIGHT


## Updates the weight and notifies listeners.
## HEADS UP: An unchanged weight IS considered a successful operation.
func set_weight(value: int) -> bool:
    if not can_set_weight(value):
        return false

    if value == current_weight:
        return true

    var old_weight: int = current_weight

    current_weight = value
    weight_changed.emit(old_weight, current_weight)

    return true
