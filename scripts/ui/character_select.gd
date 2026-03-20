extends Control

## Character selection screen.

signal character_selected(player: int, character_id: String)

const ROSTER := {
	# Drag Queens
	"glitterina": {"name": "Glitterina", "team": "queens", "special": "Death Drop", "catchphrase": "Time to slay, darling!"},
	"lady_liberty": {"name": "Lady Liberty", "team": "queens", "special": "Freedom Shade", "catchphrase": "Liberty and lip sync for ALL!"},
	"miss_fire": {"name": "Miss Fire", "team": "queens", "special": "Flame Fatale", "catchphrase": "Too hot to handle, too fierce to hold!"},
	"anita_win": {"name": "Anita Win", "team": "queens", "special": "Read to Filth", "catchphrase": "The library is OPEN!"},
	# Politicians
	"senator_stonewall": {"name": "Senator Stonewall", "team": "politicians", "special": "Filibuster Fury", "catchphrase": "Order! ORDER!"},
	"mayor_mccheese": {"name": "Mayor McBudget", "team": "politicians", "special": "Tax Attack", "catchphrase": "This is coming out of YOUR pocket!"},
	"governor_gridlock": {"name": "Governor Gridlock", "team": "politicians", "special": "Executive Disorder", "catchphrase": "Motion denied!"},
	"rep_robocall": {"name": "Rep. Robocall", "team": "politicians", "special": "Spam Slam", "catchphrase": "Have you heard about my campaign?!"},
}

var p1_selected: String = ""
var p2_selected: String = ""


func _ready() -> void:
	_build_roster_grid()


func _build_roster_grid() -> void:
	# Populate character buttons from ROSTER
	for char_id in ROSTER:
		var data = ROSTER[char_id]
		var btn = Button.new()
		btn.text = data["name"]
		btn.custom_minimum_size = Vector2(150, 80)
		btn.pressed.connect(_on_character_button_pressed.bind(char_id))
		if has_node("RosterGrid"):
			$RosterGrid.add_child(btn)


func _on_character_button_pressed(char_id: String) -> void:
	if p1_selected == "":
		p1_selected = char_id
		character_selected.emit(1, char_id)
	elif p2_selected == "":
		p2_selected = char_id
		character_selected.emit(2, char_id)
		_start_fight()


func _start_fight() -> void:
	# Store selections in GameManager autoload and transition to fight
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.p1_character = p1_selected
		gm.p2_character = p2_selected
	get_tree().change_scene_to_file("res://scenes/fight.tscn")
