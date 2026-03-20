extends Node

## Manages game state, rounds, and match flow.

signal round_started(round_number: int)
signal round_ended(winner: String)
signal match_ended(winner: String)
signal round_reset()

enum GameState { MENU, CHARACTER_SELECT, FIGHTING, ROUND_END, MATCH_END, PAUSED }

const ROUNDS_TO_WIN := 2
const ROUND_TIME := 90.0
const SAVE_PATH := "user://save.cfg"

var current_state: GameState = GameState.MENU
var round_number := 0
var p1_wins := 0
var p2_wins := 0
var p1_character: String = ""
var p2_character: String = ""
var time_remaining := ROUND_TIME

var fighters: Array[Fighter] = []
var input_manager: InputManager = null
var don_unlocked: bool = false
var current_mode: String = "versus"

var arcade: ArcadeManager = ArcadeManager.new()
var victory_mode: String = ""
var victory_winner: String = ""


func _ready() -> void:
	_load_unlock()


func start_match() -> void:
	p1_wins = 0
	p2_wins = 0
	round_number = 0
	start_round()


func start_round() -> void:
	round_number += 1
	time_remaining = ROUND_TIME
	current_state = GameState.FIGHTING
	round_started.emit(round_number)


func end_round(winner: String) -> void:
	current_state = GameState.ROUND_END
	if winner == "p1":
		p1_wins += 1
	elif winner == "p2":
		p2_wins += 1
	round_ended.emit(winner)

	if p1_wins >= ROUNDS_TO_WIN:
		end_match("p1")
	elif p2_wins >= ROUNDS_TO_WIN:
		end_match("p2")
	else:
		# Brief pause then next round
		await get_tree().create_timer(2.0).timeout
		start_round()


func end_match(winner: String) -> void:
	current_state = GameState.MATCH_END
	match_ended.emit(winner)


func reset_to_menu() -> void:
	current_state = GameState.MENU
	p1_character = ""
	p2_character = ""


func register_fighter(fighter: Fighter) -> void:
	fighters.append(fighter)
	fighter.input_manager = input_manager


func setup_input_manager() -> void:
	input_manager = InputManager.new()
	add_child(input_manager)
	for fighter in fighters:
		fighter.input_manager = input_manager


func broadcast_round_reset() -> void:
	for fighter in fighters:
		fighter.reset_round_state()
	round_reset.emit()


func unlock_don() -> void:
	don_unlocked = true
	_save_unlock()


func start_arcade_mode(queen_name: String) -> void:
	current_mode = "arcade"
	arcade.start(queen_name)
	p1_character = queen_name
	p2_character = arcade.get_current_opponent()


func arcade_advance() -> void:
	arcade.advance()
	if arcade.is_complete():
		unlock_don()
		victory_mode = "arcade_complete"
		victory_winner = p1_character
	else:
		p2_character = arcade.get_current_opponent()


func _save_unlock() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "don_unlocked", don_unlocked)
	config.save(SAVE_PATH)


func _load_unlock() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		don_unlocked = config.get_value("progress", "don_unlocked", false)
