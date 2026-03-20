extends Fighter

## Rep. Robocall - Annoying politician who spams opponents into submission.
## Special Move: Spam Slam - Floods the screen with campaign material projectiles.


func _ready() -> void:
	fighter_name = "Rep. Robocall"
	max_health = 85.0
	speed = 340.0
	jump_force = -510.0
	punch_damage = 6.0
	kick_damage = 8.0
	special_damage = 27.0
	special_name = "Spam Slam"
	super._ready()


func get_catchphrase() -> String:
	return "Have you heard about my campaign?!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Spam Slam: rapid-fire multi-hit projectiles
		pass  # TODO: campaign flyer projectile barrage
	await super.attack(type, damage)
