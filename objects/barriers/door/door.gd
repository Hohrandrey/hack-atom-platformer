extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sign_door_open() -> void:
	visible = false
	position.y += 200
	$"../sheep".label.text = "flag{:634Caesar!Heron*}"
