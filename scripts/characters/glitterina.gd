extends Fighter

## Glitterina - The sparkle queen who dazzles opponents into submission.
## Special Move: Death Drop - A devastating aerial slam that stuns enemies.


func _ready() -> void:
	fighter_name = "Glitterina"
	max_health = 100.0
	speed = 320.0
	jump_force = -520.0
	punch_damage = 7.0
	kick_damage = 9.0
	special_damage = 28.0
	special_name = "Death Drop"
	super._ready()


func get_catchphrase() -> String:
	return "Time to slay, darling!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Death Drop: leap up then slam down
		velocity.y = jump_force * 1.5
		await get_tree().create_timer(0.3).timeout
		velocity.y = 800.0
	await super.attack(type, damage)
