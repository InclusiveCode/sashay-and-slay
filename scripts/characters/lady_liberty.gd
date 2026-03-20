extends Fighter

## Lady Liberty - Patriotic queen who fights for freedom and fabulous wigs.
## Special Move: Freedom Shade - A shockwave of pure truth that pushes enemies back.


func _ready() -> void:
	fighter_name = "Lady Liberty"
	max_health = 110.0
	speed = 280.0
	jump_force = -480.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 24.0
	special_name = "Freedom Shade"
	super._ready()


func get_catchphrase() -> String:
	return "Liberty and lip sync for ALL!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Freedom Shade: knockback wave
		pass  # TODO: spawn shockwave projectile
	await super.attack(type, damage)
