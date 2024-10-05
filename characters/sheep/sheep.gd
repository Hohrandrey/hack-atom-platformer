extends CharacterBody2D

signal death

var speed = 0.0
var direction = 0
var old_direction = 1
var jump_velocity = 0

var spawn = Vector2()

var moving_velosity_x = 0

var jerk = 0
var is_jerk = false

var is_end = false

const MAX_JUMP = 100
const SLOWDOWN = 20.0
const ACCELERATION = 10.0
const MAX_SPEED = 250.0
const SPEED_JERK = 500.0
const MAX_JERK = 100

func _ready() -> void:
	spawn = Vector2($"../spawn/start_spawn".position)
	add_to_group("sheep")

func _physics_process(delta: float) -> void:
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
	
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	position = spawn
	emit_signal("death")


func _on_moving_platform_platform(velosity: Variant) -> void:
	moving_velosity_x = velosity


func _on_moving_platform_stop() -> void:
	moving_velosity_x = 0


func _on_spawn_new_spawn(x: Variant, y: Variant) -> void:
	spawn = Vector2(x, y)


func _on_celling_check_body_entered(body: Node2D) -> void:
	if not(body.is_in_group("sheep")) and is_on_floor():
		position = spawn
		emit_signal("death")


func _on_transition_end() -> void:
	is_end = true
