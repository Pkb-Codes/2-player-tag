extends Node2D

@export var game_time = 60

@onready var countdown_label = $"../CanvasLayer/Label"

var player1
var player2

var game_timer = 0
var game_running = true

signal game_end

func _ready() -> void:
	player1 = get_parent().get_node("player1")
	player2 = get_parent().get_node("player2")
	select_IT()
	game_timer = game_time

func _process(delta: float) -> void:
	if game_running:
		if game_timer > 0:
			game_timer -= delta
		else:
			game_timer = 0	
		countdown_label.text = str(int(game_timer))
	
	if game_timer == 0:
		game_running = false
		game_timer = -1
		game_end.emit()

func select_IT():
	if randf() > 0.5:
		player1.is_IT = true
	else:
		player2.is_IT = true
