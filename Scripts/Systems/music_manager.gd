extends Node

# =============================================================================
# MUSIC MANAGER
# =============================================================================
# Plays one continuous background track across menus and gameplay.
# The autoload survives scene changes; volume is controlled by GameState's
# existing Master and Music audio-bus settings.
# =============================================================================

var BGM: AudioStreamOggVorbis = preload("res://Audio/Music/counterweight_bgm.ogg")

var music_player: AudioStreamPlayer


func _ready() -> void:
    # Keep music running when the gameplay tree is paused.
    process_mode = Node.PROCESS_MODE_ALWAYS

    music_player = AudioStreamPlayer.new()
    music_player.name = "BackgroundMusic"
    music_player.bus = &"Music"
    music_player.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(music_player)

    # Godot's native Ogg loop avoids re-triggering playback from script.
    BGM.loop = true
    BGM.loop_offset = 0.0
    music_player.stream = BGM
    music_player.play()
