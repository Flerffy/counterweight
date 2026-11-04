
extends Area2D
class_name PressurePlate

# =============================================================================
# PRESSURE PLATE
# =============================================================================
# Activates when the combined weight of overlapping objects
# reaches a configurable threshold.
#
# Responsibilities:
#   - Detect weighted bodies standing on the plate.
#   - Track their combined weight.
#   - React immediately to weight changes.
#   - Notify connected devices when activation changes.
#
# Dependencies:
#   - WeightComponent on detected physics bodies.
#   - Collision mask configured to detect weighted bodies.
#   - Polygon2D child for temporary visual feedback.
# =============================================================================


# -----------------------------------------------------------------------------
# SIGNALS
# -----------------------------------------------------------------------------
signal activation_changed(active: bool)


# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
@export_range(1, 12) var required_weight: int = 3 ## Minimum combined weight needed to activate.

@export var inactive_color: Color = Color.RED ## Color when inactive.
@export var active_color: Color = Color.GREEN ## Color when activated.


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var plate_visual: Polygon2D = $Polygon2D


# -----------------------------------------------------------------------------
# STATE
# -----------------------------------------------------------------------------
var is_active: bool = false

# Associates each detected physics body with its WeightComponent.
var tracked_bodies: Dictionary = {}


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    _update_visual()


# -----------------------------------------------------------------------------
# BODY DETECTION
# -----------------------------------------------------------------------------
func _on_body_entered(body: Node2D) -> void:
    var component: WeightComponent = body.get_node_or_null(
        "WeightComponent"
    ) as WeightComponent

    if component == null or tracked_bodies.has(body):
        return

    tracked_bodies[body] = component

    # Listen for transfers while the body remains on the plate.
    component.weight_changed.connect(_on_weight_changed)

    _recalculate_weight()


func _on_body_exited(body: Node2D) -> void:
    if not tracked_bodies.has(body):
        return

    var component: WeightComponent = tracked_bodies[body]
    tracked_bodies.erase(body)

    if is_instance_valid(component):
        if component.weight_changed.is_connected(_on_weight_changed):
            component.weight_changed.disconnect(_on_weight_changed)

    _recalculate_weight()


# -----------------------------------------------------------------------------
# WEIGHT MANAGEMENT
# -----------------------------------------------------------------------------
func _on_weight_changed(_old_weight: int, _new_weight: int) -> void:
    _recalculate_weight()


## Recalculates the combined weight and updates activation.
func _recalculate_weight() -> void:
    var total_weight: int = 0

    for body: Node2D in tracked_bodies:
        var component: WeightComponent = tracked_bodies[body]

        if is_instance_valid(component):
            total_weight += component.current_weight

    var should_activate: bool = total_weight >= required_weight

    # Only notify listeners when the activation state changes.
    if should_activate == is_active:
        return

    is_active = should_activate

    _update_visual()
    activation_changed.emit(is_active)

    print("Pressure Plate Active: ", is_active)


# -----------------------------------------------------------------------------
# VISUAL FEEDBACK
# -----------------------------------------------------------------------------
func _update_visual() -> void:
    plate_visual.color = active_color if is_active else inactive_color
