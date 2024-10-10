extends CharacterBody2D

@export var vector = Vector2()
@export var acceleration = 0
var speed = 0

func _ready() -> void:
	$Area2D.add_to_group("moving_platform")


func _physics_process(delta: float) -> void:
	speed += acceleration
	velocity = vector * speed * delta
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not(body.is_in_group("sheep")):
		speed = 0
		acceleration *= -1
