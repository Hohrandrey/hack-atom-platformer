extends CharacterBody2D

var is_platform = false

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var direction = 1


func _physics_process(delta: float) -> void:
	velocity.x = direction * SPEED
	move_and_slide()



func _on_area_2d_body_entered(body: Node2D) -> void:
	direction *= -1


func _on_moving_area_body_entered(body: Node2D) -> void:
	is_platform = true


func _on_moving_area_body_exited(body: Node2D) -> void:
	is_platform = false
