class_name Projectile
extends Area2D

## Base projectile class. Moves in a direction and damages enemy fighters on contact.

@export var speed: float = 400.0
@export var damage: float = 10.0
@export var unblockable: bool = false
@export var direction: float = 1.0
@export var lifetime: float = 3.0

## The fighter who fired this projectile — will not be hit by it.
var owner_fighter: Fighter = null

var _lifetime_timer: float = 0.0


func _ready() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	add_child(shape)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		body.take_damage(damage, unblockable)
		if owner_fighter != null:
			owner_fighter.on_damage_dealt(damage)
		on_hit(body)
		queue_free()


## Virtual — override in subclasses for special on-hit effects.
func on_hit(_target: Fighter) -> void:
	pass
