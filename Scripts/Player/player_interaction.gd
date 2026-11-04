
extends Node
class_name PlayerInteraction

# =============================================================================
# PLAYER INTERACTION
# =============================================================================
# Handles weight transfers involving objects touching the player.
#
# Responsibilities:
#   - Track weighted objects currently in contact.
#   - Determine transfer participants.
#   - Request transfers through the BalanceController.
#
# Transfer rules:
#   0 targets: No transfer.
#   1 target:  Player exchanges weight with the object.
#   2 targets: Objects exchange weight with each other.
#   3+ targets: No transfer until target selection is implemented.
#
# Dependencies:
#   - WeightComponent
#   - WeightContactDetector
#   - BalanceController
# =============================================================================


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var player_weight: WeightComponent = $"../WeightComponent"
@onready var contact_detector: WeightContactDetector = $"../ContactDetector"

var balance_controller: BalanceController
var available_targets: Array[WeightComponent] = []


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    contact_detector.target_entered.connect(_on_target_entered)
    contact_detector.target_exited.connect(_on_target_exited)


# -----------------------------------------------------------------------------
# TARGET MANAGEMENT
# -----------------------------------------------------------------------------
func _on_target_entered(component: WeightComponent) -> void:
    if not available_targets.has(component):
        available_targets.append(component)


func _on_target_exited(component: WeightComponent) -> void:
    available_targets.erase(component)


# -----------------------------------------------------------------------------
# INPUT HANDLING
# -----------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
    if event.is_echo():
        return

    if event.is_action_pressed("give_weight"):
        _attempt_transfer(true)

    elif event.is_action_pressed("take_weight"):
        _attempt_transfer(false)


# -----------------------------------------------------------------------------
# TRANSFER LOGIC
# -----------------------------------------------------------------------------

## Selects the appropriate participants based on contact count.
func _attempt_transfer(forward: bool) -> void:
    if balance_controller == null:
        push_warning("BalanceController has not been assigned.")
        return

    var targets: Array[WeightComponent] = _get_valid_targets()

    var source: WeightComponent
    var receiver: WeightComponent

    match targets.size():
        0:
            return

        1:
            # The player participates when touching one weighted object.
            source = player_weight if forward else targets[0]
            receiver = targets[0] if forward else player_weight

        2:
            # With two targets, weight travels directly between them.
            # The player's own weight is not involved.
            var first: WeightComponent = targets[0]
            var second: WeightComponent = targets[1]

            if _is_after(first, second):
                first = targets[1]
                second = targets[0]

            source = first if forward else second
            receiver = second if forward else first

        _:
            # Avoid choosing arbitrary objects in crowded spaces.
            print("Multiple targets: selection required.")
            return

    if balance_controller.transfer_weight(source, receiver):
        print(
            "Transfer: ", source.get_parent().name,
            " -> ", receiver.get_parent().name,
            " | Weights: ", source.current_weight,
            ", ", receiver.current_weight
        )
    else:
        print("Weight transfer rejected.")


# -----------------------------------------------------------------------------
# TARGET VALIDATION
# -----------------------------------------------------------------------------

## Returns currently valid targets, excluding freed components.
func _get_valid_targets() -> Array[WeightComponent]:
    var targets: Array[WeightComponent] = []

    for component: WeightComponent in available_targets:
        if not is_instance_valid(component):
            continue

        if not component.get_parent() is Node2D:
            continue

        targets.append(component)

    return targets


## Determines spatial order for two contacted objects.
## Leftmost comes first; vertical position breaks horizontal ties.
func _is_after(a: WeightComponent, b: WeightComponent) -> bool:
    var a_body: Node2D = a.get_parent() as Node2D
    var b_body: Node2D = b.get_parent() as Node2D

    if is_equal_approx(
        a_body.global_position.x,
        b_body.global_position.x
    ):
        return a_body.global_position.y > b_body.global_position.y

    return a_body.global_position.x > b_body.global_position.x
