extends CanvasLayer

## In-fight HUD showing health bars, special meters, timer, and round count.

@onready var p1_health_bar: ProgressBar = $P1HealthBar if has_node("P1HealthBar") else null
@onready var p2_health_bar: ProgressBar = $P2HealthBar if has_node("P2HealthBar") else null
@onready var p1_special_bar: ProgressBar = $P1SpecialBar if has_node("P1SpecialBar") else null
@onready var p2_special_bar: ProgressBar = $P2SpecialBar if has_node("P2SpecialBar") else null
@onready var timer_label: Label = $TimerLabel if has_node("TimerLabel") else null
@onready var round_label: Label = $RoundLabel if has_node("RoundLabel") else null
@onready var announcement_label: Label = $AnnouncementLabel if has_node("AnnouncementLabel") else null

var p1_secondary_bar: ProgressBar = null
var p2_secondary_bar: ProgressBar = null
var p1_debuff_label: Label = null
var p2_debuff_label: Label = null


func update_health(player: int, current: float, max_val: float) -> void:
	var bar = p1_health_bar if player == 1 else p2_health_bar
	if bar:
		bar.max_value = max_val
		bar.value = current


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


func setup_secondary_meter(player: int, meter_name: String, max_value: float) -> void:
	var bar := ProgressBar.new()
	bar.max_value = max_value
	bar.value = 0.0
	bar.name = "P%dSecondaryBar" % player
	bar.size = Vector2(200.0, 12.0)
	if player == 1:
		bar.position = Vector2(20.0, 80.0)
		p1_secondary_bar = bar
	else:
		bar.position = Vector2(1060.0, 80.0)
		p2_secondary_bar = bar
	var _unused := meter_name
	add_child(bar)


func update_secondary(player: int, value: float) -> void:
	var bar = p1_secondary_bar if player == 1 else p2_secondary_bar
	if bar:
		bar.value = value


func show_debuff(player: int, text: String) -> void:
	var lbl: Label
	if player == 1:
		if not p1_debuff_label:
			p1_debuff_label = Label.new()
			p1_debuff_label.name = "P1DebuffLabel"
			p1_debuff_label.position = Vector2(20.0, 95.0)
			add_child(p1_debuff_label)
		lbl = p1_debuff_label
	else:
		if not p2_debuff_label:
			p2_debuff_label = Label.new()
			p2_debuff_label.name = "P2DebuffLabel"
			p2_debuff_label.position = Vector2(1060.0, 95.0)
			add_child(p2_debuff_label)
		lbl = p2_debuff_label
	lbl.text = text
	lbl.visible = true


func clear_debuffs(player: int) -> void:
	var lbl = p1_debuff_label if player == 1 else p2_debuff_label
	if lbl:
		lbl.text = ""
		lbl.visible = false
