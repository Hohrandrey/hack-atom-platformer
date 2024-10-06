extends CharacterBody2D

signal platform(velosity)
signal stop

@export var vector = Vector2()

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var direction = 1

var is_platform = false


func _ready() -> void:
	$Area2D.add_to_group("moving_platform")


func _physics_process(delta: float) -> void:
	if is_platform:
		emit_signal("platform", velocity.x)
	velocity = vector * direction * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not(body.is_in_group("sheep")):
		direction *= -1


func _on_moving_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_platform = true


func _on_moving_area_body_exited(body: Node2D) -> void:
	is_platform = false
	emit_signal("stop")


func _on_stop_platform_stop() -> void:
	direction *= -1
