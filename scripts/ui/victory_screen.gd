extends Control

## Victory/defeat screen — displays match result based on GameManager.victory_mode.


func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return

	var title_label := $VBoxContainer/TitleLabel
	var catchphrase_label := $VBoxContainer/CatchphraseLabel
	var continue_button := $VBoxContainer/ContinueButton

	match gm.victory_mode:
		"versus":
			title_label.text = "%s WINS!" % gm.victory_winner.to_upper()
			var catchphrase := _get_catchphrase(gm.victory_winner)
			catchphrase_label.text = "\"%s\"" % catchphrase

		"arcade_complete":
			title_label.text = "CONGRATULATIONS!"
			var catchphrase := _get_catchphrase(gm.victory_winner)
			catchphrase_label.text = "\"%s\"\n\nDon the Con UNLOCKED!" % catchphrase

		"arcade_defeat":
			title_label.text = "DEFEATED..."
			catchphrase_label.text = "The fight isn't over. Get back up and try again."

		_:
			title_label.text = "MATCH OVER"
			catchphrase_label.text = ""

	continue_button.pressed.connect(_on_continue_pressed)


func _get_catchphrase(fighter_name: String) -> String:
	var all_data := {}
	all_data.merge(RosterRegistry.QUEENS)
	all_data.merge(RosterRegistry.POLITICIANS)
	all_data.merge(RosterRegistry.BOSS)
	if fighter_name in all_data:
		return all_data[fighter_name]["catchphrase"]
	return "..."


func _on_continue_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.reset_to_menu()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
