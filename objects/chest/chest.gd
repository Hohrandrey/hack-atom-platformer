extends Node2D

var aes = AESContext.new()
var text
var edit

var text_link = "/home/ilya/Документы/Hackaton/text.txt"

var encrypted_ecb

# sheepiscool
var input_text = " "

func _ready() -> void:
	var cut
	cut = ProjectSettings.globalize_path("res://game.txt")
	text_link = cut.substr(0, cut.find("hack-atom-platformer/")) + "text.txt"
	var file = FileAccess
	if not(file.file_exists(text_link)):
		file = FileAccess.open(text_link, FileAccess.WRITE)
		file.close()
	edit = $TextEdit
	edit.visible = false


func save_to_file(content, link):
	var file = FileAccess.open(link, FileAccess.WRITE)
	file.store_string(content)

func load_from_file(link):
	var file = FileAccess.open(link, FileAccess.READ)
	var content = file.get_as_text()
	return content


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):  # Проверка нажатия клавиши (например, Enter)
		input_text = load_from_file(text_link)
		text = edit.text
		if int(text) == $"../sheep".money:
			$AnimatedSprite2D.play("open")
			text = "flag{tHensEcheSS!223}"
			$"../sheep".label.text = text
		else:
			text = input_text
		save_to_file(text, text_link)
		edit.clear()

func pad_data(data: String) -> String:
	# Добавление паддинга для кратности 16 байтам
	var padding_length = 16 - (data.length() % 16)
	return data + str(padding_length).repeat(padding_length)


func pad_edges(key: String) -> String:
	var res = String(key)
	for i in range(16 - key.length()):
		res += "0"
	# Расширение короткого ключа до 16 байт
	return res # Заполнение нулями до 16 байт


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		edit.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		edit.visible = false
