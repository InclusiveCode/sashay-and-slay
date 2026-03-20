extends Node

## Manages game state, rounds, and match flow.

signal round_started(round_number: int)
signal round_ended(winner: String)
signal match_ended(winner: String)

enum GameState { MENU, CHARACTER_SELECT, FIGHTING, ROUND_END, MATCH_END, PAUSED }

const ROUNDS_TO_WIN := 2
const ROUND_TIME := 90.0

var current_state: GameState = GameState.MENU
var round_number := 0
var p1_wins := 0
var p2_wins := 0
var p1_character: String = ""
var p2_character: String = ""
var time_remaining := ROUND_TIME


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
