extends CharacterBody2D

var hp = MAX_HP  # Текущий уровень здоровья персонажа
var spawn = Vector2()  # Место появления персонажа
var push_back = Vector2()  # Направление и сила отталкивания
var direction_push = 0  # Направление толчка
var direction = 0  # Направление движения перемещения
var old_direction = 0  # Старое направление движения перемещения
var speed = 0.0 # Скорость персонажа

var is_sheep = false  # Есть ли овца в зоне видимости
var is_back = false  # Флаг, указывающий, что персонажа оттолкнули назад

const MAX_HP = 1  # Максимальный уровень здоровья
const MAX_SPEED = 250.0  # Максимальная скорость перемещения
const SPEED_PUSH = 250.0  # Скорость отталкивания
const ACCELERATION = 10.0  # Ускорение
const JUMP_VELOCITY = -400.0  # Скорость прыжка
const PUSH_BACK = Vector2(100, -50)  # Вектор отталкивания
const SLOWDOWN = 20.0 # Скорость замедления


func apply_push_back() -> void:
	if is_back:  # Проверяем, был ли персонаж оттолкнут
		# Рассчитываем скорость отталкивания по направлению к точке push_back
		velocity = position.direction_to(push_back) * SPEED_PUSH
		# Проверяем, достиг ли персонаж точки отталкивания
		if position.distance_to(push_back) > SPEED_PUSH * get_process_delta_time():
			move_and_slide()  # Двигаем персонажа с рассчитанной скоростью
		else:
			is_back = false  # Сбрасываем флаг отталкивания, когда оно завершилось


func _physics_process(delta: float) -> void:
	direction = $"../../sheep".position.normalized().x
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
	
	$AnimatedSprite2D.flip_h = not(old_direction+1)
	move_and_slide()


func _on_sheep_death() -> void:
	queue_free()
	var respawn = preload("res://objects/enemies/dog/dog.tscn").instantiate()
	respawn.position = spawn
	get_parent().add_child(respawn)


func _on_search_sheep_body_entered(body: Node2D) -> void:
	print("YES")
	if body.is_in_group("sheep"):
		is_sheep = true


func _on_search_sheep_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_sheep = false


func _on_dog_hit_area_entered(area: Area2D) -> void:
	if area.name == "Damage" and $"../../sheep".is_jerk:
		hp -= $"../../sheep".damage
		direction_push = $"../../sheep".direction
		push_back.x = position.x + PUSH_BACK.x * direction_push
		push_back.y = position.y + PUSH_BACK.y
		is_back = true
