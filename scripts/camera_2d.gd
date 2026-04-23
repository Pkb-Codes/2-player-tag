extends Camera2D

var player1
var player2

func _ready():
	player1 = get_parent().get_node("player1")
	player2 = get_parent().get_node("player2")

func _process(_delta: float) -> void:
	global_position = (player1.global_position + player2.global_position)/2
	var distance = player1.global_position.distance_to(player2.global_position)
	
	if distance > 400:
		var zoom_factor = 1.2 - clamp(distance / 2000, 0, 0.8)
		zoom = Vector2(zoom_factor, zoom_factor)
