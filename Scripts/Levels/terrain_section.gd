@tool
extends StaticBody2D
class_name TerrainSection

# =============================================================================
# TERRAIN SECTION
# =============================================================================
# A visible, collision-backed rectangular run of 32x32 floor/wall tiles.
# No packed TileMapLayer byte arrays: all solid platforms have real scene nodes.
# Tiles are painted in the editor and at runtime directly from supplied art.
# The child CollisionShape2D stores the matching RectangleShape2D.
# =============================================================================

const TILE_SIZE: int = 32
const TERRAIN_ART: Texture2D = preload("res://Assets/Art/Tileset.png")

@export_range(1, 128, 1) var columns: int = 1:
    set(value):
        columns = maxi(1, value)
        queue_redraw()

@export_range(1, 32, 1) var rows: int = 1:
    set(value):
        rows = maxi(1, value)
        queue_redraw()

func _draw() -> void:
    var top_left: Vector2 = -Vector2(columns, rows) * (TILE_SIZE / 2.0)
    var src: Rect2 = Rect2(Vector2.ZERO, Vector2(TILE_SIZE, TILE_SIZE))

    for y: int in range(rows):
        for x: int in range(columns):
            var dest: Rect2 = Rect2(
                top_left + Vector2(x * TILE_SIZE, y * TILE_SIZE),
                Vector2(TILE_SIZE, TILE_SIZE)
            )
            draw_texture_rect_region(TERRAIN_ART, dest, src)
