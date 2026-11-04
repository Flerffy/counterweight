extends Node2D

# =============================================================================
# TEST ROOM
# =============================================================================
# Configures the test environment and connects shared room systems.
#
# Responsibilities:
#   - Provide the room's BalanceController to player interactions.
# =============================================================================


@onready var player_interaction: PlayerInteraction = $Player/PlayerInteraction
@onready var balance_controller: BalanceController = $BalanceController


func _ready() -> void:
    player_interaction.balance_controller = balance_controller
