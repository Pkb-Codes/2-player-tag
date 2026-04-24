extends Node

@onready var camera = $Camera2D
@onready var decision_label = $CanvasLayer/Control/decision_label
@onready var buttons = $CanvasLayer/Control/buttons
@onready var yess_label = $yess_text
@onready var ins_pos = $"instructions_page".global_position
@onready var canvas = $CanvasLayer

var target_y = -500
var decide_y = -250
var start_sequence = false
var show_decision = false

var game = 1

func _on_start_button_pressed() -> void:
	start_sequence = true
	buttons.visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	if start_sequence: 
		if camera.global_position.y > target_y:
			camera.global_position.y -= 2
			if camera.global_position.y > decide_y:
				decide_text()
		else:
			if game == 1:
				canvas.visible = false
				camera.global_position = ins_pos + Vector2(300, 250)
			elif game == 2:
				pass
	
	if game == 1 and show_decision:
		if yess_label.global_position.x < 3000:
			yess_label.global_position.x += 6

func decide_text():
	show_decision = true


func _on_tag_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tag_grassland.tscn")
