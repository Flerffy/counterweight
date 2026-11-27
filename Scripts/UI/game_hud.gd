extends Control
class_name GameHUD

# =============================================================================
# GAME HUD — SHAPE-DRAWN, NO UI IMAGES
# =============================================================================
# The supplied images are used in-world. HUD panels, weight indicators and
# floating contextual prompts use only draw_rect(), draw_line(), and text.
# =============================================================================

const INK: Color = Color("171318")
const PANEL: Color = Color(0.09, 0.08, 0.10, 0.88)
const EDGE: Color = Color("aa6152")
const TEXT: Color = Color("f8eddb")
const MUTED: Color = Color("c5a69e")
const GOLD: Color = Color("e8bd6d")
const TEAL: Color = Color("6ab6a0")

var level_number: int = 1
var level_title: String = "Puzzle"
var hint: String = ""
var player: CharacterBody2D
var weight: WeightComponent
var carry: CarryComponent
var detector: WeightContactDetector
var font: Font

func setup(number: int, title: String, description: String) -> void:
    level_number = number
    level_title = title
    hint = description
    queue_redraw()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    font = ThemeDB.fallback_font
    var room: Node = get_parent().get_parent()
    player = room.get_node_or_null("Player") as CharacterBody2D
    if player != null:
        weight = player.get_node_or_null("WeightComponent") as WeightComponent
        carry = player.get_node_or_null("CarryComponent") as CarryComponent
        detector = player.get_node_or_null("ContactDetector") as WeightContactDetector
    set_process(true)

func _process(_delta: float) -> void:
    queue_redraw()

func _label(text: String, where: Vector2, size_px: int, color: Color = TEXT) -> void:
    draw_string(font, where, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func _panel(rect: Rect2) -> void:
    draw_rect(rect, PANEL)
    draw_rect(rect, EDGE, false, 1.0)
    draw_rect(Rect2(rect.position + Vector2(0.0, 0.0), Vector2(4.0, rect.size.y)), EDGE)

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w < 200.0 or h < 200.0:
        return

    # Level heading + optional objective.
    var header_height: float = 78.0 if GameState.show_hints else 51.0
    _panel(Rect2(18, 17, minf(w - 290.0, 590.0), header_height))
    _label("%02d  /  15" % level_number, Vector2(33, 44), 16, GOLD)
    _label(level_title.to_upper(), Vector2(132, 44), 18)
    if GameState.show_hints:
        var description: String = hint
        if description.length() > 77:
            description = description.substr(0, 74) + "..."
        _label(description, Vector2(33, 72), 12, MUTED)

    # Read intrinsic weight and load separately: carried mass does not alter jumping.
    var own_weight: int = weight.current_weight if weight != null else 2
    var held_weight: int = 0
    if carry != null and is_instance_valid(carry.carried_body):
        var held_component: WeightComponent = carry.carried_body.get_node_or_null("WeightComponent") as WeightComponent
        if held_component != null:
            held_weight = held_component.current_weight
    var panel_x: float = w - 254
    _panel(Rect2(panel_x, 17, 236, 78))
    _label("YOUR WEIGHT", Vector2(panel_x + 15, 37), 11, MUTED)
    for i: int in range(3):
        var filled: bool = i < own_weight
        draw_rect(Rect2(panel_x + 16 + i * 19, 48, 14, 13), GOLD if filled else Color("43373a"))
    _label("%d / 3" % own_weight, Vector2(panel_x + 84, 60), 13)
    _label("HELD: %d   APPLIED: %d" % [held_weight, held_weight + own_weight], Vector2(panel_x + 15, 83), 12, TEAL)

    # Controls are deliberately concise to avoid obscuring the level.
    _panel(Rect2(18, h - 43, minf(w - 36, 665), 29))
    _label("A/D MOVE    SPACE JUMP    Q/E SHIFT    F CARRY    R RESET    ESC MENU", Vector2(29, h - 24), 12, MUTED)

    if not GameState.show_prompts or player == null:
        return
    var prompt: String = _get_context_prompt()
    if prompt.is_empty():
        return
    var p: Vector2 = player.get_global_transform_with_canvas().origin
    var popup_width: float = clampf(float(prompt.length()) * 7.1 + 30.0, 120.0, 290.0)
    var popup_x: float = clampf(p.x - popup_width * 0.5, 12.0, w - popup_width - 12.0)
    var popup_y: float = clampf(p.y - 132.0, 107.0, h - 100.0)
    _panel(Rect2(popup_x, popup_y, popup_width, 30))
    _label(prompt, Vector2(popup_x + 12, popup_y + 21), 12, TEXT)
    draw_line(Vector2(p.x, popup_y + 31), Vector2(p.x, popup_y + 41), EDGE, 1.0)

func _get_context_prompt() -> String:
    if carry != null and is_instance_valid(carry.carried_body):
        return "[F] DROP  |  Q/E SHIFT"
    if detector != null:
        var targets: Array[Node2D] = []
        for body: Node2D in detector.get_overlapping_bodies():
            if body.get_node_or_null("WeightComponent") != null:
                targets.append(body)
        if targets.size() >= 2:
            return "[Q/E] TRANSFER BETWEEN"
        if targets.size() == 1:
            var component: WeightComponent = targets[0].get_node("WeightComponent") as WeightComponent
            if targets[0].is_in_group("carryable"):
                if carry != null and component.current_weight <= carry.max_carry_weight:
                    return "[F] CARRY  |  [Q/E] SHIFT"
                return "TOO HEAVY  |  [E] TAKE"
            return "[Q/E] SHIFT WEIGHT"
    for node: Node in get_tree().get_nodes_in_group("puzzle_buttons"):
        if node is PuzzleButton and player.global_position.distance_to((node as PuzzleButton).global_position) < 65.0:
            match (node as PuzzleButton).mode:
                PuzzleButton.Mode.TOGGLE: return "STEP ON: TOGGLE"
                PuzzleButton.Mode.TIMED: return "STEP ON: TIMED"
                PuzzleButton.Mode.MOMENTARY: return "STAY ON: HOLD"
    return ""
