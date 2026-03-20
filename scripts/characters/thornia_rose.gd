class_name ThorniaRose
extends Fighter

## Bearded Queen / Eco-Witch / Zone Controller — Area denial specialist.
## Plants thorns with kick, grows vines, poisons the ground.

var _active_thorns: Array[Thorn] = []
const MAX_THORNS: int = 5


func _ready() -> void:
	fighter_name = "Thornia Rose"
	max_health = 100.0
	speed = 280.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 9.0
	special_damage = 25.0
	special_name = "Reclaiming My Thyme"
	super._ready()


func get_catchphrase() -> String:
	return "Nature doesn't negotiate. Neither do I."


func attack(type: String, damage: float) -> void:
	if type == "kick":
		# Kick plants a thorn at current position
		_plant_thorn()
		# Still deal kick damage normally
		super.attack(type, damage)
	else:
		super.attack(type, damage)


func _plant_thorn() -> void:
	# Remove oldest thorn if at max
	_cleanup_freed_thorns()
	if _active_thorns.size() >= MAX_THORNS:
		var oldest := _active_thorns.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var thorn := Thorn.new()
	thorn.owner_fighter = self
	thorn.position = global_position
	get_tree().current_scene.add_child(thorn)
	_active_thorns.append(thorn)


func _cleanup_freed_thorns() -> void:
	var valid_thorns: Array[Thorn] = []
	for t in _active_thorns:
		if is_instance_valid(t):
			valid_thorns.append(t)
	_active_thorns = valid_thorns


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# "Reclaiming My Thyme" — root opponent + DOT
	if opponent != null:
		# Root: speed 0 for 3 seconds
		opponent.apply_temp_speed(0.0, 3.0)

		# DOT: 5 dmg/s for 5s via burning zone (reused as poison zone)
		var zone := BurningZone.new()
		zone.damage_per_second = 5.0
		zone.duration = 5.0
		zone.zone_width = 80.0
		zone.owner_fighter = self
		zone.position = opponent.global_position
		get_tree().current_scene.add_child(zone)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func passive_proc(_delta: float) -> void:
	# "Overgrowth" — thorn damage scaling is handled in Thorn._age
	pass


func reset_round_state() -> void:
	super.reset_round_state()
	# Clear all active thorns between rounds
	for thorn in _active_thorns:
		if is_instance_valid(thorn):
			thorn.queue_free()
	_active_thorns.clear()
