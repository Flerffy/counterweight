extends Control
class_name GameMenu

# =============================================================================
# GAME MENU — HOME, PAUSE, LEVEL SELECT, OPTIONS, CREDITS
# =============================================================================
# All controls are standard Godot UI nodes styled with flat rectangles.
# The background is the supplied factory art; interface decoration uses shapes.
# =============================================================================

@export var pause_overlay: bool = false

const BG: Texture2D = preload("res://Assets/Art/BG.png")
const CREAM: Color = Color("f4e9d7")
const MUTED: Color = Color("cfaaa1")
const ORANGE: Color = Color("e5ae67")
const CYAN: Color = Color("72bda6")
const PANEL: Color = Color(0.085, 0.068, 0.080, 0.97)

const LEVEL_TITLES = [
    "A Step Up", "Building Higher", "Light on Your Feet", "The Long Way Across",
    "The Ascent", "First Contact", "Against the Clock", "Two-Step Security",
    "Remember the Order", "The Switchboard", "The Extra Burden",
    "Leave Something Behind", "The Price of Passage", "Balancing Act", "Counterweight"
]

var page: String = "home"
var card: PanelContainer
var content: VBoxContainer

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    _create_layout()
    _show_page("pause" if pause_overlay else "home")
    if not pause_overlay and GameState.open_level_select:
        GameState.open_level_select = false
        _show_page("levels")
    resized.connect(queue_redraw)

func _draw() -> void:
    if not pause_overlay:
        # A single background image, proportionally scaled to cover the menu.
        var bg_size: Vector2 = BG.get_size()
        var cover_scale: float = maxf(size.x / bg_size.x, size.y / bg_size.y)
        var scaled_size: Vector2 = bg_size * cover_scale
        var bg_position: Vector2 = (size - scaled_size) / 2.0
        draw_texture_rect(BG, Rect2(bg_position, scaled_size), false)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.035, 0.05, 0.73 if pause_overlay else 0.54))
    draw_rect(Rect2(0, 0, size.x, 5), ORANGE)
    draw_line(Vector2(20, size.y - 28), Vector2(size.x - 20, size.y - 28), Color(ORANGE.r, ORANGE.g, ORANGE.b, 0.35), 1.0)

func _create_layout() -> void:
    var centering: CenterContainer = CenterContainer.new()
    centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(centering)

    card = PanelContainer.new()
    card.custom_minimum_size = Vector2(580, 0)
    card.add_theme_stylebox_override("panel", _style(PANEL, Color("a85b4d"), 2))
    centering.add_child(card)

    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 35)
    margin.add_theme_constant_override("margin_right", 35)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    card.add_child(margin)

    content = VBoxContainer.new()
    content.alignment = BoxContainer.ALIGNMENT_CENTER
    content.add_theme_constant_override("separation", 13)
    margin.add_child(content)

func _style(fill: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(0)
    style.content_margin_left = 12.0
    style.content_margin_right = 12.0
    style.content_margin_top = 8.0
    style.content_margin_bottom = 8.0
    return style

func _title(text: String, font_size: int = 34) -> void:
    var label: Label = _make_label(text, font_size, CREAM)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(label)

func _make_label(text: String, font_size: int = 16, color: Color = CREAM) -> Label:
    var label: Label = Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    return label

func _subtitle(text: String) -> void:
    content.add_child(_make_label(text, 14, MUTED))

func _button(text: String, callback: Callable, disabled: bool = false) -> Button:
    var b: Button = Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0, 42)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.disabled = disabled
    b.add_theme_color_override("font_color", CREAM)
    b.add_theme_color_override("font_hover_color", Color("171318"))
    b.add_theme_color_override("font_disabled_color", Color("867772"))
    b.add_theme_stylebox_override("normal", _style(Color("28232a"), Color("5e4447")))
    b.add_theme_stylebox_override("hover", _style(ORANGE, ORANGE))
    b.add_theme_stylebox_override("pressed", _style(CYAN, CYAN))
    b.add_theme_stylebox_override("disabled", _style(Color("19171d"), Color("3b3337")))
    b.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, CYAN, 2))
    b.pressed.connect(callback)
    return b

func _clear() -> void:
    for child: Node in content.get_children():
        content.remove_child(child)
        child.queue_free()

func _show_page(next_page: String) -> void:
    page = next_page
    _clear()
    card.custom_minimum_size.x = 860.0 if page == "levels" else 580.0
    match page:
        "home": _build_home()
        "pause": _build_pause()
        "levels": _build_levels()
        "options": _build_options()
        "credits": _build_credits()
    queue_redraw()

