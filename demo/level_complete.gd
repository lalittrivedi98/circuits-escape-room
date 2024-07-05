extends Node2D


func _ready():
	Global.tick.stop()
	Global.time_limit.stop()


func _on_button_pressed():
	get_tree().quit()
