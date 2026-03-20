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

var hazards: Array[StageHazard] = []


func _ready() -> void:
	if music_track:
		var player = AudioStreamPlayer.new()
		player.stream = music_track
		player.bus = "Music"
		add_child(player)
		player.play()


## Registers a hazard with this stage and adds it as a child node.
func register_hazard(hazard: StageHazard) -> void:
	hazards.append(hazard)
	add_child(hazard)


## Passes the fighter list to every registered hazard so they can target them.
func set_fighters(fighter_list: Array[Fighter]) -> void:
	for hazard in hazards:
		hazard.fighters = fighter_list


## Deactivates all registered hazards (they stop ticking).
func deactivate_hazards() -> void:
	for hazard in hazards:
		hazard.active = false


## Reactivates all registered hazards.
func activate_hazards() -> void:
	for hazard in hazards:
		hazard.active = true
