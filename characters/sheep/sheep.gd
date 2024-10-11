extends CharacterBody2D

signal death

var damage = 1
var speed = 0.0
var direction = 0
var old_direction = 1
var jump_velocity = 0

var spawn = Vector2()

var moving_velosity_x = 0

var jerk = 0
var is_jerk = false

var is_death = false
var is_end = false

var current_scene

const MAX_JUMP = 100
const SLOWDOWN = 20.0
const ACCELERATION = 10.0
const MAX_SPEED = 250.0
const SPEED_JERK = 500.0
const MAX_JERK = 100

func _ready() -> void:
	current_scene = get_tree().current_scene
	spawn = Vector2($"../spawn/start_spawn".position)
	add_to_group("sheep")
	if current_scene.name == "level_1":
		$Camera2D.limit_right = 10500
	elif current_scene.name == "level_2":
		$Camera2D.limit_right = 10000

func _physics_process(delta: float) -> void:
	if is_death:
		_death()
	# Handle jump.
	if Input.is_action_pressed("jump") and abs(jump_velocity) < MAX_JUMP and\
	not(is_on_wall_only()):
		jump_velocity -= ACCELERATION
		velocity.y += jump_velocity
	else:
		jump_velocity = MAX_JUMP
	
	if is_on_floor():
		jump_velocity = 0
	
	# The uniformly accelerated motion
	direction = Input.get_axis("left", "right")
	if direction:
		speed += ACCELERATION * direction
		old_direction = direction
	elif speed / old_direction > 0:
		speed -= SLOWDOWN * old_direction
	
	# Maximum speed and full deceleration
	if speed * old_direction < ACCELERATION:
		speed = 0.0
	if speed * old_direction > MAX_SPEED:
		speed = MAX_SPEED * direction
	
	# flip
	$AnimatedSprite2D.flip_h = not(old_direction+1)
	
	if is_end:
		$AnimatedSprite2D.play("Idle")
	elif is_jerk:
		$AnimatedSprite2D.play("jerk")
	elif not(is_on_floor()):
		$AnimatedSprite2D.play("jump")
	elif int(speed) != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("Idle")
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if jerk < MAX_JERK:
		if Input.is_action_just_pressed("jerk"):
			is_jerk = true
		if is_jerk:
			speed = SPEED_JERK * old_direction
			jerk += ACCELERATION
	else:
		is_jerk = false
		if is_on_floor():
			jerk = 0
	velocity.x = speed
	velocity.x += moving_velosity_x
	
	if is_end:
		velocity = Vector2(0, 0)
		$AnimatedSprite2D.flip_h = false
	
	move_and_slide()


func _death():
	position = spawn
	emit_signal("death")
	is_death = false
	var nodes = get_tree().get_nodes_in_group("m_platform")
	for node in nodes:
		node.position = node.spawn


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_death = true


func _on_moving_platform_platform(velosity: Variant) -> void:
	moving_velosity_x = velosity


func _on_moving_platform_stop() -> void:
	moving_velosity_x = 0


func _on_spawn_new_spawn(x: Variant, y: Variant) -> void:
	spawn = Vector2(x, y)


func _on_celling_check_body_entered(body: Node2D) -> void:
	if not(body.is_in_group("sheep")) and is_on_floor():
		is_death = true


func _on_transition_end() -> void:
	is_end = true


func _on_sign_door_open() -> void:
	$Camera2D.limit_right = 11000
