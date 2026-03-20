class_name Thorn
extends Area2D

## A planted thorn that grows over time and damages non-owner fighters
## on contact. Damage scales: 2 dmg (0-3s), 4 dmg (3-6s), 6 dmg (6s+).

var owner_fighter: Fighter = null
var _age: float = 0.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	add_child(shape)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta


func get_current_damage() -> float:
	if _age < 3.0:
		return 2.0
	elif _age < 6.0:
		return 4.0
	else:
		return 6.0


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		body.take_damage(get_current_damage())
		if owner_fighter != null:
			owner_fighter.on_damage_dealt(get_current_damage())
