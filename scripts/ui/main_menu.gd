extends Control

## Main menu screen - Sashay & Slay!


func _ready() -> void:
	$VBoxContainer/FightButton.pressed.connect(_on_fight_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_fight_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
