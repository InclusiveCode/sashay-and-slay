class_name BurningZone
extends Area2D

## A persistent damage zone that burns fighters standing inside it.

@export var damage_per_second: float = 3.0
@export var duration: float = 8.0
@export var zone_width: float = 100.0

## Optional — when set, the owner is immune to the zone's damage.
## Call set_hurts_everyone(true) to damage all fighters including the owner.
var owner_fighter: Fighter = null

var _duration_timer: float = 0.0
var _tick_accumulator: float = 0.0


func _ready() -> void:
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(zone_width, 120.0)
	shape.shape = rect
	add_child(shape)


func _physics_process(delta: float) -> void:
	_duration_timer += delta
	if _duration_timer >= duration:
		queue_free()
		return

	_tick_accumulator += delta
	if _tick_accumulator >= 1.0:
		_tick_accumulator -= 1.0
		_apply_tick_damage()


func _apply_tick_damage() -> void:
	for body in get_overlapping_bodies():
		if body is Fighter:
			if owner_fighter != null and body == owner_fighter:
				continue
			body.take_damage(damage_per_second, false)


## When called with true, the zone will damage all fighters — including the one who spawned it.
func set_hurts_everyone(hurts_all: bool) -> void:
	if hurts_all:
		owner_fighter = null
