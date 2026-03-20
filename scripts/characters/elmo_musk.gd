class_name ElmoMusk
extends Fighter

## Gadget / Resource fighter — Has Capital resource (starts 50, +1/sec, max 100).
## Taunt deploys attack drone (15 Capital). Max 2 drones active.
## Opponent destroying drones refunds 150% Capital.

const CAPITAL_START: float = 50.0
const CAPITAL_PER_SEC: float = 1.0
const ATTACK_DRONE_COST: int = 15
const SHIELD_DRONE_COST: int = 25
const MAX_DRONES: int = 2

var _active_drones: Array = []


func _ready() -> void:
	fighter_name = "Elmo Musk"
	max_health = 100.0
	speed = 290.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 28.0
	special_name = "Hostile Takeover"
	secondary_resource_max = 100.0
	super._ready()
	set_secondary_resource(CAPITAL_START)


func get_catchphrase() -> String:
	return "I'm not a villain. I'm a disruptor. Same thing."


func passive_proc(delta: float) -> void:
	# Capital generation: +1/sec
	set_secondary_resource(secondary_resource + CAPITAL_PER_SEC * delta)

	# Clean up freed drones from list
	_active_drones = _active_drones.filter(func(d): return is_instance_valid(d))


func on_taunt_complete() -> void:
	# Deploy attack drone if affordable and under limit
	_active_drones = _active_drones.filter(func(d): return is_instance_valid(d))
	if secondary_resource >= ATTACK_DRONE_COST and _active_drones.size() < MAX_DRONES:
		_deploy_attack_drone()


func _deploy_attack_drone() -> void:
	set_secondary_resource(secondary_resource - ATTACK_DRONE_COST)

	var drone := AttackDrone.new()
	drone.owner_fighter = self
	drone.target_fighter = opponent
	drone.capital_cost = ATTACK_DRONE_COST
	drone.drone_destroyed.connect(_on_drone_destroyed)
	_active_drones.append(drone)
	get_tree().current_scene.add_child(drone)


func deploy_shield_drone() -> void:
	_active_drones = _active_drones.filter(func(d): return is_instance_valid(d))
	if secondary_resource >= SHIELD_DRONE_COST and _active_drones.size() < MAX_DRONES:
		set_secondary_resource(secondary_resource - SHIELD_DRONE_COST)

		var drone := ShieldDrone.new()
		drone.owner_fighter = self
		drone.capital_cost = SHIELD_DRONE_COST
		drone.drone_destroyed.connect(_on_shield_drone_destroyed)
		_active_drones.append(drone)
		get_tree().current_scene.add_child(drone)


func take_damage(amount: float, unblockable: bool = false) -> void:
	# Check for shield drone absorption
	for drone in _active_drones:
		if drone is ShieldDrone and is_instance_valid(drone):
			if drone.absorb_hit():
				return  # Hit absorbed

	super.take_damage(amount, unblockable)


## "Move Fast Break Things" — opponent destroying drone refunds 150% Capital
func _on_drone_destroyed(drone: AttackDrone) -> void:
	var refund := drone.capital_cost * 1.5
	set_secondary_resource(secondary_resource + refund)
	passive_triggered.emit("Move Fast Break Things")
	_active_drones.erase(drone)


func _on_shield_drone_destroyed(drone: ShieldDrone) -> void:
	var refund := drone.capital_cost * 1.5
	set_secondary_resource(secondary_resource + refund)
	passive_triggered.emit("Move Fast Break Things")
	_active_drones.erase(drone)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Stun opponent for 1 second
	if opponent != null:
		opponent.apply_temp_speed(0.0, 1.0)

	# Electric floor — 2 dmg/s for 6s
	spawn_burning_zone(2.0, 6.0, 300.0)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	# Destroy all active drones
	for drone in _active_drones:
		if is_instance_valid(drone):
			drone.queue_free()
	_active_drones.clear()
	set_secondary_resource(CAPITAL_START)
