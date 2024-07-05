extends CharacterBody2D

@onready var all_interactions = []
@onready var interactLabel = $"InteractionComponents/interact_label"

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var q1 : Interactable

func _physics_process(delta):
	#Interaction
	if Input.is_action_just_pressed("quit"):
		Global.player_position = position
		get_tree().change_scene_to_file("res://Escape_menu.tscn")
	if Input.is_action_just_pressed("interactKey"):
		execute_interaction()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Allows falling through one-way platforms with down input.
	if(Input.is_action_pressed("ui_down") && is_on_floor()):
		position.y += 1 

	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
#Interaction Methods
func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()
	
func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
	else:
		interactLabel.text = ""

func execute_interaction():
	if all_interactions:
		Global.player_position = position
		var cur_interaction = all_interactions[0]
		Global.question_uuid = cur_interaction.question_uuid
		if cur_interaction.interact_type == "typeE":
			get_tree().change_scene_to_file("res://level_complete.tscn")
		elif not Global.question_completion.has(Global.question_uuid) or not Global.question_completion[Global.question_uuid]:
			get_tree().change_scene_to_file("res://question.tscn")
			