func _build_home() -> void:
    _title("COUNTERWEIGHT", 40)
    _subtitle("NOTHING BECOMES LIGHTER WITHOUT SOMETHING ELSE BECOMING HEAVIER")
    content.add_child(_make_label("G A M E   O F F   2 0 2 6", 13, ORANGE))
    if GameState.highest_unlocked > 1:
        content.add_child(_button("CONTINUE  —  LEVEL %02d" % GameState.current_level, func(): _start_level(GameState.current_level)))
    content.add_child(_button("START FROM LEVEL 01", func(): _start_level(1)))
    content.add_child(_button("LEVEL SELECT", func(): _show_page("levels")))
    content.add_child(_button("OPTIONS", func(): _show_page("options")))
    content.add_child(_button("CREDITS", func(): _show_page("credits")))
    content.add_child(_button("QUIT", func(): get_tree().quit()))
    _subtitle("Progress saves automatically after each completed room.")

func _build_pause() -> void:
    _title("PAUSED")
    _subtitle("Take your time. The machinery will wait.")
    content.add_child(_button("RESUME", _resume))
    content.add_child(_button("RESTART LEVEL", func(): _start_level(GameState.current_level)))
    content.add_child(_button("OPTIONS", func(): _show_page("options")))
    content.add_child(_button("MAIN MENU", _go_home))

func _build_levels() -> void:
    _title("LEVEL SELECT", 30)
    _subtitle("Unlocked: %d / 15" % GameState.highest_unlocked)
    var grid: GridContainer = GridContainer.new()
    grid.columns = 5
    grid.add_theme_constant_override("h_separation", 8)
    grid.add_theme_constant_override("v_separation", 8)
    content.add_child(grid)
    for i: int in range(15):
        var number: int = i + 1
        var accessible: bool = GameState.can_play(number)
        var title: String = ("%02d\n%s" % [number, LEVEL_TITLES[i]]) if accessible else ("%02d\nLOCKED" % number)
        var level_button: Button = _button(title, func(): _start_level(number), not accessible)
        level_button.custom_minimum_size = Vector2(145, 70)
        grid.add_child(level_button)
    content.add_child(_button("BACK", _go_back))

func _build_options() -> void:
    _title("OPTIONS", 30)
    _subtitle("Audio settings are saved, ready for the composer's tracks.")
    _volume_row("MASTER VOLUME", "master_volume", GameState.master_volume)
    _volume_row("MUSIC", "music_volume", GameState.music_volume)
    _volume_row("SOUND EFFECTS", "sfx_volume", GameState.sfx_volume)
    _check_row("FULLSCREEN", "fullscreen", GameState.fullscreen)
    _check_row("SHOW LEVEL HINTS", "show_hints", GameState.show_hints)
    _check_row("SHOW INTERACTION PROMPTS", "show_prompts", GameState.show_prompts)
    content.add_child(_button("BACK", _go_back))

func _volume_row(title: String, key: String, val: float) -> void:
    var row: HBoxContainer = HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    content.add_child(row)
    var label: Label = _make_label(title, 14, MUTED)
    label.custom_minimum_size.x = 178
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    row.add_child(label)
    var slider: HSlider = HSlider.new()
    slider.custom_minimum_size = Vector2(260, 24)
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.min_value = 0.0
    slider.max_value = 100.0
    slider.step = 5.0
    slider.value = val * 100.0
    row.add_child(slider)
    var percent: Label = _make_label("%d%%" % roundi(slider.value), 14, CREAM)
    percent.custom_minimum_size.x = 52
    row.add_child(percent)
    slider.value_changed.connect(func(v: float) -> void:
        percent.text = "%d%%" % roundi(v)
        GameState.update_option(key, v / 100.0)
    )

func _check_row(title: String, key: String, value: bool) -> void:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.text = title
    checkbox.button_pressed = value
    checkbox.add_theme_color_override("font_color", CREAM)
    checkbox.toggled.connect(func(v: bool): GameState.update_option(key, v))
    content.add_child(checkbox)

func _build_credits() -> void:
    _title("CREDITS", 30)
    _subtitle("COUNTERWEIGHT  ·  GAME OFF 2026")
    content.add_child(_make_label("Lead Programming & Project Lead  —  Erik / Flerffy", 17, CREAM))
    content.add_child(_make_label("Co-Programming  —  Flocos", 17, CREAM))
    content.add_child(_make_label("Visual Art  —  [Artist credit pending]", 17, CREAM))
    content.add_child(_make_label("Music & Sound  —  [Composer credit pending]", 17, CREAM))
    content.add_child(_make_label("Built in Godot  ·  GitHub Game Off 2026", 14, MUTED))
    content.add_child(_button("BACK", _go_back))

func _go_back() -> void:
    _show_page("pause" if pause_overlay else "home")

func _start_level(number: int) -> void:
    if pause_overlay:
        get_tree().paused = false
    get_tree().call_deferred("change_scene_to_file", GameState.level_path(number))

func _go_home() -> void:
    get_tree().paused = false
    get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/main_menu.tscn")

func _resume() -> void:
    if not pause_overlay:
        return
    get_tree().paused = false
    get_parent().queue_free()

func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action_pressed("ui_cancel") or event.is_echo():
        return
    get_viewport().set_input_as_handled()
    if page != "pause" and page != "home":
        _go_back()
    elif pause_overlay:
        _resume()
