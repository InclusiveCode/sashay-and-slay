class_name RonDeSanctimonious
extends Fighter

## Culture Warrior — Every 15 seconds, bans one opponent move (punch or kick).
## Special silences opponent completely. Gains DR when opponent uses special.

var _ban_timer: float = 0.0
const BAN_INTERVAL: float = 15.0

var _parental_advisory_active: bool = false
var _parental_advisory_timer: float = 0.0
const PARENTAL_ADVISORY_DR: float = 0.15
const PARENTAL_ADVISORY_DURATION: float = 5.0


func _ready() -> void:
	fighter_name = "Ron DeSanctimonious"
	max_health = 110.0
	speed = 280.0
	jump_force = -490.0
	punch_damage = 9.0
	kick_damage = 10.0
	special_damage = 0.0
	special_name = "Don't Say Slay"
	super._ready()


func get_catchphrase() -> String:
	return "This fight has been deemed inappropriate for all audiences."


func passive_proc(delta: float) -> void:
	# Ban timer — every 15s, ban a random opponent action (punch or kick)
	_ban_timer += delta
	if _ban_timer >= BAN_INTERVAL:
		_ban_timer -= BAN_INTERVAL
		_apply_random_ban()

	# Parental Advisory DR timer
	if _parental_advisory_active:
		_parental_advisory_timer -= delta
		if _parental_advisory_timer <= 0.0:
			_parental_advisory_active = false
			_parental_advisory_timer = 0.0


func _apply_random_ban() -> void:
	if opponent == null or input_manager == null:
		return

	var opp_prefix := "p2_" if is_player_one else "p1_"
	var actions := ["punch", "kick"]
	var chosen: String = actions[randi() % actions.size()]

	# FIFO: evict oldest if already at max 2 bans
	if input_manager.get_active_ban_count(opp_prefix) >= 2:
		input_manager.evict_oldest_ban(opp_prefix)

	input_manager.ban_input(opp_prefix, chosen, BAN_INTERVAL)
	passive_triggered.emit("Move Banned: " + chosen)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Silence opponent for 4 seconds
	if opponent != null and input_manager != null:
		var opp_prefix := "p2_" if is_player_one else "p1_"
		input_manager.silence_player(opp_prefix, 4.0)

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


## "Parental Advisory" — called externally when opponent uses their special.
## Connect opponent's special_used signal to this method.
func _on_opponent_used_special() -> void:
	_parental_advisory_active = true
	_parental_advisory_timer = PARENTAL_ADVISORY_DURATION
	passive_triggered.emit("Parental Advisory")


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _parental_advisory_active:
		amount *= (1.0 - PARENTAL_ADVISORY_DR)
	super.take_damage(amount, unblockable)


func reset_round_state() -> void:
	super.reset_round_state()
	_ban_timer = 0.0
	_parental_advisory_active = false
	_parental_advisory_timer = 0.0
