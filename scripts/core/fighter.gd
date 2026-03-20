class_name Fighter
extends CharacterBody2D

## Base class for all fighters (drag queens and politicians).

signal health_changed(new_health: float)
signal special_meter_changed(new_value: float)
signal defeated()

@export var fighter_name: String = "Fighter"
@export var max_health: float = 100.0
@export var speed: float = 300.0
@export var jump_force: float = -500.0
@export var punch_damage: float = 8.0
@export var kick_damage: float = 10.0
@export var special_damage: float = 25.0
@export var special_name: String = "Special Move"
@export var is_player_one: bool = true

var health: float
var special_meter: float = 0.0
var is_blocking: bool = false
var is_attacking: bool = false
var facing_right: bool = true
var gravity: float = 980.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var hitbox: Area2D = $Hitbox if has_node("Hitbox") else null
@onready var hurtbox: Area2D = $Hurtbox if has_node("Hurtbox") else null


func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var prefix = "p1_" if is_player_one else "p2_"
	handle_input(prefix)
	move_and_slide()


func handle_input(prefix: String) -> void:
	if is_attacking:
		return

	var direction := Input.get_axis(prefix + "left", prefix + "right")
	velocity.x = direction * speed

	if direction != 0:
		facing_right = direction > 0

	if Input.is_action_just_pressed(prefix + "up") and is_on_floor():
		velocity.y = jump_force

	is_blocking = Input.is_action_pressed(prefix + "down") and is_on_floor()

	if Input.is_action_just_pressed(prefix + "punch"):
		attack("punch", punch_damage)
	elif Input.is_action_just_pressed(prefix + "kick"):
		attack("kick", kick_damage)
	elif Input.is_action_just_pressed(prefix + "special") and special_meter >= 100.0:
		attack("special", special_damage)
		special_meter = 0.0
		special_meter_changed.emit(special_meter)


func attack(type: String, damage: float) -> void:
	is_attacking = true
	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished
	is_attacking = false


func take_damage(amount: float) -> void:
	if is_blocking:
		amount *= 0.2  # Block reduces damage by 80%

	health -= amount
	health = max(health, 0.0)
	health_changed.emit(health)

	# Build special meter when taking damage
	special_meter = min(special_meter + amount * 0.5, 100.0)
	special_meter_changed.emit(special_meter)

	if health <= 0:
		defeated.emit()


func get_catchphrase() -> String:
	return "..."
