class_name ShieldDrone
extends CharacterBody2D

## Shield drone companion for Elmo Musk. Follows owner, blocks one incoming hit
## (absorbs all damage), then is destroyed. Lasts up to 10 seconds.

signal drone_destroyed(drone: ShieldDrone)

var owner_fighter: Fighter = null
var drone_health: float = 1.0
var capital_cost: int = 25
var shield_active: bool = true

const LIFETIME: float = 10.0
const FOLLOW_OFFSET: Vector2 = Vector2(0.0, -30.0)

var _lifetime_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Follow owner
	if owner_fighter != null:
		position = owner_fighter.position + FOLLOW_OFFSET

	# Lifetime
	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		queue_free()


## Called by Elmo Musk's take_damage override to check if the shield absorbs.
func absorb_hit() -> bool:
	if shield_active:
		shield_active = false
		drone_destroyed.emit(self)
		queue_free()
		return true
	return false
