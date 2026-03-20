extends Control

## Character selection screen — adapts to versus or arcade mode via RosterRegistry.

signal character_selected(player: int, character_id: String)

var p1_selected: String = ""
var p2_selected: String = ""

# Color constants for team-based button styling
const COLOR_QUEENS := Color(1.0, 0.4, 0.7)      # pink
const COLOR_POLITICIANS := Color(0.9, 0.2, 0.2)  # red
const COLOR_BOSS := Color(1.0, 0.84, 0.0)        # gold


func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var mode := "versus"
	if gm:
		mode = gm.current_mode

	if mode == "arcade":
		$Title.text = "CHOOSE YOUR QUEEN"
		_build_roster_grid(RosterRegistry.get_arcade_roster())
	else:
		$Title.text = "CHOOSE YOUR FIGHTER"
		var don_unlocked := false
		if gm:
			don_unlocked = gm.don_unlocked
		_build_roster_grid(RosterRegistry.get_versus_roster(don_unlocked))


func _build_roster_grid(roster: Dictionary) -> void:
	for fighter_name in roster:
		var data: Dictionary = roster[fighter_name]
		var btn := Button.new()
		btn.text = fighter_name
		btn.custom_minimum_size = Vector2(150, 80)
		btn.pressed.connect(_on_character_button_pressed.bind(fighter_name))

		# Color-code by team
		var style := StyleBoxFlat.new()
		match data["team"]:
			"queens":
				style.bg_color = COLOR_QUEENS
			"politicians":
				style.bg_color = COLOR_POLITICIANS
			"boss":
				style.bg_color = COLOR_BOSS
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		btn.add_theme_stylebox_override("normal", style)

		if has_node("RosterGrid"):
			$RosterGrid.add_child(btn)


func _on_character_button_pressed(fighter_name: String) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var mode := "versus"
	if gm:
		mode = gm.current_mode

	if mode == "arcade":
		# In arcade mode, one selection starts the run
		p1_selected = fighter_name
		character_selected.emit(1, fighter_name)
		if gm:
			gm.start_arcade_mode(fighter_name)
		get_tree().change_scene_to_file("res://scenes/fight.tscn")
	else:
		# Versus mode: P1 then P2
		if p1_selected == "":
			p1_selected = fighter_name
			character_selected.emit(1, fighter_name)
		elif p2_selected == "":
			p2_selected = fighter_name
			character_selected.emit(2, fighter_name)
			_start_fight()


func _start_fight() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.p1_character = p1_selected
		gm.p2_character = p2_selected
	get_tree().change_scene_to_file("res://scenes/fight.tscn")
