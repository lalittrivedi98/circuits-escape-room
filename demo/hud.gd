extends CanvasLayer

@onready var prev_time_left = Global.time_limit_time_sec

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.tick.timeout.connect(_on_tick_timeout)
	$TimeLeft.text = Global.format_time(Global.time_limit_time_sec - 1)


func _on_tick_timeout():
	if (prev_time_left - int(Global.time_limit.time_left)) >= 8:
		$TimeLeft.add_theme_color_override("font_color", Color.RED)
	else:
		$TimeLeft.add_theme_color_override("font_color", Color.WHITE)
	$TimeLeft.text = Global.format_time(Global.time_limit.time_left)
	prev_time_left = Global.time_limit.time_left
