extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_quit_2_electricboogaloo_pressed():
	get_tree().quit()


func _on_quit_pressed():
	Global.time_limit.stop()
	get_tree().change_scene_to_file("res://menu.tscn")
