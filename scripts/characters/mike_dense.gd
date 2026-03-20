class_name MikeDense
extends Fighter

## Holy Warrior — Has "Mother" NPC companion that auto-blocks one hit every 10s.
## Pray stance (block + up for 3s) charges next attack to 2x. Special grabs
## opponent, deals damage, reverses controls, and drains meter.

var _mother: MotherNPC = null
var _pray_timer: float = 0.0
var _pray_charged: bool = false
const PRAY_CHARGE_TIME: float = 3.0


func _ready() -> void:
	fighter_name = "Mike Dense"
	max_health = 105.0
	speed = 270.0
	jump_force = -490.0
	punch_damage = 9.0
	kick_damage = 10.0
	special_damage = 24.0
	special_name = "Conversion Therapy"
	super._ready()
	_spawn_mother()


func get_catchphrase() -> String:
	return "Mother wouldn't approve of this."


func _spawn_mother() -> void:
	_mother = MotherNPC.new()
	_mother.owner_fighter = self
	# Defer adding to tree until the node is in the tree
	if is_inside_tree():
		get_tree().current_scene.add_child(_mother)
	else:
		tree_entered.connect(_add_mother_to_tree, CONNECT_ONE_SHOT)


func _add_mother_to_tree() -> void:
	if _mother != null and is_instance_valid(_mother):
		get_tree().current_scene.add_child(_mother)


func handle_input(prefix: String) -> void:
	if is_attacking or is_taunting:
		return

	# Check pray stance: block (down) + up held simultaneously
	var down_held := Input.is_action_pressed(prefix + "down")
	var up_held := Input.is_action_pressed(prefix + "up")

	if down_held and up_held and is_on_floor():
		_pray_timer += get_physics_process_delta_time()
		if _pray_timer >= PRAY_CHARGE_TIME and not _pray_charged:
			_pray_charged = true
			passive_triggered.emit("Prayer Charged")
		# While praying, don't process other inputs
		velocity.x = 0
		return
	else:
		_pray_timer = 0.0

	super.handle_input(prefix)


func attack(type: String, damage: float) -> void:
	var final_damage := damage
	if _pray_charged:
		final_damage = damage * 2.0
		_pray_charged = false
		passive_triggered.emit("Holy Strike!")

	is_attacking = true
	on_damage_dealt(final_damage)
	on_hit_landed()
	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished
	is_attacking = false


func take_damage(amount: float, unblockable: bool = false) -> void:
	# "Mother Knows Best" — Mother blocks one hit every 10s
	if _mother != null and is_instance_valid(_mother) and _mother.try_block_hit():
		passive_triggered.emit("Mother Knows Best")
		return

	super.take_damage(amount, unblockable)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	if opponent != null:
		# 24 dmg grab
		opponent.take_damage(24.0, true)
		on_damage_dealt(24.0)

		# Reverse controls for 4 seconds (scramble left/right)
		var opp_prefix := "p2_" if is_player_one else "p1_"
		if input_manager != null:
			input_manager.scramble_input(opp_prefix, "left", "right", 4.0)
			input_manager.scramble_input(opp_prefix, "right", "left", 4.0)

		# Drain 30 special meter
		opponent.special_meter = max(opponent.special_meter - 30.0, 0.0)
		opponent.special_meter_changed.emit(opponent.special_meter)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_pray_timer = 0.0
	_pray_charged = false
	# Reset Mother
	if _mother != null and is_instance_valid(_mother):
		_mother.is_present = true
		_mother.visible = true
		_mother._cooldown_timer = 0.0
