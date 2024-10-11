extends Node2D

signal door_open

var text_edit
var input_text
var is_edit = false


# Функция для шифрования текста с помощью шифра Цезаря
func caesar_cipher(text: String, shift: int) -> String:
	var result = ""
	for char in text:
		if char >= 'a' and char <= 'z':  # Проверяем, является ли символ буквой нижнего регистра
			var base = 'a'
			# Сдвигаем символ и добавляем его в результат
			result += char((char.unicode_at(0) - base.unicode_at(0) + shift) % 26 + base.unicode_at(0))
		elif char >= 'A' and char <= 'Z':  # Проверяем, является ли символ буквой верхнего регистра
			var base = 'A'
			result += char((char.unicode_at(0) - base.unicode_at(0) + shift) % 26 + base.unicode_at(0))
		else:
			# Если символ не буква, добавляем его без изменений
			result += char
	return result


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_edit = $TextEdit
	text_edit.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_edit:
		input_text = text_edit.get_text()
		input_text = caesar_cipher(input_text, 12)
	if input_text == "Tmowmfazuezuoq":
		emit_signal("door_open")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		text_edit.visible = true
		is_edit = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		text_edit.visible = false
		is_edit = false
