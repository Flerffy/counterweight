
extends Node2D

# =============================================================================
# TEST ROOM
# =============================================================================
# Configures the test environment and shared room systems.
#
# Responsibilities:
#   - Connect player interaction to the room's BalanceController.
#   - Reset the room to its initial state.
#
# Dependencies:
#   - PlayerInteraction
#   - BalanceController
#   - Input action: reset_room.
# =============================================================================


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var player_interaction: PlayerInteraction = $Player/PlayerInteraction
@onready var balance_controller: BalanceController = $BalanceController


# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------
func _ready() -> void:
    player_interaction.balance_controller = balance_controller


# -----------------------------------------------------------------------------
# ROOM RESET
# -----------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("reset_room") and not event.is_echo():
        reset_room()


## Restores the room to its saved state.
## Reloading also restores all scene-owned objects and their properties.
func reset_room() -> void:
    # Defer reloading until the current input processing finishes.
    get_tree().call_deferred("reload_current_scene")
