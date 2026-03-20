class_name AnitaRiot
extends Fighter

## Punk Protest Queen / Disruptor — Rushdown who thrives in chaos.
## Every 4th hit scrambles a random opponent input.

const SCRAMBLE_ACTIONS: Array[String] = ["punch", "kick", "left", "right"]
const SCRAMBLE_DURATION: float = 3.0


func _ready() -> void:
	fighter_name = "Anita Riot"
	max_health = 90.0
	speed = 350.0
	jump_force = -520.0
	punch_damage = 8.0
	kick_damage = 9.0
	special_damage = 28.0
	special_name = "No Justice No Peace"
	super._ready()


func get_catchphrase() -> String:
	return "Your comfort was built on our silence. Sound check's over."


func on_hit_landed() -> void:
	super.on_hit_landed()
	# "Disruption" — every 4th hit scrambles a random opponent input
	if _hit_counter % 4 == 0 and _hit_counter > 0:
		_scramble_random_input()


func _scramble_random_input() -> void:
	if opponent == null or input_manager == null:
		return

	var opp_prefix := "p2_" if is_player_one else "p1_"

	# Pick two different random actions to swap
	var from_idx := randi() % SCRAMBLE_ACTIONS.size()
	var to_idx := (from_idx + 1 + randi() % (SCRAMBLE_ACTIONS.size() - 1)) % SCRAMBLE_ACTIONS.size()
	var from_action: String = SCRAMBLE_ACTIONS[from_idx]
	var to_action: String = SCRAMBLE_ACTIONS[to_idx]

	input_manager.scramble_input(opp_prefix, from_action, to_action, SCRAMBLE_DURATION)
	passive_triggered.emit("Disruption")


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Shockwave: 8 dmg + push opponent away
	if opponent != null:
		opponent.take_damage(8.0)
		on_damage_dealt(8.0)
		var push_dir := 1.0 if opponent.global_position.x > global_position.x else -1.0
		opponent.apply_knockback(push_dir, 400.0)

	# 4 phantom protester hits (5 dmg each)
	for i in range(4):
		if opponent != null:
			opponent.take_damage(5.0)
			on_damage_dealt(5.0)
		if anim_player and anim_player.has_animation("special"):
			anim_player.play("special")
			await anim_player.animation_finished

	is_attacking = false


func passive_proc(_delta: float) -> void:
	pass
