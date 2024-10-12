extends CharacterBody2D

var hp = MAX_HP

var spawn = Vector2()

var point = []

var is_back = false
var push_back = Vector2()
var direction_push = 0
var direction = 0

var start_shoot = false
var is_sheep = false
var is_shoot = false
var is_aim = false
var raycast: RayCast2D
var line: Line2D
var sheep_position = Vector2()

const MAX_HP = 2147483647
const SPEED = 100.0
const SPEED_PUSH = 250.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = -400.0
const PUSH_BACK = Vector2(100, -50)





func _ready() -> void:
	raycast = $RayCast2D
	line = $Line2D  # Получаем ссылку на Line2D
	spawn = position
	point.append($"../pos1")
	point.append($"../pos2")


func shoot() -> void:
	var bodies = $AreaAim.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("sheep"):
			$"../../sheep".position = $"../../sheep".spawn
			hp = MAX_HP
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("sheep"):
			$"../../sheep".position = $"../../sheep".spawn
			hp = MAX_HP
	is_shoot = false
	start_shoot = false
	line.clear_points()


func _physics_process(delta: float) -> void:
	if position.y >= 666:
		position = spawn
	if hp <= 0:
		$"../../Wall".queue_free()
		queue_free()
	
	if not is_on_floor():
		direction = direction_push
		velocity.y += SPEED_PUSH / 10
	else:
		direction =  sign(point[0].position.x - position.x)
	
	if is_back:
		velocity = position.direction_to(push_back) * SPEED_PUSH
		if position.distance_to(push_back) > SPEED_PUSH * delta:
			move_and_slide()
		else:
			is_back = false
	else:
		if abs(position.x - point[0].position.x) < SPEED * delta:
			var temp = point[0]
			point[0] = point[1]
			point[1] = temp
		if not(start_shoot) and $Shoot.is_stopped():
			$Shoot.start()
		if start_shoot:
			if not(is_shoot):
				$AnimatedSprite2D.play("aim")
			if not($AnimatedSprite2D.is_playing()):
				if $AnimatedSprite2D.animation == "aim":
					$AnimatedSprite2D.play("shoot_1")
					is_aim = false
				elif $AnimatedSprite2D.animation == "shoot_1":
					shoot()
					$AnimatedSprite2D.play("shoot_2")
			is_shoot = true
			if is_shoot and is_sheep:
				if is_aim:
					sheep_position = $"../../sheep".position - position
					$AreaAim.position = sheep_position
					raycast.target_position = sheep_position  # Устанавливаем направление
					raycast.force_raycast_update()
					line.points = [Vector2.ZERO, sheep_position]
				direction = sign(sheep_position.x)
				velocity = Vector2(0, 0)
				velocity.y += SPEED_PUSH
		elif direction:
			velocity.x = direction * SPEED
			is_shoot = false
			is_aim = true
	
	move_and_slide()
	
	$AnimatedSprite2D.flip_h = not(direction+1)
	
	if not(is_shoot):
		if velocity.x != 0:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")


func _on_sheep_death() -> void:
	queue_free()
	var respawn = preload("res://objects/enemies/cowboy/cowboy.tscn").instantiate()
	respawn.position = spawn
	get_parent().add_child(respawn)



func _on_cowboy_hit_area_entered(area: Area2D) -> void:
	if area.name == "Damage" and $"../../sheep".is_jerk:
		hp -= $"../../sheep".damage
		direction_push = $"../../sheep".direction
		push_back.x = position.x + PUSH_BACK.x * direction_push
		push_back.y = position.y + PUSH_BACK.y
		is_back = true


func _on_search_sheep_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_sheep = true


func _on_search_sheep_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_sheep = false


func _on_shoot_timeout() -> void:
	start_shoot = true
