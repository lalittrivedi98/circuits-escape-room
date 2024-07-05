extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_question_editor_pressed():
	Global.time_limit.stop()
	get_tree().change_scene_to_file("res://design_tool.tscn")


func _on_options_pressed():
	Global.time_limit.stop()
	get_tree().change_scene_to_file("res://Options_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()
