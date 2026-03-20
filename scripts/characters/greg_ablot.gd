class_name GregAblot
extends Fighter

## Trap Specialist — Kick places barriers (max 3). Gains 30% DR behind own
## barriers. Special pushes opponent into barriers for bonus damage.

var _barriers: Array = []
const MAX_BARRIERS: int = 3
const BARRIER_DR: float = 0.30


func _ready() -> void:
	fighter_name = "Greg Ablot"
	max_health = 110.0
	speed = 260.0
	jump_force = -480.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 26.0
	special_name = "Operation Lone Star"
	super._ready()


func get_catchphrase() -> String:
	return "This stage is CLOSED."


func attack(type: String, damage: float) -> void:
	if type == "kick":
		_place_barrier()
		# Still animate the kick
		is_attacking = true
		if anim_player:
			anim_player.play("kick")
			await anim_player.animation_finished
		is_attacking = false
		return

	# Normal punch attack
	super.attack(type, damage)


func _place_barrier() -> void:
	_barriers = _barriers.filter(func(b): return is_instance_valid(b))

	# Remove oldest if at max
	if _barriers.size() >= MAX_BARRIERS:
		var oldest = _barriers.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var barrier := Barrier.new()
	barrier.owner_fighter = self
	barrier.position = global_position + Vector2(60.0 if facing_right else -60.0, 0.0)
	barrier.barrier_destroyed.connect(_on_barrier_destroyed)
	_barriers.append(barrier)
	get_tree().current_scene.add_child(barrier)


func _on_barrier_destroyed(barrier: Barrier) -> void:
	_barriers.erase(barrier)


func _is_behind_barrier() -> bool:
	_barriers = _barriers.filter(func(b): return is_instance_valid(b))
	for barrier in _barriers:
		if not is_instance_valid(barrier):
			continue
		# "Behind" means barrier is between self and opponent
		if opponent != null:
			var barrier_x: float = barrier.position.x
			var self_x: float = position.x
			var opp_x: float = opponent.position.x
			# Barrier is between us if it's between our x positions
			if (self_x < barrier_x and barrier_x < opp_x) or \
			   (opp_x < barrier_x and barrier_x < self_x):
				return true
	return false


func take_damage(amount: float, unblockable: bool = false) -> void:
	# "Pulled Up the Ladder" — 30% DR when behind own barrier
	if _is_behind_barrier():
		amount *= (1.0 - BARRIER_DR)
		passive_triggered.emit("Pulled Up the Ladder")

	super.take_damage(amount, unblockable)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	if opponent != null:
		# 4 hits x 6.5 dmg, push toward nearest barrier
		var total_dmg: float = 0.0
		for i in range(4):
			opponent.take_damage(6.5, false)
			total_dmg += 6.5

		# Push opponent toward nearest barrier
		var push_dir := 1.0 if facing_right else -1.0
		opponent.apply_knockback(push_dir, 400.0)

		# Check if opponent will collide with a barrier (bonus 8 dmg)
		_barriers = _barriers.filter(func(b): return is_instance_valid(b))
		for barrier in _barriers:
			if is_instance_valid(barrier):
				var dist := abs(opponent.position.x - barrier.position.x)
				if dist < 80.0:
					opponent.take_damage(8.0, true)
					total_dmg += 8.0
					break

		on_damage_dealt(total_dmg)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	# Destroy all barriers
	for barrier in _barriers:
		if is_instance_valid(barrier):
			barrier.queue_free()
	_barriers.clear()
