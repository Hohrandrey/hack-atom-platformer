extends CharacterBody2D

signal platform(velosityz)
signal stop

@export var vector = Vector2()
@export var is_moving = true
@export var speed = 150.0

var is_mov

const JUMP_VELOCITY = -400.0
var direction = 0

var spawn = Vector2()
var is_platform = false


func _ready() -> void:
	is_mov = not(is_moving)
	add_to_group("m_platform")
	$Area2D.add_to_group("moving_platform")
	spawn = position
	if is_moving:
		direction = 1


func _physics_process(delta: float) -> void:
	if $"../../sheep".is_death:
		position = spawn
	if is_platform:
		emit_signal("platform", velocity.x)
	velocity = vector * direction * speed
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not(body.is_in_group("sheep")):
		direction *= -1


func _on_moving_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_platform = true
		if is_mov:
			is_moving = true
			direction = 1


func _on_moving_area_body_exited(body: Node2D) -> void:
	is_platform = false
	emit_signal("stop")
	if is_mov:
		is_moving = false
		direction = 0


func _on_stop_platform_stop() -> void:
	direction *= -1
