extends Control

## Main menu screen - Sashay & Slay!


func _ready() -> void:
	$VBoxContainer/VersusButton.pressed.connect(_on_versus_pressed)
	$VBoxContainer/ArcadeButton.pressed.connect(_on_arcade_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_versus_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.current_mode = "versus"
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_arcade_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.current_mode = "arcade"
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
