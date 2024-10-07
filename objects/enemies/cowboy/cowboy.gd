extends CharacterBody2D

var hp = MAX_HP

var spawn = Vector2()

var point = []

var is_back = false
var push_back = Vector2()
var direction_push = 0
var direction = 0

const MAX_HP = 50
const SPEED = 100.0
const SPEED_PUSH = 150.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = -400.0
const PUSH_BACK = Vector2(100, -50)

func _ready() -> void:
	spawn = position
	point.append($"../pos1")
	point.append($"../pos2")


func _physics_process(delta: float) -> void:
	$Hp.text = str(hp)
	if hp <= 0:
		get_tree().quit()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITYd

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction =  sign(point[0].position.x - position.x)
	
	if is_back:
		velocity = position.direction_to(push_back) * SPEED_PUSH
		if position.distance_to(push_back) > SPEED_PUSH * delta:
			move_and_slide()
		else:
			print("YES")
			is_back = false
	else:
		if abs(position.x - point[0].position.x) < SPEED * delta:
			var temp = point[0]
			point[0] = point[1]
			point[1] = temp
		if direction:
			velocity.x = direction * SPEED
	
	move_and_slide()
	
	$AnimatedSprite2D.flip_h = not(direction+1)
	
	if velocity.x != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")


func _on_sheep_death() -> void:
	position = spawn


func _on_cowboy_hit_area_entered(area: Area2D) -> void:
	if area.name == "Damage" and $"../../sheep".is_jerk:
		hp -= $"../../sheep".damage
		direction_push = $"../../sheep".direction
		push_back.x = position.x + PUSH_BACK.x * direction_push
		push_back.y = position.y + PUSH_BACK.y
		is_back = true
