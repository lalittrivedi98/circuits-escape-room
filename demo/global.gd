extends Node

var time_limit = Timer.new()
var tick = Timer.new()
var time_limit_time_sec = 300
var hud = load("res://hud.tscn").instantiate()
var respawn = false
var player_position = Vector2.ZERO
var question_completion = {}

# Called when the node enters the scene tree for the first time.
func start_timers():
	time_limit.one_shot = true	
	time_limit.timeout.connect(_on_time_limit_timeout)
	add_child(time_limit)
	add_child(tick)
	add_child(hud)
	tick.start(1)
	time_limit.start(time_limit_time_sec)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass	
	
	
func _on_time_limit_timeout():
	get_tree().change_scene_to_file("res://game_over.tscn")


#func _on_escape_pressed(): commenting this out while I make an escape menu
	#get_tree().quit() 


func format_time(_time):
	var time = int(_time)
	var minutes = time / 60
	var sec = time % 60
	return "%02d:%02d" % [minutes, sec]
	
	
func get_completion():
	var complete = true
	for question in question_completion:
		complete = question_completion[question]
		if complete == false:
			return complete
	return complete
	
	
func decrease_time_limit(time):
	var new_time = time_limit.time_left - time
	time_limit.stop()
	time_limit.start(new_time)

var question_uuid = ""
