extends CharacterBody2D

@export var speed = 300.0
@export var JUMP_VELOCITY = -600.0
@export var dash_cooldown = 1
@export var dash_speed = 5000
@export var player_no = 1
@export var sprite_texture : Texture

@onready var IT_indicator = $AnimatedSprite2D

var is_IT = false
var game_running = false

var og_speed

var max_cooldown = 0.5
var cooldown
var dash_time = 0.1
var dash_cooldown_timer
var dust_timer = 1.0
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
	$"../game_manager".game_start.connect(_on_game_start)
	
	# set texture
	var sprite = $Sprite2D
	if sprite_texture != null:
		sprite.texture = sprite_texture
		
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
		IT_indicator.visible = true
	else:
		IT_indicator.visible = false
	
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
	
	if game_running:
		# jump.
		if Input.is_action_just_pressed(input_jump):
			if jump_count == 0:
				$jump_particles.restart()
				velocity.y = JUMP_VELOCITY
				jump_count += 1
			elif jump_count == 1:
				$jump_particles.restart()
				velocity.y = JUMP_VELOCITY * 0.7
				jump_count += 1
		
		# dash
		if Input.is_action_just_pressed(input_dash) and dash_cooldown_timer == 0:
			$dash_particles.process_material.direction = Vector3( -1 * sign(velocity.x), 0, 0)
			$dash_particles.emitting = true
			speed = dash_speed
			dashing = true
			await get_tree().create_timer(dash_time).timeout
			speed = og_speed
			dash_cooldown_timer = dash_cooldown
			dashing = false
			$dash_particles.emitting = false
		
		# movement
		var direction := Input.get_axis(input_left, input_right)
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	# movement dust particle effects
	if is_on_floor() and abs(velocity.x) > 0:
		$dust_particles.emitting = true
	else:
		$dust_particles.emitting = false
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if game_running and is_IT and cooldown <= 0 and body.is_in_group("players") and body != self:
		is_IT = false
		body.cooldown = max_cooldown
		body.is_IT = true
		$IT_sound_player.play()

func _on_game_start():
	game_running = true

func _on_game_end():
	game_running = false
	self.velocity = Vector2.ZERO
	if !is_IT:
		$"../game_manager".winner = player_no
