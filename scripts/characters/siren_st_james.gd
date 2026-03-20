class_name SirenStJames
extends Fighter

## Pageant Assassin / Ice Queen — Slow, devastating precision.
## Standing still charges super armor on the next attack.

var _still_timer: float = 0.0
var _has_super_armor: bool = false
var _super_armor_active: bool = false  # True while mid-attack with armor
const STILL_THRESHOLD: float = 2.0


func _ready() -> void:
	fighter_name = "Siren St. James"
	max_health = 105.0
	speed = 240.0
	jump_force = -480.0
	punch_damage = 12.0
	kick_damage = 14.0
	special_damage = 32.0
	special_name = "Miss Congeniality"
	super._ready()


func get_catchphrase() -> String:
	return "I'd wish you luck, but it won't help."


func passive_proc(delta: float) -> void:
	# "Poise Under Pressure" — standing still for 2s grants super armor
	if velocity.x == 0 and is_on_floor() and not is_attacking and not is_taunting:
		_still_timer += delta
		if _still_timer >= STILL_THRESHOLD and not _has_super_armor:
			_has_super_armor = true
			passive_triggered.emit("Poise Under Pressure")
	else:
		_still_timer = 0.0


func attack(type: String, damage: float) -> void:
	# Activate super armor for this attack if charged
	if _has_super_armor:
		_super_armor_active = true
		_has_super_armor = false
	super.attack(type, damage)
	_super_armor_active = false


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _super_armor_active:
		# Absorb one hit without flinching — still take damage but don't interrupt
		if is_blocking and not unblockable:
			amount *= 0.2
		health -= amount
		health = max(health, 0.0)
		health_changed.emit(health)
		special_meter = min(special_meter + amount * 0.5, 100.0)
		special_meter_changed.emit(special_meter)
		_super_armor_active = false
		if health <= 0:
			defeated.emit()
		return
	super.take_damage(amount, unblockable)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Kiss projectile (0 dmg) — stuns on hit
	spawn_projectile(0.0, 400.0, false)

	# 3-hit scepter combo: 8 + 10 + 14
	var hit_damages: Array[float] = [8.0, 10.0, 14.0]
	for dmg in hit_damages:
		if opponent != null:
			opponent.take_damage(dmg)
			on_damage_dealt(dmg)
		if anim_player and anim_player.has_animation("special"):
			anim_player.play("special")
			await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_still_timer = 0.0
	_has_super_armor = false
	_super_armor_active = false
