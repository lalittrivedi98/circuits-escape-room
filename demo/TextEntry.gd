extends Node2D

@onready var id = ""
@onready var question_type = "TextEntry"
@onready var image_path = ""
@onready var question_text = ""
@onready var answer_placeholder = ""
@onready var correct_answers = []
@onready var final_format = {"id": "", "type": "", "text": "", "image": "", "placeholder_text": "", "answers": []}

func _ready():
	const uuid_util = preload("res://uuid.gd")
	id = uuid_util.v4()
	
	$QuestionText.set_visible(false)
	$QuestionTextSubmit.set_visible(false)
	$CircuitImage.set_visible(false)
	$AnswerPlaceholder.set_visible(false)
	$CorrectAnswers.set_visible(false)
	$AnswerSubmit.set_visible(false)

func _on_image_path_text_text_changed(new_text):
	image_path = new_text
	
func _on_image_submit_pressed():
	var error = loadImage(image_path)
	if error == OK:
		$ImagePathText.set_visible(false)
		$ImageSubmit.set_visible(false)
		$QuestionText.set_visible(true)
		$QuestionTextSubmit.set_visible(true)
		$CircuitImage.set_visible(true)
	
func _on_question_text_text_changed(new_text):
	question_text = new_text

func _on_question_text_submit_pressed():
	$QuestionText.set_visible(false)
	$QuestionTextSubmit.set_visible(false)
	$AnswerPlaceholder.set_visible(true)
	$CorrectAnswers.set_visible(true)
	$AnswerSubmit.set_visible(true)
	
	if question_text == "":
		get_tree().change_scene_to_file("res://question_submit_fail.tscn")
	
func _on_answer_placeholder_text_changed(new_text):
	answer_placeholder = new_text
	
func _on_correct_answers_text_changed(new_text):
	correct_answers = new_text.replace(" ", "").split(",")
	
func _on_answer_submit_pressed():
	if Array(correct_answers) != []:
		get_tree().change_scene_to_file("res://question_submit_success.tscn")
		final_format["id"] = id
		final_format["type"] = question_type
		final_format["text"] = question_text
		final_format["image"] = image_path
		final_format["placeholder_text"] = answer_placeholder
		final_format["answers"] = correct_answers
		saveQuestionData(final_format)
	else:
		get_tree().change_scene_to_file("res://question_submit_fail.tscn")

func loadImage(image_path):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _image_http_request_completed)
	var http_error = http_request.request(image_path)
	if http_error != OK:
		print("An error occurred in the HTTP request.")
		
	return http_error

func _image_http_request_completed(_result, _response_code, _headers, body):
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		var ErrLabel = Label.new()
		ErrLabel.text = "An error obtained while displaying the image: " + str(image_error) + ". HTTP status was " + str(_response_code)
		$CircuitImage.add_child(ErrLabel)

	var texture = ImageTexture.create_from_image(image)
	$CircuitImage.set_texture(texture)
	return image_error
	
func saveQuestionData(dict):
	var f_qdata = FileAccess.open("res://question_data", FileAccess.WRITE)
	if FileAccess.file_exists("res://question_data"):
		f_qdata.seek_end()
	f_qdata.store_line(JSON.stringify(dict, "", false))
	f_qdata.close()
