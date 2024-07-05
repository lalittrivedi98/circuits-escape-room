extends Node2D

const uuid_util = preload("res://uuid.gd")

@onready var correctness_dropdown = get_node("CorrectnessDropdown")
@onready var current_selected = 0

@onready var isRecording = false
@onready var num_clicks = 0
@onready var this_point = {"id": "", "position_x": 0, "position_y": 0, "size_x": 0, "size_y": 0, "correct": false}
@onready var num_points = 0
@onready var this_point_rect
@onready var point_rects = []

@onready var id = ""
@onready var question_type = "PointSelect"
@onready var image_path = ""
@onready var question_text = ""
@onready var points = []
@onready var final_format = {"id": "", "type": "", "text": "", "image": "", "points": []}

func _ready():
    id = uuid_util.v4()
    
    $QuestionText.set_visible(false)
    $QuestionTextSubmit.set_visible(false)
    $CircuitImage.set_visible(false)
    $AddNew.set_visible(false)
    $ClearAll.set_visible(false)
    $PointInstr.set_visible(false)
    $CorrectnessDropdown.set_visible(false)
    $CancelPoint.set_visible(false)
    $PointSubmit.set_visible(false)
    $QSubmit.set_visible(false)
    
    add_items()

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
        $AddNew.set_visible(true)
        $ClearAll.set_visible(true)
        $QSubmit.set_visible(true)
        
func _on_add_new_pressed():
    $AddNew.set_visible(false)
    $ClearAll.set_visible(false)
    $QSubmit.set_visible(false)
    $PointInstr.set_visible(true)
    $CorrectnessDropdown.set_visible(true)
    $CancelPoint.set_visible(true)
    $PointSubmit.set_visible(true)
    
    isRecording = true

#TODO - fix graphical rectangles to show points
func _on_circuit_image_gui_input(event):
    if event is InputEventMouseButton and isRecording:
        if Input.is_action_just_released("l_click"):
            if num_clicks == 0:
                num_clicks += 1
                this_point["position_x"] = event.position[0]
                this_point["position_y"] = event.position[1]
            elif num_clicks == 1:
                num_clicks += 1
                this_point["size_x"] = abs(this_point["position_x"] - event.position[0])
                this_point["size_y"] = abs(this_point["position_y"] - event.position[1])
                var pos_x = min(this_point["position_x"], event.position[0])
                var pos_y = min(this_point["position_y"], event.position[1])
                
                
                this_point["position_x"] = pos_x
                this_point["position_y"] = pos_y
                
                this_point_rect = ColorRect.new()
                this_point_rect.color = Color(0.0, 1, 0.0, 0.5)
                this_point_rect.position = Vector2(this_point["position_x"], this_point["position_y"])
                this_point_rect.size = Vector2(this_point["size_x"], this_point["size_y"])
                $CircuitImage.add_child(this_point_rect)
                point_rects.append(this_point_rect)

func _on_correctness_dropdown_item_selected(index):
    current_selected = index

func _on_cancel_point_pressed():
    $PointInstr.set_visible(false)
    $CorrectnessDropdown.set_visible(false)
    $CancelPoint.set_visible(false)
    $PointSubmit.set_visible(false)
    $AddNew.set_visible(true)
    $ClearAll.set_visible(true)
    $QSubmit.set_visible(true)
    
    this_point = {"id": "", "position_x": 0, "position_y": 0, "size_x": 0, "size_y": 0, "correct": false}
    num_clicks = 0
    current_selected = 0
    isRecording = false
    correctness_dropdown.select(0)
    $CircuitImage.remove_child(this_point_rect)
    
func _on_clear_all_pressed():
    points = []
    for rect in point_rects:
        $CircuitImage.remove_child(rect)
    
func _on_point_submit_pressed():
    if (current_selected != 0) and (this_point["size_x"] != 0):
        if current_selected == 1:
            this_point["correct"] = true
        if current_selected == 2:
            this_point["correct"] = false
        this_point["id"] = uuid_util.v4()
        points.append(this_point)
        num_points += 1

        this_point = {"id": "", "position_x": 0, "position_y": 0, "size_x": 0, "size_y": 0, "correct": false}
        num_clicks = 0
        current_selected = 0
        isRecording = false
        correctness_dropdown.select(0)
        
        $PointInstr.set_visible(false)
        $CorrectnessDropdown.set_visible(false)
        $CancelPoint.set_visible(false)
        $PointSubmit.set_visible(false)
        $AddNew.set_visible(true)
        $ClearAll.set_visible(true)
        $QSubmit.set_visible(true)

func _on_q_submit_pressed():
    for p in points:
        if (p["id"] == "") or (p["position_x"] == 0) or (p["position_y"] == 0) or (p["size_x"] == 0) or (p["size_y"] == 0):
            get_tree().change_scene_to_file("res://question_submit_fail.tscn")
    
    get_tree().change_scene_to_file("res://question_submit_success.tscn")
    final_format["id"] = id
    final_format["type"] = question_type
    final_format["text"] = question_text
    final_format["image"] = image_path
    final_format["points"] = points
    saveQuestionData(final_format)
            

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

func add_items():
    correctness_dropdown.add_item("Select point correctness")
    correctness_dropdown.add_item("Correct")
    correctness_dropdown.add_item("Incorrect")
    
    disable_item(0)

func disable_item(id):
    correctness_dropdown.set_item_disabled(id, true)

func saveQuestionData(dict):
    var f_qdata = FileAccess.open("res://question_data", FileAccess.WRITE)
    if FileAccess.file_exists("res://question_data"):
        f_qdata.seek_end()
    f_qdata.store_line(JSON.stringify(dict, "", false))
    f_qdata.close()
