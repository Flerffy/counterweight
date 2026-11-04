
extends Node
class_name CarryComponent

# =============================================================================
# CARRY COMPONENT
# =============================================================================
# Allows the player to pick up and carry weighted physics objects.
#
# Responsibilities:
#   - Find nearby carryable objects.
#   - Enforce the player's carrying capacity.
#   - Suspend object physics while carrying.
#   - Prevent objects from being dropped inside solid geometry.
#
# Dependencies:
#   - WeightContactDetector sibling.
#   - CarryPoint sibling (Marker2D).
#   - WeightComponent on carryable objects.
#   - Input action: carry.
#
# Carryable objects must belong to the "carryable" group.
# =============================================================================


# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
@export_range(1, 3) var max_carry_weight: int = 2 ## Maximum weight the player can carry.

@export var drop_horizontal_offset: float = 34.0 ## Distance to drop beside the player.
@export var drop_vertical_offset: float = -17.0 ## Vertical offset from the player's feet.


# -----------------------------------------------------------------------------
# NODE REFERENCES
# -----------------------------------------------------------------------------
@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var contact_detector: WeightContactDetector = $"../ContactDetector"
@onready var carry_point: Marker2D = $"../CarryPoint"


# -----------------------------------------------------------------------------
# STATE
# -----------------------------------------------------------------------------
var carried_body: RigidBody2D = null
var facing_direction: float = 1.0

var original_collision_layer: int = 0
var original_collision_mask: int = 0


# -----------------------------------------------------------------------------
# PHYSICS
# -----------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
    var direction: float = Input.get_axis("move_left", "move_right")

    if not is_zero_approx(direction):
        facing_direction = -1.0 if direction < 0.0 else 1.0

    # Keep carried objects attached to the marker in world space.
    if is_instance_valid(carried_body):
        carried_body.global_position = carry_point.global_position

    if Input.is_action_just_pressed("carry"):
        if carried_body == null:
            _attempt_pickup()
        else:
            _attempt_drop()


# -----------------------------------------------------------------------------
# PICKUP
# -----------------------------------------------------------------------------

## Picks up the nearest eligible object touching the player.
func _attempt_pickup() -> void:
    var nearest_body: RigidBody2D = null
    var nearest_distance: float = INF

    for body: Node2D in contact_detector.get_overlapping_bodies():
        if not body is RigidBody2D:
            continue

        if not body.is_in_group("carryable"):
            continue

        var weight: WeightComponent = body.get_node_or_null(
            "WeightComponent"
        ) as WeightComponent

        if weight == null:
            continue

        print(
            "Pickup check: ", body.name,
            " weight=", weight.current_weight,
            " capacity=", max_carry_weight
        )

        # Objects exceeding carrying capacity cannot be picked up.
        if weight.current_weight > max_carry_weight: 
            continue

        var distance: float = player.global_position.distance_squared_to(
            body.global_position
        )

        if distance < nearest_distance:
            nearest_distance = distance
            nearest_body = body as RigidBody2D

    if nearest_body == null:
        print("No eligible object within carrying capacity.")
        return

    carried_body = nearest_body

    # Preserve the body's collision configuration for dropping.
    original_collision_layer = carried_body.collision_layer
    original_collision_mask = carried_body.collision_mask

    # Suspend simulation and disable collisions during carrying.
    carried_body.linear_velocity = Vector2.ZERO
    carried_body.angular_velocity = 0.0
    carried_body.freeze = true
    carried_body.collision_layer = 0
    carried_body.collision_mask = 0

    carried_body.global_position = carry_point.global_position

    print("Picked up: ", carried_body.name)


# -----------------------------------------------------------------------------
# DROPPING
# -----------------------------------------------------------------------------

## Drops the carried object beside the player if space is available.
func _attempt_drop() -> void:
    var shape_node: CollisionShape2D = carried_body.get_node_or_null(
        "CollisionShape2D"
    ) as CollisionShape2D

    if shape_node == null or shape_node.shape == null:
        push_warning("Carried object has no collision shape.")
        return

    var drop_position: Vector2 = player.global_position + Vector2(
        facing_direction * drop_horizontal_offset,
        drop_vertical_offset
    )

    # Check the proposed drop location before restoring physics.
    # This prevents placing the block inside walls or other bodies.
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    query.shape = shape_node.shape
    query.transform = Transform2D(
        carried_body.global_rotation,
        drop_position
    ) * shape_node.transform
    query.collision_mask = original_collision_mask
    query.exclude = [carried_body.get_rid()]
    query.collide_with_areas = false
    query.margin = 0.0

    var collisions: Array[Dictionary] = player.get_world_2d().direct_space_state.intersect_shape(
        query,
        1
    )

    if not collisions.is_empty():
        print("Cannot drop: space is occupied.")
        return

    # Restore the physics body to the world.
    carried_body.global_position = drop_position
    carried_body.collision_layer = original_collision_layer
    carried_body.collision_mask = original_collision_mask
    carried_body.freeze = false
    carried_body.sleeping = false

    print("Dropped: ", carried_body.name)

    carried_body = null
