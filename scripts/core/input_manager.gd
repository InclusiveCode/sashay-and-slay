class_name InputManager
extends Node

## Manages input scrambling, banning, and silencing for fighters.
## Each effect is scoped by a player prefix (e.g., "p1_" or "p2_").

# Maps "prefix_action" -> { "target": String, "expires": float }
var _scrambles: Dictionary = {}

# Maps "prefix_action" -> float (expiry time)
var _bans: Dictionary = {}

# Maps prefix -> float (expiry time)
var _silences: Dictionary = {}

# Actions that silence blocks (NOT movement)
const SILENCE_ACTIONS: Array[String] = ["punch", "kick", "special", "down", "taunt"]


func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	_expire_effects(now)


func scramble_input(prefix: String, from_action: String, to_action: String, duration: float) -> void:
	var key := prefix + from_action
	var expires := Time.get_ticks_msec() / 1000.0 + duration
	_scrambles[key] = { "target": prefix + to_action, "expires": expires }


func ban_input(prefix: String, action: String, duration: float) -> void:
	var key := prefix + action
	var expires := Time.get_ticks_msec() / 1000.0 + duration
	_bans[key] = expires


func silence_player(prefix: String, duration: float) -> void:
	for action in SILENCE_ACTIONS:
		ban_input(prefix, action, duration)


func get_remapped_action(action: String, _pressed: bool) -> String:
	if action in _scrambles:
		var entry: Dictionary = _scrambles[action]
		return entry["target"]
	return action


func is_input_banned(action: String) -> bool:
	return action in _bans


func get_active_ban_count(prefix: String) -> int:
	var count := 0
	for key in _bans:
		if key.begins_with(prefix):
			count += 1
	return count


func evict_oldest_ban(prefix: String) -> void:
	var oldest_key := ""
	var oldest_time := INF
	for key in _bans:
		if key.begins_with(prefix):
			var expiry: float = _bans[key]
			if expiry < oldest_time:
				oldest_time = expiry
				oldest_key = key
	if oldest_key != "":
		_bans.erase(oldest_key)


func clear_all(prefix: String) -> void:
	var keys_to_erase: Array = []
	for key in _scrambles:
		if key.begins_with(prefix):
			keys_to_erase.append(key)
	for key in keys_to_erase:
		_scrambles.erase(key)

	keys_to_erase.clear()
	for key in _bans:
		if key.begins_with(prefix):
			keys_to_erase.append(key)
	for key in keys_to_erase:
		_bans.erase(key)

	_silences.erase(prefix)


func _expire_effects(now: float) -> void:
	var keys_to_erase: Array = []
	for key in _scrambles:
		var entry: Dictionary = _scrambles[key]
		if entry["expires"] <= now:
			keys_to_erase.append(key)
	for key in keys_to_erase:
		_scrambles.erase(key)

	keys_to_erase.clear()
	for key in _bans:
		if _bans[key] <= now:
			keys_to_erase.append(key)
	for key in keys_to_erase:
		_bans.erase(key)
