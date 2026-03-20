class_name MarjorieTrailerQueen
extends Fighter

## Chaotic Rushdown — 20% chance for 1.5x damage, 10% chance to hit self.
## Passive guarantees 1.5x on next attack after taking 10+ dmg.

var _guaranteed_crit: bool = false


func _ready() -> void:
	fighter_name = "Marjorie Trailer Queen"
	max_health = 95.0
	speed = 330.0
	jump_force = -520.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 30.0
	special_name = "Jewish Space Laser"
	super._ready()


func get_catchphrase() -> String:
	return "I did my own research! On Facebook!"


func attack(type: String, damage: float) -> void:
	is_attacking = true

	# Check chaos rolls
	var final_damage := damage
	var hit_self := false

	if _guaranteed_crit:
		final_damage = damage * 1.5
		_guaranteed_crit = false
		passive_triggered.emit("Guaranteed Crit")
	else:
		var roll := randf()
		if roll < 0.10:
			# 10% chance to hit self
			hit_self = true
			final_damage = damage * 0.5
		elif roll < 0.30:
			# 20% chance for 1.5x (roll 0.10–0.30)
			final_damage = damage * 1.5

	if hit_self:
		take_damage(final_damage, true)
	else:
		on_damage_dealt(final_damage)
		on_hit_landed()

	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished

	is_attacking = false


func take_damage(amount: float, unblockable: bool = false) -> void:
	super.take_damage(amount, unblockable)
	# "Do Your Own Research" — after taking 10+ dmg, next hit is guaranteed 1.5x
	if amount >= 10.0:
		_guaranteed_crit = true
		passive_triggered.emit("Do Your Own Research")


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# 30 dmg tracking hit on opponent
	if opponent != null:
		opponent.take_damage(30.0, false)
		on_damage_dealt(30.0)

	# Burning zone that hurts everyone (including Marjorie)
	var zone := spawn_burning_zone(4.0, 4.0, 120.0)
	zone.set_hurts_everyone(true)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_guaranteed_crit = false
