extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -500.0
@export var player_no = 1
@export var sprite_texture : Texture

@onready var label = $Label

@export var is_IT = false

var max_cooldown = 0.5
var cooldown

var input_left
var input_right
var input_jump
var input_dash

func _ready() -> void:
	#set cooldown to max
	cooldown = max_cooldown
	
	# connect signals
	$"../game_manager".game_end.connect(_on_game_end)
	
	# set texture
	var sprite = $Sprite2D
	#sprite.texture = sprite_texture
	
	# configuring input based on player number
	if player_no == 1:
		input_left = "p1_left"
		input_right = "p1_right"
		input_jump = "p1_jump"
		input_dash = "p1_dash"
	else:
		input_left = "p2_left"
		input_right = "p2_right"
		input_jump = "p2_jump"
		input_dash = "p2_dash"

func _physics_process(delta: float) -> void:
	# change label
	if is_IT:
		label.text = "IT"
	else:
		label.text = ""
	
	# run cooldown to 0
	if cooldown > 0:
		cooldown -= delta
	else:
		cooldown = 0
	
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# jump.
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# movement
	var direction := Input.get_axis(input_left, input_right)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_IT and cooldown <= 0 and body.is_in_group("players") and body != self:
		is_IT = false
		body.cooldown = max_cooldown
		body.is_IT = true

func _on_game_end():
	print("game_end")
	if !is_IT:
		print("player", player_no, " wins")
