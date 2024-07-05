extends CharacterBody2D

@onready var all_interactions = []
@onready var interactLabel = $"InteractionComponents/interact_label"

const SPEED = 172.0
const JUMP_VELOCITY = -300.0
var canDash = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_action_pressed("dash") && canDash:
			airDash(Input.get_axis("ui_left", "ui_right"))
			

	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		canDash = true
		velocity.y = JUMP_VELOCITY
		
	#Allows falling through one-way platforms with down input.
	if(Input.is_action_pressed("ui_down") && is_on_floor()):
		position.y += 1 

	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		#get axis returns -1 on left, 1 on right. So this just turns speed ±
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
#Dash functions
func airDash(direction):
	canDash = false
	velocity.x = direction * 4000
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
