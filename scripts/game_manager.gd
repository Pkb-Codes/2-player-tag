extends Node2D

@export var game_time = 60

@onready var countdown_label = $"../UI/Timer"
@onready var red_win_box = $"../UI/red_win"
@onready var blue_win_box = $"../UI/blue_win"
@onready var play_again_button = $"../UI/play_again_button"
@onready var timer_audio = $"../UI/timer_audio_player"

var player1
var player2
var winner = 0
var red_limit = 200
var blue_limit = 1000

var game_timer = 0
var game_running = false
var timer_audio_playing = false
var start_time = 0
var start_timer = 0
var last_second = -1


signal game_end
signal game_start

func _ready() -> void:
	start_timer = start_time
	player1 = get_parent().get_node("player1")
	player2 = get_parent().get_node("player2")
	play_again_button.pressed.connect(_on_play_again_button_pressed)

func _process(delta: float) -> void:
	if start_timer > 0:
		start_timer -= delta
		countdown_label.text = str(int(start_timer))
		if start_timer <= 0:
			start_timer = 0
	
	if !game_running and start_timer == 0:
		select_IT()
		game_timer = game_time
		game_running = true
		game_start.emit()
		start_timer = -1
	
	if game_running:
		if game_timer > 0:
			game_timer -= delta
			var current_second = int(game_timer)
			if game_timer < 10 and current_second != last_second:
				if !timer_audio_playing:
					timer_audio.play()
					timer_audio_playing = true
				last_second = current_second
				pulse_once()
				countdown_label.modulate = Color("red")
		else:
			game_timer = 0
			timer_audio.stop()
		countdown_label.text = str(int(game_timer))
	else:
		if winner == 2:
			if red_win_box.global_position.x < red_limit:
				red_win_box.global_position.x += 2
			else:
				await get_tree().create_timer(1.0).timeout
				play_again_button.visible = true
		elif winner == 1:
			if blue_win_box.global_position.x > blue_limit:
				blue_win_box.global_position.x -= 2
			else:
				await get_tree().create_timer(1.0).timeout
				play_again_button.visible = true
	
	if game_running and game_timer == 0:
		game_running = false
		game_timer = -1
		game_end.emit()

func select_IT():
	if randf() > 0.5:
		player1.is_IT = true
	else:
		player2.is_IT = true

func pulse_once():
	var t = create_tween()
	t.tween_property(countdown_label, "scale", Vector2(1.4, 1.4), 0.1)
	t.tween_property(countdown_label, "scale", Vector2(1, 1), 0.2)

func _on_play_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
