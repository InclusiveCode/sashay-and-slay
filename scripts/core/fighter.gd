class_name Fighter
extends CharacterBody2D

## Base class for all fighters (drag queens and politicians).

signal health_changed(new_health: float)
signal special_meter_changed(new_value: float)
signal defeated()
signal damage_dealt(amount: float)
signal special_used()
signal taunt_started()
signal taunt_finished()
signal passive_triggered(passive_name: String)
signal secondary_resource_changed(new_value: float)

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

# Stat modifier system
var _stat_reduction_count: int = 0
var _temp_speed_modifier: float = 1.0
var _temp_speed_timer: float = 0.0

# Input manager (set externally, e.g., by GameManager)
var input_manager: InputManager = null

# Opponent reference
var opponent: Fighter = null

# Hit counter
var _hit_counter: int = 0

# Taunt system
var is_taunting: bool = false
var taunt_duration: float = 1.0
var _taunt_timer: float = 0.0

# Secondary resource
var secondary_resource: float = 0.0
var secondary_resource_max: float = 100.0

# Arena boundaries
const ARENA_LEFT: float = 40.0
const ARENA_RIGHT: float = 1240.0

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

	passive_proc(delta)
	_process_taunt(delta)
	_process_temp_effects(delta)

	move_and_slide()
	_clamp_to_arena()


func get_stat_modifier() -> float:
	return max(1.0 - _stat_reduction_count * 0.1, 0.5)


func apply_stat_reduction() -> void:
	_stat_reduction_count += 1


func get_effective_punch() -> float:
	return punch_damage * get_stat_modifier()


func get_effective_kick() -> float:
	return kick_damage * get_stat_modifier()


func get_effective_speed() -> float:
	return speed * get_stat_modifier() * _temp_speed_modifier


func reset_round_state() -> void:
	_stat_reduction_count = 0
	_temp_speed_modifier = 1.0
	_temp_speed_timer = 0.0
	is_taunting = false
	_taunt_timer = 0.0
	_hit_counter = 0
	secondary_resource = 0.0
	is_blocking = false
	is_attacking = false


func _is_action_banned(action: String) -> bool:
	return input_manager != null and input_manager.is_input_banned(action)


func _get_remapped(action: String) -> String:
	if input_manager != null:
		return input_manager.get_remapped_action(action, true)
	return action


func handle_input(prefix: String) -> void:
	if is_attacking or is_taunting:
		return

	# Movement — never banned by silence
	var direction := Input.get_axis(prefix + "left", prefix + "right")
	velocity.x = direction * get_effective_speed()

	if direction != 0:
		facing_right = direction > 0

	if Input.is_action_just_pressed(prefix + "up") and is_on_floor():
		velocity.y = jump_force

	# Blocking (down) — can be banned
	if not _is_action_banned(prefix + "down"):
		is_blocking = Input.is_action_pressed(prefix + "down") and is_on_floor()
	else:
		is_blocking = false

	# Punch — check ban, apply remap
	var punch_action := _get_remapped(prefix + "punch")
	if not _is_action_banned(prefix + "punch") and Input.is_action_just_pressed(punch_action):
		attack("punch", get_effective_punch())
	# Kick — check ban, apply remap
	elif not _is_action_banned(prefix + "kick"):
		var kick_action := _get_remapped(prefix + "kick")
		if Input.is_action_just_pressed(kick_action):
			attack("kick", get_effective_kick())
	# Special — check ban
	if not _is_action_banned(prefix + "special") and Input.is_action_just_pressed(prefix + "special") and special_meter >= 100.0:
		use_special()
	# Taunt — check ban
	if not _is_action_banned(prefix + "taunt") and Input.is_action_just_pressed(prefix + "taunt"):
		start_taunt()


func attack(type: String, damage: float) -> void:
	is_attacking = true
	on_damage_dealt(damage)
	on_hit_landed()
	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished
	is_attacking = false


func use_special() -> void:
	attack("special", special_damage)
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()


func take_damage(amount: float, unblockable: bool = false) -> void:
	if is_blocking and not unblockable:
		amount *= 0.2  # Block reduces damage by 80%

	health -= amount
	health = max(health, 0.0)
	health_changed.emit(health)

	# Build special meter when taking damage
	special_meter = min(special_meter + amount * 0.5, 100.0)
	special_meter_changed.emit(special_meter)

	if health <= 0:
		defeated.emit()


func get_knockback_modifier() -> float:
	return 100.0 / max_health


func apply_knockback(direction: float, force: float) -> void:
	var kb = force * get_knockback_modifier()
	velocity.x += direction * kb


func on_damage_dealt(amount: float) -> void:
	special_meter = min(special_meter + amount * 0.4, 100.0)
	special_meter_changed.emit(special_meter)
	damage_dealt.emit(amount)


func on_hit_landed() -> void:
	_hit_counter += 1


# --- Passive system (virtual) ---

func passive_proc(_delta: float) -> void:
	pass


# --- Taunt system ---

func start_taunt() -> void:
	is_taunting = true
	_taunt_timer = taunt_duration
	taunt_started.emit()
	if anim_player and anim_player.has_animation("taunt"):
		anim_player.play("taunt")


func _process_taunt(delta: float) -> void:
	if not is_taunting:
		return
	_taunt_timer -= delta
	if _taunt_timer <= 0.0:
		is_taunting = false
		_taunt_timer = 0.0
		on_taunt_complete()
		taunt_finished.emit()


func on_taunt_complete() -> void:
	pass


# --- Secondary resource ---

func set_secondary_resource(value: float) -> void:
	secondary_resource = clamp(value, 0.0, secondary_resource_max)
	secondary_resource_changed.emit(secondary_resource)


# --- Temporary speed effects ---

func apply_temp_speed(modifier: float, duration: float) -> void:
	_temp_speed_modifier = modifier
	_temp_speed_timer = duration


func _process_temp_effects(delta: float) -> void:
	if _temp_speed_timer > 0.0:
		_temp_speed_timer -= delta
		if _temp_speed_timer <= 0.0:
			_temp_speed_modifier = 1.0
			_temp_speed_timer = 0.0


# --- Arena clamping ---

func _clamp_to_arena() -> void:
	if position.x < ARENA_LEFT:
		position.x = ARENA_LEFT
	elif position.x > ARENA_RIGHT:
		position.x = ARENA_RIGHT


func get_catchphrase() -> String:
	return "..."
