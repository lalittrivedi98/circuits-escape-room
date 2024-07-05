extends Node2D

const but1 = false
const but2 = true
const but3 = false
const but4 = false
const but5 = true
const but6 = true
const but7 = true
const but8 = false

var check1 = false
var check2 = false
var check3 = false
var check4 = false
var check5 = false
var check6 = false
var check7 = false
var check8 = false


var butt : Button

func _ready():
	butt = $Submit

func _on_b_1_toggled(is_toggled):
	if is_toggled == true:
		check1 = true
	if is_toggled == false:
		check1 = false
	return check1

func _on_b_2_toggled(is_toggled):
	if is_toggled == true:
		check2 = true
	if is_toggled == false:
		check2 = false
	return check2

func _on_b_3_toggled(is_toggled):
	if is_toggled == true:
		check3 = true
	if is_toggled == false:
		check3 = false
	return check3

func _on_b_4_toggled(is_toggled):
	if is_toggled == true:
		check4 = true
	if is_toggled == false:
		check4 = false
	return check4

func _on_b_5_toggled(is_toggled):
	if is_toggled == true:
		check5 = true
	if is_toggled == false:
		check5 = false
	return check5
	
func _on_b_6_toggled(is_toggled):
	if is_toggled == true:
		check6 = true
	if is_toggled == false:
		check6 = false
	return check6
	
func _on_b_7_toggled(is_toggled):
	if is_toggled == true:
		check7 = true
	if is_toggled == false:
		check7 = false
	return check7
	
func _on_b_8_toggled(is_toggled):
	if is_toggled == true:
		check8 = true
	if is_toggled == false:
		check8 = false
	return check8

func _on_button_pressed():
	if (check1 == but1) and (check2 == but2) and (check3 == but3) and (check4 == but4) and (check5 == but5) and (check6 == but6) and (check7 == but7) and (check8 == but8):
		butt.text = "Correct"
		butt.self_modulate = Color(0.0, 1.0, 0.0)
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://end_screen.tscn")
	else:
		butt.text = "Wrong"
		butt.self_modulate = Color(1.0, 0.0, 0.0)
