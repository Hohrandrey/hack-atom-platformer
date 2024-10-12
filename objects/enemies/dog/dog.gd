extends CharacterBody2D

@export var is_promo = true

var hp = MAX_HP  # Текущий уровень здоровья персонажа
var spawn = Vector2()  # Место появления персонажа
var push_back = Vector2()  # Направление и сила отталкивания
var direction_push = 0  # Направление толчка
var direction = 0  # Направление движения перемещения
var anim # Анимации собаки
var jump_velocity = 0

var is_sheep = false  # Есть ли овца в зоне видимости
var is_back = false  # Флаг, указывающий, что персонажа оттолкнули назад

const ACCELERATION = 10.0
const MAX_JUMP = 120
const ANIM = ["black", "blue", "orange", "standart"]
const MAX_HP = 1  # Максимальный уровень здоровья
const SPEED = 250.0  # Скорость перемещения
const SPEED_PUSH = 250.0  # Скорость отталкивания
const JUMP_VELOCITY = -400.0  # Скорость прыжка
const PUSH_BACK = Vector2(100, -50)  # Вектор отталкивания
const SLOWDOWN = 20.0 # Скорость замедления


func _ready() -> void:
	anim = ANIM[randi()%4]
	spawn = position
	hp = MAX_HP
	visible = true


func _jump() -> void:
	if abs(jump_velocity) < MAX_JUMP and\
		not(is_on_wall_only()):
		jump_velocity -= ACCELERATION
		velocity.y += jump_velocity
	else:
		jump_velocity = MAX_JUMP
	
	if is_on_floor():
		jump_velocity = 0


func _physics_process(delta: float) -> void:
	if hp <= 0 or position.y >= 666:
		if is_promo:
			if $"../../sheep".label.text == "":
				$"../../sheep".label.text = "PROMO: "
			$"../../sheep".label.text += $"../../sheep".promo.substr(0, 2)
			$"../../sheep".promo = $"../../sheep".promo.substr(2, $"../../sheep".promo.length()-2)
		_on_sheep_death()
		visible = false
	
	direction = sign($"../../sheep".position.x - position.x)
	if is_sheep:
		if not is_on_floor():
			_jump()
		velocity.x = position.direction_to($"../../sheep".position).x * SPEED
		velocity.y += SPEED_PUSH / 10
	else:
		velocity.x = 0
	$AnimatedSprite2D.flip_h = not(direction+1)
	if velocity.x != 0:
		$AnimatedSprite2D.play("run_" + anim)
	else:
		$AnimatedSprite2D.play("idle_" + anim)
	if not(visible):
		velocity = Vector2()
		position = spawn
	move_and_slide()


func _on_sheep_death() -> void:
	visible = true
	position = spawn
	hp = MAX_HP
	anim = ANIM[randi()%4]


func _on_search_sheep_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_sheep = true


func _on_search_sheep_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_sheep = false


func _on_dog_hit_area_entered(area: Area2D) -> void:
	if area.name == "Damage" and $"../../sheep".is_jerk and visible:
		hp -= $"../../sheep".damage
		direction_push = $"../../sheep".direction
		push_back.x = position.x + PUSH_BACK.x * direction_push
		push_back.y = position.y + PUSH_BACK.y
		is_back = true


func _on_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep") and visible:
		$"../../sheep".is_death = true
		_on_sheep_death()
