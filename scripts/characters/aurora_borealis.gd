class_name AuroraBorealis
extends Fighter

## Cosmic Nonbinary Queen / Light Wielder — Ranged hybrid with self-sustain.
## Punch fires beam projectile, double jump, spectral shield passive.

var _has_double_jump: bool = true
var _damage_absorbed: float = 0.0
var _shield_charged: bool = false
const SHIELD_THRESHOLD: float = 30.0
const SHIELD_REFLECT_DAMAGE: float = 8.0


func _ready() -> void:
	fighter_name = "Aurora Borealis"
	max_health = 95.0
	speed = 300.0
	jump_force = -480.0
	punch_damage = 6.0
	kick_damage = 7.0
	special_damage = 28.0
	special_name = "Prismatic Judgment"
	super._ready()


func get_catchphrase() -> String:
	return "You tried to erase us from the sky. Look up."


func handle_input(prefix: String) -> void:
	if is_attacking or is_taunting:
		return

	# Movement
	var direction := Input.get_axis(prefix + "left", prefix + "right")
	velocity.x = direction * get_effective_speed()

	if direction != 0:
		facing_right = direction > 0

	# Jump with double jump support
	if Input.is_action_just_pressed(prefix + "up"):
		if is_on_floor():
			velocity.y = jump_force
			_has_double_jump = true
		elif _has_double_jump:
			velocity.y = jump_force
			_has_double_jump = false

	# Reset double jump when landing
	if is_on_floor():
		_has_double_jump = true

	# Blocking
	if not _is_action_banned(prefix + "down"):
		is_blocking = Input.is_action_pressed(prefix + "down") and is_on_floor()
	else:
		is_blocking = false

	# Punch — fires beam projectile instead of melee
	var punch_action := _get_remapped(prefix + "punch")
	if not _is_action_banned(prefix + "punch") and Input.is_action_just_pressed(punch_action):
		attack("punch", get_effective_punch())
	# Kick — normal melee
	elif not _is_action_banned(prefix + "kick"):
		var kick_action := _get_remapped(prefix + "kick")
		if Input.is_action_just_pressed(kick_action):
			attack("kick", get_effective_kick())
	# Special
	if not _is_action_banned(prefix + "special") and Input.is_action_just_pressed(prefix + "special") and special_meter >= 100.0:
		use_special()
	# Taunt
	if not _is_action_banned(prefix + "taunt") and Input.is_action_just_pressed(prefix + "taunt"):
		start_taunt()


func attack(type: String, damage: float) -> void:
	if type == "punch":
		# Punch fires a beam projectile instead of melee
		is_attacking = true
		spawn_projectile(damage, 500.0, false)
		on_damage_dealt(damage)
		on_hit_landed()
		if anim_player:
			anim_player.play("punch")
			await anim_player.animation_finished
		is_attacking = false
	else:
		super.attack(type, damage)


func take_damage(amount: float, unblockable: bool = false) -> void:
	# "Spectral Shield" — absorb hit and reflect
	if _shield_charged:
		_shield_charged = false
		# Absorb completely (0 damage taken)
		# Reflect as rainbow projectile
		spawn_projectile(SHIELD_REFLECT_DAMAGE, 400.0, false)
		passive_triggered.emit("Spectral Shield")
		return

	super.take_damage(amount, unblockable)

	# Track total damage for shield charging
	var actual_damage := amount
	if is_blocking and not unblockable:
		actual_damage = amount * 0.2
	_damage_absorbed += actual_damage
	if _damage_absorbed >= SHIELD_THRESHOLD and not _shield_charged:
		_shield_charged = true
		_damage_absorbed = 0.0


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# "Prismatic Judgment" — ascend + 28 dmg + heal 20% of damage dealt
	if opponent != null:
		var dmg := 28.0
		opponent.take_damage(dmg)
		on_damage_dealt(dmg)

		# Heal 20% of damage dealt
		var heal_amount := dmg * 0.2
		health = min(health + heal_amount, max_health)
		health_changed.emit(health)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func passive_proc(_delta: float) -> void:
	pass


func reset_round_state() -> void:
	super.reset_round_state()
	_has_double_jump = true
	_damage_absorbed = 0.0
	_shield_charged = false
