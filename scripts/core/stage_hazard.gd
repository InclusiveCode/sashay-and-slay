class_name StageHazard
extends Node2D

## Base class for all stage hazards. Subclasses override activate() with specific behaviour.

@export var interval: float = 20.0
@export var hazard_name: String = "Hazard"

var _timer: float = 0.0
var fighters: Array[Fighter] = []
var active: bool = true


func _physics_process(delta: float) -> void:
	if not active:
		return

	_timer += delta
	if _timer >= interval:
		activate()
		_timer = 0.0


## Virtual — override in subclasses to define what the hazard does.
func activate() -> void:
	pass


## Returns all Fighter nodes that are currently inside the given Area2D.
func get_fighters_in_area(area: Area2D) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for body in area.get_overlapping_bodies():
		if body is Fighter:
			result.append(body)
	return result


## Deals damage to every registered fighter.
func apply_damage_to_all(damage: float, unblockable: bool = false) -> void:
	for fighter in fighters:
		if is_instance_valid(fighter):
			fighter.take_damage(damage, unblockable)


## Launches every registered fighter upward by the given force.
func apply_launch_to_all(force: float) -> void:
	for fighter in fighters:
		if is_instance_valid(fighter):
			fighter.velocity.y = -force
