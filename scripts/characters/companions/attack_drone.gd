class_name AttackDrone
extends CharacterBody2D

## Attack drone companion for Elmo Musk. Follows owner, fires 3 shots (4 dmg
## each) spread over 8 seconds. Has 10 HP, can be destroyed by opponent.

signal drone_destroyed(drone: AttackDrone)

var owner_fighter: Fighter = null
var target_fighter: Fighter = null
var drone_health: float = 10.0
var capital_cost: int = 15

var _shots_fired: int = 0
const MAX_SHOTS: int = 3
const SHOT_DAMAGE: float = 4.0
const LIFETIME: float = 8.0
const FOLLOW_OFFSET: Vector2 = Vector2(0.0, -60.0)

var _lifetime_timer: float = 0.0
var _shot_interval: float = LIFETIME / MAX_SHOTS
var _shot_timer: float = 0.0


func _ready() -> void:
	_shot_timer = _shot_interval


func _physics_process(delta: float) -> void:
	# Follow owner
	if owner_fighter != null:
		position = owner_fighter.position + FOLLOW_OFFSET

	# Lifetime
	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		_self_destruct()
		return

	# Fire shots
	_shot_timer -= delta
	if _shot_timer <= 0.0 and _shots_fired < MAX_SHOTS:
		_fire_shot()
		_shots_fired += 1
		_shot_timer = _shot_interval


func _fire_shot() -> void:
	if owner_fighter == null or target_fighter == null:
		return
	var dir := 1.0 if target_fighter.global_position.x > global_position.x else -1.0
	var proj := Projectile.new()
	proj.damage = SHOT_DAMAGE
	proj.speed = 400.0
	proj.direction = dir
	proj.owner_fighter = owner_fighter
	proj.position = global_position
	get_tree().current_scene.add_child(proj)


func take_drone_damage(amount: float, from_owner: bool = false) -> void:
	if from_owner:
		return  # Musk cannot destroy his own drones
	drone_health -= amount
	if drone_health <= 0.0:
		drone_destroyed.emit(self)
		queue_free()


func _self_destruct() -> void:
	queue_free()
