extends MonowheelVisuals

# =============================================================================
# MONOWHEEL SUSPENSION OVERRIDE
# =============================================================================
# Compatibility override: keeps the existing wheel animation untouched,
# then aligns the tire/hubcap and moves the body and wheel together on impact.
# This script can replace the base animation script once local edits are merged.
# =============================================================================

var _shared_landing_dip: float = 0.0


func update_motion(
    delta: float,
    travelled_x: float,
    direction: float,
    grounded: bool,
    just_landed: bool,
    impact_speed: float
) -> void:
    # Preserve existing wheel frame animation and directional body lean.
    super.update_motion(
        delta, travelled_x, direction, grounded, just_landed, impact_speed
    )

    # Treat landing like the robot's suspension briefly compressing down.
    if just_landed:
        _shared_landing_dip = minf(
            landing_compression, maxf(2.0, impact_speed * 0.012)
        )

    var dip: float = _shared_landing_dip if grounded else 0.0

    # Never let landing recoil lift the wheel up into the body. Keep airborne
    # wheel extension from the original animation, and lock horizontal center.
    var extension: float = maxf(0.0, _wheel_offset)
    tire.position = Vector2(0.0, BASE_WHEEL_Y + extension + dip)
    hubcap.position = tire.position
    body_pivot.position = Vector2(0.0, BASE_PIVOT_Y + dip)

    _shared_landing_dip = move_toward(
        _shared_landing_dip, 0.0, delta * recoil_recovery
    )
