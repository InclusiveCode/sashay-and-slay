class_name RexHazard
extends Fighter

## Drag King / Leather Daddy Grappler — Command grab specialist.
## Successful grabs increase grab range for the round.

var grab_range: float = 60.0
const BASE_GRAB_RANGE: float = 60.0
const MAX_GRAB_RANGE: float = 120.0


func _ready() -> void:
	fighter_name = "Rex Hazard"
	max_health = 115.0
	speed = 270.0
	jump_force = -490.0
	punch_damage = 10.0
	kick_damage = 11.0
	special_damage = 30.0
	special_name = "Daddy Issues"
	super._ready()


func get_catchphrase() -> String:
	return "I'm not your daddy. But I am your problem."


func _is_in_grab_range() -> bool:
	if opponent == null:
		return false
	return abs(global_position.x - opponent.global_position.x) <= grab_range


func attack(type: String, damage: float) -> void:
	if type == "kick" and _is_in_grab_range() and opponent != null:
		# Kick becomes grab when in range
		is_attacking = true
		opponent.take_damage(damage)
		on_damage_dealt(damage)
		on_hit_landed()
		_on_grab_success()
		if anim_player:
			anim_player.play("kick")
			await anim_player.animation_finished
		is_attacking = false
	else:
		super.attack(type, damage)


func _on_grab_success() -> void:
	# "Masc 4 Massacre" — increase grab range by 10px per successful grab
	grab_range = min(grab_range + 10.0, MAX_GRAB_RANGE)
	passive_triggered.emit("Masc 4 Massacre")


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	if not _is_in_grab_range():
		# Must be in grab range — special whiffs
		if anim_player and anim_player.has_animation("special"):
			anim_player.play("special")
			await anim_player.animation_finished
		is_attacking = false
		return

	# "Daddy Issues" — unblockable grab
	if opponent != null:
		# Headbutt: 10 dmg
		opponent.take_damage(10.0, true)
		on_damage_dealt(10.0)

		# Pile-drive: 20 dmg
		opponent.take_damage(20.0, true)
		on_damage_dealt(20.0)

		_on_grab_success()

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func passive_proc(_delta: float) -> void:
	pass


func reset_round_state() -> void:
	super.reset_round_state()
	grab_range = BASE_GRAB_RANGE
