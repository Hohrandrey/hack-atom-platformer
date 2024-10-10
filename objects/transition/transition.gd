extends Node2D

signal end

var is_tuch = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not($AnimatedSprite2D.is_playing()) and is_tuch:
		$AnimatedSprite2D.play("idle")
		get_tree().change_scene_to_file("res://scenes/level_2/level_2.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep") and not(is_tuch):
		is_tuch = true
		emit_signal("end")
		$AnimatedSprite2D.play("up")
