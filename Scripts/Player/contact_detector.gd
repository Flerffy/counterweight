
extends Area2D
class_name WeightContactDetector

# =============================================================================
# WEIGHT CONTACT DETECTOR
# =============================================================================
# Detects weighted objects touching the player's interaction area.
#
# Responsibilities:
#   - Identify physics bodies containing a WeightComponent.
#   - Notify other systems when contact begins or ends.
#   - Ignore objects that cannot participate in weight transfers.
#
# Dependencies:
#   - WeightComponent
#   - Area2D collision mask configured for weighted objects.
#
# This component only detects targets.
# It does not perform weight transfers.
# =============================================================================


# -----------------------------------------------------------------------------
# SIGNALS
# -----------------------------------------------------------------------------
signal target_entered(component: WeightComponent)
signal target_exited(component: WeightComponent)


# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
@export var debug_logging: bool = true ## Print detected contacts to the Output panel.


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


# -----------------------------------------------------------------------------
# CONTACT DETECTION
# -----------------------------------------------------------------------------
## Handles the body entering the contact area.
## Emits the target_entered signal if the body contains a WeightComponent.
func _on_body_entered(body: Node2D) -> void:
    var component: WeightComponent = body.get_node_or_null(
        "WeightComponent"
    ) as WeightComponent

    if component == null:
        return

    target_entered.emit(component)

    if debug_logging:
        print("Weight target detected: ", body.name)

## Handles the body exiting the contact area.
## Emits the target_exited signal if the body contains a WeightComponent.
func _on_body_exited(body: Node2D) -> void:
    var component: WeightComponent = body.get_node_or_null(
        "WeightComponent"
    ) as WeightComponent

    if component == null:
        return

    target_exited.emit(component)

    if debug_logging:
        print("Weight target exited: ", body.name)
