extends Fighter

## Mayor McBudget - Penny-pinching politician who weaponizes the budget.
## Special Move: Tax Attack - Rains down coins and paperwork.


func _ready() -> void:
	fighter_name = "Mayor McBudget"
	max_health = 100.0
	speed = 290.0
	jump_force = -470.0
	punch_damage = 8.0
	kick_damage = 10.0
	special_damage = 25.0
	special_name = "Tax Attack"
	super._ready()


func get_catchphrase() -> String:
	return "This is coming out of YOUR pocket!"


func attack(type: String, damage: float) -> void:
	if type == "special":
		# Tax Attack: raining projectiles from above
		pass  # TODO: spawn falling coin projectiles
	await super.attack(type, damage)
