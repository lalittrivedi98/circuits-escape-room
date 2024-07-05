extends Node2D

@onready var type_select_dropdown = get_node("QTypeSelect")
@onready var current_selected

func _ready():
    add_items()
    
func add_items():
    type_select_dropdown.add_item("Please select question type")
    type_select_dropdown.add_item("Text Entry")
    type_select_dropdown.add_item("Point Select")
    type_select_dropdown.add_item("Drag and Drop Equation")
    
    disable_item(0)
    
func disable_item(id):
    type_select_dropdown.set_item_disabled(id, true)

func _on_q_type_select_item_selected(index):
    current_selected = index

func _on_q_select_submit_pressed():
    if current_selected == 1:
        get_tree().change_scene_to_file("res://text_entry.tscn")
    if current_selected == 2:
        get_tree().change_scene_to_file("res://point_select.tscn")
    if current_selected == 3:
        get_tree().change_scene_to_file("res://drag_drop_eq.tscn")

