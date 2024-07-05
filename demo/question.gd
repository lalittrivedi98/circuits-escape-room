extends Node2D

@onready var SubmitBtn = preload("res://question_components/SubmitBtn.tscn").instantiate()
@onready var qText = $VBoxContainer/questionText
@onready var qImage = $VBoxContainer/qImage
@onready var AnswerArea = $VBoxContainer/HBoxContainer
@onready var PointSelect = preload("res://question_components/PointSelect.tscn")

var qData = {}

var qTxtEx = {"id":"661deb86-e62d-4095-896d-307f323075fd","type":"TextEntry","text":"3","image":"http://127.0.0.1:8000/circ2.png","placeholder_text":"3","answers":["3"]}

var qPtEx = {"id":"4e1ec0ae-e937-4b69-82d4-38dd1bc0f96b","type":"PointSelect","text":"select a and b","image":"http://127.0.0.1:8000/circ2.png","points":[{"id":"2c07250d-5690-4048-857b-09e078ca5676","position_x":24,"position_y":157,"size_x":141,"size_y":141,"correct":true}]}

var qExample = {
	"id": "3809205a-0bf0-4d24-8f15-63088acc8e18",
	"type": "TextEntry",
	"text": "The answer to this question can be either 3 or 4",
	"image": "http://127.0.0.1:8000/circ2.png",
	"placeholder_text": "Enter an integer (0-9)",
	"answers": ["3", "4"],
}

var qSelectExample = {
	"id": "08b8b9c9-f9d5-4fea-ad39-9d9efef05eae",
	"type": "PointSelect",
	"text": "Select components C and E",
	"image": "http://127.0.0.1:8000/circ2.png",
	"points": [
		{
			"id": "A", # This should probably be a UUID
			"position_x": 22,
			"position_y": 154,
			"size_x": 144,
			"size_y": 144,
			"correct": false,
		},
		{
			"id": "B",
			"position_x": 22,
			"position_y": 458,
			"size_x": 144,
			"size_y": 144,
			"correct": false,
		},
		{
			"id": "C",
			"position_x": 836,
			"position_y": 306,
			"size_x": 144,
			"size_y": 144,
			"correct": true,
		},
		{
			"id": "D",
			"position_x": 1233,
			"position_y": 625,
			"size_x": 144,
			"size_y": 144,
			"correct": false,
		},
			{
			"id": "E",
			"position_x": 1630,
			"position_y": 306,
			"size_x": 144,
			"size_y": 144,
			"correct": true,
		},
	],
}

func _ready():
	var question_file = FileAccess.open("res://question_data", FileAccess.READ)
	var question_json
	var current_line = ""
	var json = JSON.new()
	var json_data
	while not question_file.eof_reached() and not question_json:
		current_line = question_file.get_line()
		json.parse(current_line)
		json_data = json.get_data()
		if json_data['id'] == Global.question_uuid:
			question_json = json_data
	match json_data['type']:
		"TextEntry":
			create_textinput_question(json_data)
		"PointSelect":
			create_pointselect_question(json_data)

func _on_button_pressed(answer_check_function: Callable):
	if answer_check_function.call():
		SubmitBtn.text = "Correct"
		SubmitBtn.self_modulate = Color(0.0, 1.0, 0.0)
		Global.question_completion[Global.question_uuid] = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://end_screen.tscn")
	else:
		SubmitBtn.text = "Wrong"
		SubmitBtn.self_modulate = Color(1.0, 0.0, 0.0)
		Global.decrease_time_limit(10)

func _on_submit_focus_exited():
	SubmitBtn.text = "Submit"
	SubmitBtn.self_modulate = Color(1.0, 1.0, 1.0)


func create_textinput_question(question):
	create_generic_question(question)
	var AnswerEntry = preload("res://question_components/AnswerEntry.tscn")
	var IAnswerEntry = AnswerEntry.instantiate()
	IAnswerEntry.placeholder_text = question["placeholder_text"]
	AnswerArea.add_child(IAnswerEntry)
	AnswerArea.add_child(SubmitBtn)
	qData = question
	SubmitBtn.connect("pressed", _on_button_pressed.bind(check_textinput_answer))
	SubmitBtn.connect("focus_exited", _on_submit_focus_exited)
	
	
func create_pointselect_question(question):
	create_generic_question(question)
	for point in question["points"]:
		var b = PointSelect.instantiate()
		b.size = Vector2(point['size_x'], point["size_y"])
		b.position = Vector2(point['position_x'], point['position_y'])
		b.toggle_mode = true
		b.name = point['id']
		point['selected'] = false
		$VBoxContainer/qImage.add_child(b)
		b.toggled.connect(_point_selected.bind(b))
	AnswerArea.add_child(SubmitBtn)
	qData = question
	SubmitBtn.connect("pressed", _on_button_pressed.bind(check_pointselect_answer))
	SubmitBtn.connect("focus_exited", _on_submit_focus_exited)
	
	
	
func create_generic_question(question):
	qText.text = question["text"]
	if not FileAccess.file_exists(question["image"]):
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", _image_http_request_completed)
		var http_error = http_request.request(question["image"])
		if http_error != OK:
			print("An error occurred in the HTTP request.")
	else:
		qImage.texture = load(question["image"])


func check_textinput_answer():
	var PlayerAnswerInput = $VBoxContainer/HBoxContainer/AnswerEntry
	for answer in qData['answers']:
		if PlayerAnswerInput.text == answer:
			return true
	return false
	
	
func check_pointselect_answer():
	for point in qData['points']:
		if point['selected'] == point['correct']:
			continue
		else:
			return false
	return true

func _image_http_request_completed(_result, _response_code, _headers, body):
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		var ErrLabel = Label.new()
		ErrLabel.text = "An error obtained while displaying the image: " + str(image_error) + ". HTTP status was " + str(_response_code)
		$VBoxContainer/qImage.add_child(ErrLabel)
		

	var texture = ImageTexture.create_from_image(image)
	qImage.texture = texture
	
func _point_selected(state, button):
	for point in qData['points']:
		if point['id'] == button.name:
			point['selected'] = state
			break
	
	
