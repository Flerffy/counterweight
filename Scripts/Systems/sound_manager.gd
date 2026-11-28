extends Node

# =============================================================================
# SOUND MANAGER
# =============================================================================
# Short one-shots and occasional environment sounds across all puzzle rooms.
# Routed to SFX so existing Options sliders control these independently of BGM.
# MusicManager owns the continuous soundtrack.
# =============================================================================

const BUTTON_STEP: AudioStream = preload("res://Audio/SFX/Step_sound.wav")
const DOOR_OPEN: AudioStream = preload("res://Audio/SFX/Door_Open_sound.wav")
const DOOR_CLOSE: AudioStream = preload("res://Audio/SFX/Door_Close_sound.wav")
const ROBOT_HAND: AudioStream = preload("res://Audio/SFX/Robot_Hand_sound.wav")
const STEAM: AudioStream = preload("res://Audio/SFX/Steam_sound.wav")
const AMBIENCE = [
    preload("res://Audio/SFX/ambience_sound_1.wav"),
    preload("res://Audio/SFX/ambience_sound_2.wav"),
    preload("res://Audio/SFX/ambience_sound_3.wav"),
    preload("res://Audio/SFX/ambience_sound_4.wav"),
    preload("res://Audio/SFX/ambience_sound_5.wav"),
    preload("res://Audio/SFX/ambience_sound_6.wav"),
    preload("res://Audio/SFX/ambience_sound_7.wav"),
]

const VOICE_COUNT: int = 6
const AMBIENCE_MIN_DELAY: float = 10.0
const AMBIENCE_MAX_DELAY: float = 19.0

var voices: Array[AudioStreamPlayer] = []
var ambience_player: AudioStreamPlayer
var ambience_timer: Timer
var ambience_enabled: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

    for i: int in range(VOICE_COUNT):
        var voice: AudioStreamPlayer = AudioStreamPlayer.new()
        voice.name = "OneShot%02d" % i
        voice.bus = &"SFX"
        add_child(voice)
        voices.append(voice)

    ambience_player = AudioStreamPlayer.new()
    ambience_player.name = "RoomAmbience"
    ambience_player.bus = &"SFX"
    ambience_player.volume_db = -14.0
    add_child(ambience_player)

    ambience_timer = Timer.new()
    ambience_timer.name = "AmbienceTimer"
    ambience_timer.one_shot = true
    ambience_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
    ambience_timer.timeout.connect(_on_ambience_timer_timeout)
    add_child(ambience_timer)

## Plays a short sound without cutting off unrelated effects.
func play_one_shot(sound: AudioStream, gain_db: float = 0.0) -> void:
    for voice: AudioStreamPlayer in voices:
        if not voice.playing:
            voice.stream = sound
            voice.volume_db = gain_db
            voice.play()
            return
    # Cap polyphony instead of interrupting an existing sound.

func play_button_press() -> void:
    play_one_shot(BUTTON_STEP, -2.0)

func play_door(opened: bool) -> void:
    play_one_shot(DOOR_OPEN if opened else DOOR_CLOSE, -3.0)

func play_manipulation() -> void:
    play_one_shot(ROBOT_HAND, -5.0)

## Called when a level starts; no ambience plays in the main menu.
func start_room_ambience() -> void:
    ambience_enabled = true
    ambience_timer.start(randf_range(AMBIENCE_MIN_DELAY, AMBIENCE_MAX_DELAY))

func stop_room_ambience() -> void:
    ambience_enabled = false
    ambience_timer.stop()
    ambience_player.stop()

func _on_ambience_timer_timeout() -> void:
    if not ambience_enabled:
        return
    # Occasionally use the steam hiss; other events sample seven room sounds.
    var selected: int = randi_range(0, AMBIENCE.size())
    ambience_player.stream = STEAM if selected == AMBIENCE.size() else AMBIENCE[selected]
    ambience_player.play()
    ambience_timer.start(randf_range(AMBIENCE_MIN_DELAY, AMBIENCE_MAX_DELAY))
