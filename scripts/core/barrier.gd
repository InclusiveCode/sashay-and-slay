class_name Barrier
extends StaticBody2D

## Destructible barrier placed by Greg Ablot. Has 15 HP, deals 5 contact damage
## to opponents who collide with it.

signal barrier_destroyed(barrier: Barrier)

var owner_fighter: Fighter = null
var barrier_health: float = 15.0
const CONTACT_DAMAGE: float = 5.0

var _contact_cooldown: Dictionary = {}  # fighter -> float
const CONTACT_COOLDOWN_TIME: float = 1.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20.0, 80.0)
	shape.shape = rect
	add_child(shape)

	# Also add an Area2D for contact damage detection
	var area := Area2D.new()
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(24.0, 84.0)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	add_child(area)
	area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Tick contact cooldowns
	var to_erase: Array = []
	for fighter in _contact_cooldown:
		_contact_cooldown[fighter] -= delta
		if _contact_cooldown[fighter] <= 0.0:
			to_erase.append(fighter)
	for fighter in to_erase:
		_contact_cooldown.erase(fighter)


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		if body not in _contact_cooldown:
			body.take_damage(CONTACT_DAMAGE, false)
			_contact_cooldown[body] = CONTACT_COOLDOWN_TIME


func take_barrier_damage(amount: float) -> void:
	barrier_health -= amount
	if barrier_health <= 0.0:
		barrier_destroyed.emit(self)
		queue_free()
