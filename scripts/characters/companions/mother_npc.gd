class_name MotherNPC
extends CharacterBody2D

## "Mother" companion NPC for Mike Dense. Follows Mike, auto-blocks one incoming
## attack every 10 seconds (absorbs all damage from that hit), then disappears
## for 10 seconds before returning.

var owner_fighter: Fighter = null
var is_present: bool = true

const FOLLOW_OFFSET: Vector2 = Vector2(-40.0, 0.0)
const COOLDOWN: float = 10.0

var _cooldown_timer: float = 0.0


func _physics_process(delta: float) -> void:
	if not is_present:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			is_present = true
			visible = true
		return

	# Follow owner
	if owner_fighter != null:
		var offset := FOLLOW_OFFSET
		if owner_fighter.facing_right:
			offset.x = -abs(offset.x)
		else:
			offset.x = abs(offset.x)
		position = owner_fighter.position + offset


## Called by Mike Dense's take_damage override. Returns true if Mother blocks.
func try_block_hit() -> bool:
	if is_present:
		is_present = false
		visible = false
		_cooldown_timer = COOLDOWN
		return true
	return false
