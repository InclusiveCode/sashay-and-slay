extends Fighter

## Miss Fire - A flame-wielding diva who brings the heat.
## Special Move: Flame Fatale - Engulfs the arena in fabulous fire.


func _ready() -> void:
	fighter_name = "Miss Fire"
	max_health = 90.0
	speed = 350.0
	jump_force = -500.0
	punch_damage = 8.0
	kick_damage = 10.0
	special_damage = 30.0
	special_name = "Flame Fatale"
	super._ready()


func get_catchphrase() -> String:
	return "Too hot to handle, too fierce to hold!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Flame Fatale: fire burst area attack
		pass  # TODO: spawn flame effect
	await super.attack(type, damage)
