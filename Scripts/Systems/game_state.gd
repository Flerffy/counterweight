extends Node

# =============================================================================
# GAME STATE — PERSISTENT PROGRESSION & OPTIONS
# =============================================================================
# Autosaves between rooms. No per-object save data and no runtime state persists.
# The user:// path is writable in standalone desktop/web builds.
# =============================================================================

const SAVE_PATH: String = "user://counterweight_save.cfg"
const MAX_LEVEL: int = 15

var open_level_select: bool = false
var highest_unlocked: int = 1
var current_level: int = 1
var game_complete: bool = false

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9
var fullscreen: bool = false
var show_hints: bool = true
var show_prompts: bool = true

func _ready() -> void:
    load_save()
    apply_options()

func level_path(number: int) -> String:
    return "res://Scenes/Levels/level_%02d.tscn" % clampi(number, 1, MAX_LEVEL)

func can_play(number: int) -> bool:
    return number >= 1 and number <= highest_unlocked

func enter_level(number: int) -> void:
    current_level = clampi(number, 1, MAX_LEVEL)
    save_progress()

## Unlock the next level only when the player reaches the current room's exit.
func complete_level(number: int) -> void:
    if number < 1 or number > MAX_LEVEL:
        return
    if number == MAX_LEVEL:
        game_complete = true
        highest_unlocked = MAX_LEVEL
        current_level = MAX_LEVEL
    else:
        highest_unlocked = maxi(highest_unlocked, number + 1)
        current_level = number + 1
    save_progress()

func load_save() -> void:
    var config: ConfigFile = ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    highest_unlocked = clampi(int(config.get_value("progress", "highest_unlocked", 1)), 1, MAX_LEVEL)
    current_level = clampi(int(config.get_value("progress", "current_level", 1)), 1, MAX_LEVEL)
    current_level = mini(current_level, highest_unlocked)
    game_complete = bool(config.get_value("progress", "game_complete", false))
    master_volume = clampf(float(config.get_value("options", "master_volume", 1.0)), 0.0, 1.0)
    music_volume = clampf(float(config.get_value("options", "music_volume", 0.8)), 0.0, 1.0)
    sfx_volume = clampf(float(config.get_value("options", "sfx_volume", 0.9)), 0.0, 1.0)
    fullscreen = bool(config.get_value("options", "fullscreen", false))
    show_hints = bool(config.get_value("options", "show_hints", true))
    show_prompts = bool(config.get_value("options", "show_prompts", true))

func save_progress() -> void:
    var config: ConfigFile = ConfigFile.new()
    config.set_value("progress", "highest_unlocked", highest_unlocked)
    config.set_value("progress", "current_level", current_level)
    config.set_value("progress", "game_complete", game_complete)
    config.set_value("options", "master_volume", master_volume)
    config.set_value("options", "music_volume", music_volume)
    config.set_value("options", "sfx_volume", sfx_volume)
    config.set_value("options", "fullscreen", fullscreen)
    config.set_value("options", "show_hints", show_hints)
    config.set_value("options", "show_prompts", show_prompts)
    var error: Error = config.save(SAVE_PATH)
    if error != OK:
        push_warning("Could not save Counterweight progress: %s" % error_string(error))

func apply_options() -> void:
    _set_bus_volume("Master", master_volume)
    _set_bus_volume("Music", music_volume)
    _set_bus_volume("SFX", sfx_volume)
    if not OS.has_feature("web"):
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func _set_bus_volume(bus_name: String, linear: float) -> void:
    var bus_index: int = AudioServer.get_bus_index(bus_name)
    if bus_index >= 0:
        AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear, 0.0001)))
        AudioServer.set_bus_mute(bus_index, linear <= 0.0001)

func update_option(key: String, value: Variant) -> void:
    match key:
        "master_volume": master_volume = clampf(float(value), 0.0, 1.0)
        "music_volume": music_volume = clampf(float(value), 0.0, 1.0)
        "sfx_volume": sfx_volume = clampf(float(value), 0.0, 1.0)
        "fullscreen": fullscreen = bool(value)
        "show_hints": show_hints = bool(value)
        "show_prompts": show_prompts = bool(value)
        _: return
    apply_options()
    save_progress()
