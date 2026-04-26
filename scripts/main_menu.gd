extends Node

@onready var camera = $Camera2D
@onready var decision_label = $CanvasLayer/Control/decision_label
@onready var buttons = $CanvasLayer/Control/buttons
@onready var ins_pos = $"instructions_page".global_position
@onready var canvas = $CanvasLayer
@onready var yess_label = $yess_text
@onready var nope_label = $nope_text

var target_y = -600
var decide_y = -300
var start_sequence = false
var show_decision = false

var number_of_games = 2
var game = 0

func _on_start_button_pressed() -> void:
	start_sequence = true
	buttons.visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	if start_sequence: 
		if camera.global_position.y > target_y:
			camera.global_position.y -= 2
			if camera.global_position.y > decide_y and !show_decision:
				decide()
		else:
			canvas.visible = false
			camera.global_position = ins_pos + Vector2(300, 250)
	
	if show_decision:
		if game == 1:
			if yess_label.global_position.x < 3000:
				yess_label.global_position.x += 6
		else:
			if nope_label.global_position.x > -2500:
				nope_label.global_position.x -= 4
				nope_label.global_position.y += 2

func decide():
	if LevelManager.last_game == -1:
		game = 1
	else:
		game = randi() % number_of_games + 1
		if game == LevelManager.last_game:
			game += 1
			if game > 2:
				game = 1
	show_decision = true
	LevelManager.last_game = game


func _on_tag_play_button_pressed() -> void:
	if game == 1:
		if randf() > 0.5:
			get_tree().change_scene_to_file("res://scenes/tag_grassland.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/tag_stone.tscn")
	elif game == 2:
		get_tree().change_scene_to_file("res://scenes/lava_rising.tscn")
