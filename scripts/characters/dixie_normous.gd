class_name DixieNormous
extends Fighter

## Southern Comedy Queen / Psychological Warfare — Debuff queen who
## dismantles opponents piece by piece. Kick attacks are "reads" that
## permanently reduce opponent stats for the round.

var _last_attack_was_read: bool = false


func _ready() -> void:
	fighter_name = "Dixie Normous"
	max_health = 100.0
	speed = 290.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 22.0
	special_name = "The Library Is Open"
	super._ready()


func get_catchphrase() -> String:
	return "Oh honey, I'm not being mean. The truth just hurts when it's this well-accessorized."


func attack(type: String, damage: float) -> void:
	is_attacking = true

	if type == "kick" and opponent != null:
		# Kick attacks are "reads" — apply stat reduction on hit
		opponent.apply_stat_reduction()
		_last_attack_was_read = true

	on_damage_dealt(damage)
	on_hit_landed()

	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished

	is_attacking = false


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# "The Library Is Open" — 5-hit combo (4+4+4+4+6)
	# Each hit applies stat reduction, final drains meter
	var hit_damages: Array[float] = [4.0, 4.0, 4.0, 4.0, 6.0]

	for i in range(hit_damages.size()):
		if opponent != null:
			opponent.take_damage(hit_damages[i])
			on_damage_dealt(hit_damages[i])
			opponent.apply_stat_reduction()

			# Final hit drains opponent's special meter
			if i == hit_damages.size() - 1:
				opponent.special_meter = 0.0
				opponent.special_meter_changed.emit(opponent.special_meter)

		if anim_player and anim_player.has_animation("special"):
			anim_player.play("special")
			await anim_player.animation_finished

	is_attacking = false


## "Bless Your Heart" — taunting after a successful read heals 5 HP
func on_taunt_complete() -> void:
	if _last_attack_was_read:
		health = min(health + 5.0, max_health)
		health_changed.emit(health)
		_last_attack_was_read = false
		passive_triggered.emit("Bless Your Heart")


func passive_proc(_delta: float) -> void:
	pass


func reset_round_state() -> void:
	super.reset_round_state()
	_last_attack_was_read = false
