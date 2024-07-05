extends Node2D

func _ready():
	if Global.question_completion == {}:
		for interact_node in get_tree().get_nodes_in_group('questions'):
			if interact_node.question_uuid != "none":
				Global.question_completion[interact_node.question_uuid] = false

	if Global.time_limit.is_stopped():
		Global.start_timers()
		
	if Global.get_completion():
		$exit_node/exit/Interactable.interact_label = "Press [E] to interact"
	else:
		$exit_node/exit/Interactable.interact_label = "Locked"
		
	if Global.player_position != Vector2.ZERO:
		$Player.position = Global.player_position
		
	for interact_node in get_tree().get_nodes_in_group('questions'):
		if Global.question_completion.has(interact_node.question_uuid) and Global.question_completion[interact_node.question_uuid]:
			interact_node.interact_label = "Complete"
			

#var player: Node2D
#var puz1: Node2D
#var puz2: Node2D
#var puz3: Node2D
#var puz4: Node2D
#var exit: Node2D
#
#func _ready():
#	player = $Player
#	puz1 = $puzzle_nodes/puzzle_1
#	puz2 = $puzzle_nodes/puzzle_2
#	puz3 = $puzzle_nodes/puzzle_3
#	puz4 = $puzzle_nodes/puzzle_4
#	exit = $exit_node/exit
#
#func _input(event: InputEvent):
#	if event is InputEventKey and event.keycode == KEY_E:
#		if is_inside_collision_shape(puz1):
#			get_tree().change_scene("res://question1.tscn")
#		elif is_inside_collision_shape(puz2):
#			get_tree().change_scene("res://question2.tscn")
#		elif is_inside_collision_shape(puz3):
#			get_tree().change_scene("res://question3.tscn")
#		elif is_inside_collision_shape(puz4):
#			get_tree().change_scene("res://question4.tscn")
#		elif is_inside_collision_shape(exit):
#			get_tree().quit()
#
#func is_inside_collision_shape(target: Node2D) -> bool:
#	for child in target.get_children():
#		if child is CollisionShape2D:
#			var collision_shape = child as CollisionShape2D
#			if collision_shape.is_point_in_shape(player.global_position):
#				return true
#	return false
