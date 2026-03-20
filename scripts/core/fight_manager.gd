extends Node

## Orchestrates a fight scene — loads fighters and stage, wires signals,
## manages rounds, and handles match-end transitions.

var p1: Fighter = null
var p2: Fighter = null
var stage: Stage = null
var hud: CanvasLayer = null
var gm: Node = null


func _ready() -> void:
	gm = get_node_or_null("/root/GameManager")
	if not gm:
		push_error("FightManager: GameManager autoload not found")
		return

	hud = get_node_or_null("../HUD")

	gm.setup_input_manager()
	_load_fighters()
	_load_stage()
	_connect_signals()
	gm.start_match()

	if hud and gm.current_mode == "arcade":
		hud.show_announcement(gm.arcade.get_progress_text(), 2.0)


func _load_fighters() -> void:
	# Create P1
	p1 = RosterRegistry.create_fighter(gm.p1_character)
	if p1:
		p1.is_player_one = true
		p1.position = Vector2(300, 580)
		p1.facing_right = true
		get_parent().add_child(p1)
		gm.register_fighter(p1)

	# Create P2
	p2 = RosterRegistry.create_fighter(gm.p2_character)
	if p2:
		p2.is_player_one = false
		p2.position = Vector2(980, 580)
		p2.facing_right = false
		get_parent().add_child(p2)
		gm.register_fighter(p2)

	# Set opponent references
	if p1 and p2:
		p1.opponent = p2
		p2.opponent = p1

	# Wire cross-fighter passive signals (e.g., Ron's Parental Advisory)
	if p1 and p2:
		_wire_passive_signals(p1, p2)
		_wire_passive_signals(p2, p1)


func _wire_passive_signals(fighter: Fighter, other: Fighter) -> void:
	# Ron DeSanctimonious reacts to opponent using special
	if other.has_method("_on_opponent_used_special"):
		fighter.special_used.connect(other._on_opponent_used_special)


func _load_stage() -> void:
	var stage_key := ""
	if gm.current_mode == "arcade":
		stage_key = gm.arcade.get_current_stage()
	else:
		# Versus mode: pick a random stage
		var all_stages := StageRegistry.get_all_stage_names()
		if all_stages.size() > 0:
			stage_key = all_stages[randi() % all_stages.size()]

	if stage_key != "" and stage_key in StageRegistry.STAGE_SCRIPTS:
		var script_path: String = StageRegistry.STAGE_SCRIPTS[stage_key]
		var stage_script: GDScript = load(script_path)
		stage = stage_script.new()
		var stage_node := get_node_or_null("../Stage")
		if stage_node:
			stage_node.add_child(stage)
		if p1 and p2:
			var fighter_list: Array[Fighter] = [p1, p2]
			stage.set_fighters(fighter_list)


func _connect_signals() -> void:
	if p1:
		p1.health_changed.connect(_on_health_changed.bind(1))
		p1.special_meter_changed.connect(_on_special_changed.bind(1))
		p1.secondary_resource_changed.connect(_on_secondary_changed.bind(1))
		p1.defeated.connect(_on_fighter_defeated.bind("p2"))

	if p2:
		p2.health_changed.connect(_on_health_changed.bind(2))
		p2.special_meter_changed.connect(_on_special_changed.bind(2))
		p2.secondary_resource_changed.connect(_on_secondary_changed.bind(2))
		p2.defeated.connect(_on_fighter_defeated.bind("p1"))

	if gm:
		gm.round_started.connect(_on_round_started)
		gm.match_ended.connect(_on_match_end)


func _on_health_changed(new_health: float, player: int) -> void:
	if hud:
		var max_hp := p1.max_health if player == 1 else p2.max_health
		hud.update_health(player, new_health, max_hp)


func _on_special_changed(new_value: float, player: int) -> void:
	if hud:
		hud.update_special(player, new_value)


func _on_secondary_changed(new_value: float, player: int) -> void:
	if hud:
		hud.update_secondary(player, new_value)


func _on_round_started(round_num: int) -> void:
	if hud and hud.has_node("RoundLabel"):
		hud.get_node("RoundLabel").text = "Round %d" % round_num

	# Reset fighters for the new round
	if round_num > 1:
		_reset_fighters_for_round()


func _reset_fighters_for_round() -> void:
	if p1:
		p1.health = p1.max_health
		p1.health_changed.emit(p1.health)
		p1.reset_round_state()
		p1.position = Vector2(300, 580)
	if p2:
		p2.health = p2.max_health
		p2.health_changed.emit(p2.health)
		p2.reset_round_state()
		p2.position = Vector2(980, 580)
	if gm:
		gm.broadcast_round_reset()


func _on_fighter_defeated(winner: String) -> void:
	if gm:
		gm.end_round(winner)


func _on_match_end(winner: String) -> void:
	if not gm:
		return

	if gm.current_mode == "arcade":
		if winner == "p1":
			gm.arcade_advance()
			if gm.arcade.is_complete():
				# Arcade complete — go to victory screen
				gm.victory_mode = "arcade_complete"
				gm.victory_winner = gm.p1_character
				get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
			else:
				# Next opponent
				gm.p2_character = gm.arcade.get_current_opponent()
				get_tree().change_scene_to_file("res://scenes/fight.tscn")
		else:
			# Player lost in arcade
			gm.victory_mode = "arcade_defeat"
			gm.victory_winner = gm.p2_character
			get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
	else:
		# Versus mode
		gm.victory_mode = "versus"
		gm.victory_winner = gm.p1_character if winner == "p1" else gm.p2_character
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")


func _process(_delta: float) -> void:
	if not gm:
		return
	if gm.current_state != gm.GameState.FIGHTING:
		return

	# Countdown timer
	gm.time_remaining -= _delta
	if gm.time_remaining <= 0.0:
		gm.time_remaining = 0.0
		_handle_timeout()

	if hud:
		hud.update_timer(gm.time_remaining)


func _handle_timeout() -> void:
	# Whoever has more health wins; tie goes to P1
	if p1 and p2:
		if p1.health >= p2.health:
			_on_fighter_defeated("p1")
		else:
			_on_fighter_defeated("p2")
