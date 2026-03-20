extends Fighter

## Governor Gridlock - Master of red tape who ties opponents in bureaucracy.
## Special Move: Executive Disorder - Freezes the opponent in red tape.


func _ready() -> void:
	fighter_name = "Governor Gridlock"
	max_health = 115.0
	speed = 260.0
	jump_force = -460.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 23.0
	special_name = "Executive Disorder"
	super._ready()


func get_catchphrase() -> String:
	return "Motion denied!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Executive Disorder: stun/freeze effect
		pass  # TODO: red tape stun effect
	await super.attack(type, damage)
