extends CharacterBody2D

var speed = 0.0
var direction = 0
var old_direction = 1
var jump_velocity = 0

const MAX_JUMP = 100
const ACCELERATION_JUMP = 20.0
const SLOWDOWN = 20.0
const ACCELERATION = 10.0
const MAX_SPEED = 250.0


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
	
	if not(is_on_floor()):
		$AnimatedSprite2D.play("jump")
	elif int(speed) != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("Idle")
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = speed
	if $"../moving_platform".is_platform:
		velocity += $"../moving_platform".velocity
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	position = $"../spawn".position
