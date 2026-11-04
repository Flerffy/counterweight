
extends Node
class_name BalanceController

# =============================================================================
# BALANCE CONTROLLER
# =============================================================================
# Manages weight transfers between two WeightComponents.
#
# Responsibilities:
#   - Validate weight transfer requests.
#   - Enforce weight conservation.
#   - Prevent transfers beyond component limits.
#   - Notify listeners when a transfer succeeds.
#
# Dependencies:
#   - WeightComponent
#
# Transfers are currently limited to one weight unit.
# Player input and target selection are handled separately.
# =============================================================================


# -----------------------------------------------------------------------------
# SIGNALS
# -----------------------------------------------------------------------------
signal transfer_completed(
    source: WeightComponent,
    target: WeightComponent
)


# -----------------------------------------------------------------------------
# WEIGHT TRANSFER
# -----------------------------------------------------------------------------

## Transfers one weight unit from source to target.
func transfer_weight(
    source: WeightComponent,
    target: WeightComponent
) -> bool:

    # Both components MUST exist and refer to different objects.
    if source == null or target == null:
        return false

    if source == target:
        return false

    var new_source_weight: int = source.current_weight - 1
    var new_target_weight: int = target.current_weight + 1

    # Validate both changes before modifying either component.
    # This prevents invalid requests from partially changing weight.
    if not source.can_set_weight(new_source_weight):
        return false

    if not target.can_set_weight(new_target_weight):
        return false

    source.set_weight(new_source_weight)
    target.set_weight(new_target_weight)

    transfer_completed.emit(source, target)

    return true
