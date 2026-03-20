class_name CancunCruz
extends Fighter

## Zoner / Coward — Deals bonus damage to low-HP opponents, has a flee dash,
## and a sleep-zone special. Gets faster when low HP.

var _flee_cooldown: float = 0.0
var _flee_cooldown_max: float = 5.0
var _is_fleeing: bool = false
var _flee_timer: float = 0.0
const FLEE_DURATION: float = 0.5
const FLEE_DISTANCE: float = 600.0  # roughly half stage

var _fled_state_active: bool = false


func _ready() -> void:
	fighter_name = "Cancun Cruz"
	max_health = 100.0
	speed = 310.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 26.0
	special_name = "Zodiac Filibuster"
	super._ready()


func get_catchphrase() -> String:
	return "I'd love to fight, but I have a flight to catch."


func on_damage_dealt(amount: float) -> void:
	# 25% bonus damage to opponents below 40% HP
	if opponent != null and opponent.health < opponent.max_health * 0.4:
		var bonus := amount * 0.25
		opponent.take_damage(bonus, true)
		super.on_damage_dealt(amount + bonus)
	else:
		super.on_damage_dealt(amount)


func on_taunt_complete() -> void:
	# Flee dash: invincible 0.5s, travel half stage
	if _flee_cooldown <= 0.0:
		_is_fleeing = true
		_flee_timer = FLEE_DURATION
		var flee_dir := -1.0 if facing_right else 1.0
		velocity.x = flee_dir * (FLEE_DISTANCE / FLEE_DURATION)
		_flee_cooldown = _get_flee_cooldown()


func _get_flee_cooldown() -> float:
	if _fled_state_active:
		return _flee_cooldown_max * 0.5
	return _flee_cooldown_max


func passive_proc(delta: float) -> void:
	# Flee cooldown countdown
	if _flee_cooldown > 0.0:
		_flee_cooldown -= delta

	# Flee invincibility timer
	if _is_fleeing:
		_flee_timer -= delta
		if _flee_timer <= 0.0:
			_is_fleeing = false

	# "Fled the State" — below 30% HP, speed +20% and cooldown halved
	var was_fled := _fled_state_active
	_fled_state_active = health <= max_health * 0.3
	if _fled_state_active and not was_fled:
		passive_triggered.emit("Fled the State")


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _is_fleeing:
		return  # Invincible during flee
	super.take_damage(amount, unblockable)


func get_effective_speed() -> float:
	var base := super.get_effective_speed()
	if _fled_state_active:
		return base * 1.2
	return base


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Sleep zone at current position — grows from 120 to 200px over 2s
	# Put opponent to sleep (speed 0) for 2s if in range
	if opponent != null:
		var dist := abs(global_position.x - opponent.global_position.x)
		if dist <= 200.0:
			opponent.apply_temp_speed(0.0, 2.0)

	# Suitcase hit — 26 dmg
	if opponent != null:
		opponent.take_damage(26.0, false)
		on_damage_dealt(26.0)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_flee_cooldown = 0.0
	_is_fleeing = false
	_flee_timer = 0.0
	_fled_state_active = false
