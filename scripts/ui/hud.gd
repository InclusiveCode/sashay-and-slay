extends CanvasLayer

## In-fight HUD showing health bars, special meters, timer, and round count.

@onready var p1_health_bar: ProgressBar = $P1HealthBar if has_node("P1HealthBar") else null
@onready var p2_health_bar: ProgressBar = $P2HealthBar if has_node("P2HealthBar") else null
@onready var p1_special_bar: ProgressBar = $P1SpecialBar if has_node("P1SpecialBar") else null
@onready var p2_special_bar: ProgressBar = $P2SpecialBar if has_node("P2SpecialBar") else null
@onready var timer_label: Label = $TimerLabel if has_node("TimerLabel") else null
@onready var round_label: Label = $RoundLabel if has_node("RoundLabel") else null
@onready var announcement_label: Label = $AnnouncementLabel if has_node("AnnouncementLabel") else null


func update_health(player: int, value: float) -> void:
	var bar = p1_health_bar if player == 1 else p2_health_bar
	if bar:
		bar.value = value


func update_special(player: int, value: float) -> void:
	var bar = p1_special_bar if player == 1 else p2_special_bar
	if bar:
		bar.value = value


func update_timer(time: float) -> void:
	if timer_label:
		timer_label.text = str(int(time))


func show_announcement(text: String, duration: float = 2.0) -> void:
	if announcement_label:
		announcement_label.text = text
		announcement_label.visible = true
		await get_tree().create_timer(duration).timeout
		announcement_label.visible = false
