extends Fighter

## Senator Stonewall - A stubborn politician who refuses to yield.
## Special Move: Filibuster Fury - Talks so long it damages everyone nearby.


func _ready() -> void:
	fighter_name = "Senator Stonewall"
	max_health = 120.0
	speed = 250.0
	jump_force = -450.0
	punch_damage = 10.0
	kick_damage = 12.0
	special_damage = 22.0
	special_name = "Filibuster Fury"
	super._ready()


func get_catchphrase() -> String:
	return "Order! ORDER!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Filibuster Fury: sustained area damage over time
		pass  # TODO: speech bubble DOT effect
	await super.attack(type, damage)
