class_name ArcadeManager
extends RefCounted

## Manages arcade mode progression — tracks the selected queen, shuffled
## opponent queue, current fight index, and boss fight state.

var queen_name: String = ""
var opponent_queue: Array = []
var current_opponent_index: int = 0
var is_active: bool = false


## Initialises a new arcade run for the given queen.
func start(selected_queen: String) -> void:
	queen_name = selected_queen
	opponent_queue = RosterRegistry.get_arcade_opponents()
	current_opponent_index = 0
	is_active = true


## Returns the current opponent's name, or "Don the Con" for the final boss.
func get_current_opponent() -> String:
	if is_boss_fight():
		return "Don the Con"
	if current_opponent_index < opponent_queue.size():
		return opponent_queue[current_opponent_index]
	return ""


## Returns the stage key for the current fight via StageRegistry.
func get_current_stage() -> String:
	var opponent := get_current_opponent()
	return StageRegistry.get_stage_for_fighter(opponent)


## Returns true when all 7 politicians have been defeated and the boss is next.
func is_boss_fight() -> bool:
	return current_opponent_index >= opponent_queue.size()


## Advances to the next opponent after a victory.
func advance() -> void:
	current_opponent_index += 1


## Returns true when the boss has been defeated (index past all opponents + boss).
func is_complete() -> bool:
	# Complete when we've advanced past the boss fight
	return current_opponent_index > opponent_queue.size()


## Returns a human-readable progress string for the HUD.
func get_progress_text() -> String:
	if is_boss_fight():
		return "FINAL BOSS"
	return "Fight %d of 7" % (current_opponent_index + 1)
