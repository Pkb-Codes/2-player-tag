extends Node2D

@onready var countdown_label = $"../UI/Timer"
@onready var red_win_box = $"../UI/red_win"
@onready var blue_win_box = $"../UI/blue_win"
@onready var play_again_button = $"../UI/play_again_button"
@onready var lava_cam = $"../lava_cam"
@onready var lava_text = $"../lava_text"

var lava_limit = -488
var red_limit = 200
var blue_limit = 1000
var cam_speed = 1
var start_time = 5
var start_timer = 0

var game_running = false
var red_won = false
var blue_won = false
var lava_fall = false
var player1
var player2

signal game_start
signal game_end

func _ready() -> void:
	player1 = get_parent().get_node("player1")
	player2 = get_parent().get_node("player2")
	
	start_timer = start_time
	play_again_button.pressed.connect(_on_play_again_button_pressed)

func _process(delta: float) -> void:
	if start_timer > 0:
		start_timer -= delta
		countdown_label.text = str(int(start_timer))
		if start_timer < 2:
			lava_fall = true
		if start_timer <= 0:
			start_timer = 0
	
	if start_timer == 0:
		countdown_label.text = ""
		game_start.emit()
		game_running = true
		start_timer = -1
	
	if lava_fall and lava_text.global_position.y > -1000:
		lava_text.global_position.y += 5
	
	if game_running:
		lava_cam.global_position.y -= cam_speed
	
	var diff1 = lava_cam.global_position.y - player1.global_position.y
	var diff2 = lava_cam.global_position.y - player2.global_position.y
	
	if !blue_won and diff1 < lava_limit:
		red_won = true
		game_running = false
	
	if !red_won and diff2 < lava_limit:
		blue_won = true
		game_running = false
	
	if red_won:
		if red_win_box.global_position.x < red_limit:
			red_win_box.global_position.x += 2
		else:
			await get_tree().create_timer(1.0).timeout
			play_again_button.visible = true
	
	if blue_won:
		if blue_win_box.global_position.x > blue_limit:
			blue_win_box.global_position.x -= 2
		else:
			await get_tree().create_timer(1.0).timeout
			play_again_button.visible = true

func _on_play_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass
