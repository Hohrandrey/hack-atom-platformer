extends CharacterBody2D

var is_gravity = false
var start_position = Vector2()

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_gravity:
		velocity += get_gravity() * delta
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		is_gravity = true


func _on_sheep_death() -> void:
	velocity.y = 0
	is_gravity = false
	position = start_position
