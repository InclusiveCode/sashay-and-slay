class_name MamaMolotov
extends Fighter

## Stonewall Veteran / Rage Tank — Brawler who gets more dangerous as she
## takes damage. Below 30% HP she enters Riot Mode.

var _riot_mode: bool = false


func _ready() -> void:
	fighter_name = "Mama Molotov"
	max_health = 130.0
	speed = 260.0
	jump_force = -480.0
	punch_damage = 11.0
	kick_damage = 13.0
	special_damage = 30.0
	special_name = "First Brick"
	super._ready()


func get_catchphrase() -> String:
	return "I've been fighting fascists since before you were a fundraising email."


func _is_riot_mode() -> bool:
	return health <= max_health * 0.3


func get_effective_punch() -> float:
	var base := super.get_effective_punch()
	if _is_riot_mode():
		return base * 1.4
	return base


func get_effective_kick() -> float:
	var base := super.get_effective_kick()
	if _is_riot_mode():
		return base * 1.4
	return base


func get_effective_speed() -> float:
	var base := super.get_effective_speed()
	if _is_riot_mode():
		return base * 1.3
	return base


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Unblockable projectile (30 dmg)
	spawn_projectile(30.0, 400.0, true)

	# Burning zone at opponent's position (3 dmg/s for 8s)
	if opponent != null:
		var zone := BurningZone.new()
		zone.damage_per_second = 3.0
		zone.duration = 8.0
		zone.zone_width = 100.0
		zone.owner_fighter = self
		zone.position = opponent.global_position
		get_tree().current_scene.add_child(zone)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


## "We Were Always Here" — 20% reduced knockback
func apply_knockback(direction: float, force: float) -> void:
	var kb = force * get_knockback_modifier() * 0.8
	velocity.x += direction * kb


func passive_proc(_delta: float) -> void:
	# Riot Mode is checked dynamically via _is_riot_mode()
	var was_riot := _riot_mode
	_riot_mode = _is_riot_mode()
	if _riot_mode and not was_riot:
		passive_triggered.emit("Riot Mode")


func reset_round_state() -> void:
	super.reset_round_state()
	_riot_mode = false
