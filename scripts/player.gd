extends CharacterBody2D

@export var speed = 300.0
@export var JUMP_VELOCITY = -500.0
@export var dash_cooldown = 1
@export var dash_speed = 5000
@export var player_no = 1
@export var sprite_texture : Texture

@onready var label = $Label

var is_IT = false
var game_running = true

var og_speed

var max_cooldown = 0.5
var cooldown
var dash_time = 0.1
var dash_cooldown_timer
var jump_count = 0
var dashing = false

var input_left
var input_right
var input_jump
var input_dash

func _ready() -> void:
	#record original speed of player
	og_speed = speed
	
	#set cooldown to max
	cooldown = max_cooldown
	dash_cooldown_timer = dash_cooldown
	
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
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	else:
		dash_cooldown_timer = 0
	
	#no y velocity while dashing
	if dashing:
		velocity.y = 0
	
	# gravity
	if not is_on_floor() and !dashing:
		if velocity.y <= 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.5
			
	# set jump_count to 0 if on floor
	if is_on_floor():
		jump_count = 0
	
	# jump.
	if Input.is_action_just_pressed(input_jump):
		if jump_count == 0:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
		elif jump_count == 1:
			velocity.y = JUMP_VELOCITY * 0.7
			jump_count += 1
	
	# dash
	if Input.is_action_just_pressed(input_dash) and dash_cooldown_timer == 0:
		speed = dash_speed
		dashing = true
		await get_tree().create_timer(dash_time).timeout
		speed = og_speed
		dash_cooldown_timer = dash_cooldown
		dashing = false
	
	# movement
	var direction := Input.get_axis(input_left, input_right)
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if game_running and is_IT and cooldown <= 0 and body.is_in_group("players") and body != self:
		is_IT = false
		body.cooldown = max_cooldown
		body.is_IT = true

func _on_game_end():
	game_running = false
	if !is_IT:
		print("player", player_no, " wins")
