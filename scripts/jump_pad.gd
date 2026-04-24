extends StaticBody2D

@export var texture_normal : Texture
@export var texture_activated : Texture

@onready var sprite = $Sprite2D

var glow_time = 0.2

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.velocity.y -= 1500
		sprite.texture = texture_activated
		await get_tree().create_timer(glow_time).timeout
		sprite.texture = texture_normal
