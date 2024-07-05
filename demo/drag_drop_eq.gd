extends Node2D

@onready var id = ""
@onready var question_type = "DragDropEquation"
@onready var image_path = ""
@onready var question_text = ""
@onready var labels = []
@onready var lhs = []
@onready var rhs = []
@onready var answers = []
@onready var final_format = {"id": "", "type": "", "text": "", "image": "", "labels": [], "lhs_terms": [], "rhs_terms": [], "answers": []}
@onready var equations = ""


func _ready():
    const uuid_util = preload("res://uuid.gd")
    id = uuid_util.v4()
    
    $QuestionText.set_visible(false)
    $QuestionTextSubmit.set_visible(false)
    $CircuitImage.set_visible(false)
    $Equation.set_visible(false)
    $Answer.set_visible(false)
    $EquationSubmit.set_visible(false)

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
    if question_text != "":
        $QuestionText.set_visible(false)
        $QuestionTextSubmit.set_visible(false)
        $Equation.set_visible(true)
        $Answer.set_visible(true)
        $EquationSubmit.set_visible(true)
    
func _on_equation_text_changed(new_text):
    equations = new_text.replace(" ", "").split(",") 
    
func _on_answer_text_changed(new_text):
    answers = new_text.replace(" ", "").split(",")
    
func _on_equation_submit_pressed():
    if len(equations) != len(answers):
        get_tree().chanage_scene_to_file("res://question_submit_fail.tscn")
        
    else:
        for i in len(equations):
            for eq in equations:
                eq = eq.replace(" ", "").split("=")
                if len(eq) != 3:
                    get_tree().change_scene_to_file("res://question_submit_fail.tscn")
                else:
                    labels.append(eq[0])
                    lhs.append(eq[1])
                    rhs.append(eq[2])
    
    if (len(labels) == len(lhs)) and (len(lhs) == len(rhs))  and (len(lhs) > 0):
        get_tree().change_scene_to_file("res://question_submit_success.tscn")
        final_format["id"] = id
        final_format["type"] = question_type
        final_format["text"] = question_text
        final_format["image"] = image_path
        final_format["labels"] = labels
        final_format["lhs_terms"] = lhs
        final_format["rhs_terms"] = rhs
        final_format["answers"] = answers
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
