class_name Stage
extends Node2D

## Base class for fighting stages/arenas.

@export var stage_name: String = "Stage"
@export var stage_width: float = 1280.0
@export var floor_y: float = 600.0
@export var left_boundary: float = 0.0
@export var right_boundary: float = 1280.0
@export var music_track: AudioStream

@onready var camera: Camera2D = $Camera2D if has_node("Camera2D") else null


func _ready() -> void:
	if music_track:
		var player = AudioStreamPlayer.new()
		player.stream = music_track
		player.bus = "Music"
		add_child(player)
		player.play()
