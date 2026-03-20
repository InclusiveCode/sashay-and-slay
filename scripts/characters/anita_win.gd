extends Fighter

## Anita Win - The reading queen whose words cut deeper than any blade.
## Special Move: Read to Filth - Unleashes a devastating verbal takedown.


func _ready() -> void:
	fighter_name = "Anita Win"
	max_health = 95.0
	speed = 310.0
	jump_force = -490.0
	punch_damage = 7.0
	kick_damage = 12.0
	special_damage = 26.0
	special_name = "Read to Filth"
	super._ready()


func get_catchphrase() -> String:
	return "The library is OPEN!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Read to Filth: ranged word projectile
		pass  # TODO: spawn word bubble projectile
	await super.attack(type, damage)
