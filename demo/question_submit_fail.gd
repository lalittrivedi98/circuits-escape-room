extends Node2D


func _on_new_q_pressed():
	get_tree().change_scene_to_file("res://design_tool.tscn")

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
