class_name ValenciaThunderclap
extends Fighter

## Ballroom Mother / Vogue Assassin — Counter-attacker who dodges through
## dips, duckwalks, and spins. Every dodge builds combo meter.

var _dodge_count: int = 0
var _in_special_combo: bool = false


func _ready() -> void:
	fighter_name = "Valencia Thunderclap"
	max_health = 95.0
	speed = 340.0
	jump_force = -520.0
	punch_damage = 6.0
	kick_damage = 8.0
	special_damage = 35.0
	special_name = "10s Across the Board"
	super._ready()


func get_catchphrase() -> String:
	return "You're giving me nothing to work with, and I'm still serving everything."


func use_special() -> void:
	_in_special_combo = true
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# 5-hit vogue combo — 7 dmg each, bonus 15 if all land
	var hits_landed := 0
	for i in range(5):
		if opponent != null:
			opponent.take_damage(7.0)
			on_damage_dealt(7.0)
			hits_landed += 1
		if anim_player and anim_player.has_animation("special"):
			anim_player.play("special")
			await anim_player.animation_finished

	# Bonus damage if all 5 hit
	if hits_landed == 5 and opponent != null:
		opponent.take_damage(15.0)
		on_damage_dealt(15.0)

	_in_special_combo = false
	is_attacking = false


func passive_proc(_delta: float) -> void:
	# "The Floor is Yours" — tracked via register_dodge()
	pass


## Called externally when this fighter successfully dodges an attack.
func register_dodge() -> void:
	_dodge_count += 1
	if _dodge_count >= 3:
		_dodge_count = 0
		# Free death drop counter-attack: 15 dmg, unblockable
		if opponent != null:
			opponent.take_damage(15.0, true)
			on_damage_dealt(15.0)
			passive_triggered.emit("The Floor is Yours")


func reset_round_state() -> void:
	super.reset_round_state()
	_dodge_count = 0
	_in_special_combo = false
