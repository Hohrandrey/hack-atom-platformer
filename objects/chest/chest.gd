extends Node2D

var aes = AESContext.new()
var text
var edit

var text_link = "/home/ilya/Документы/Hackaton/text.txt"

var encrypted_ecb

# sheepiscool
const TEXT = "92be66296a24458eafc5594169515a57"

func _ready() -> void:
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
		encrypt_data()
		if text == TEXT:
			text = "flag"
		else:
			text = TEXT + '/n' + text
		save_to_file(text, text_link)
		edit.clear()


func encrypt_data() -> void:
	var key = "Afrn"  # Ключ длиной 5 байт (32 бита)
	var iv = "TheSocietyofFact"  # IV должен быть ровно 16 байт
	var data = edit.text  # Получение текста

	# Убедитесь, что длина данных кратна 16, добавьте паддинг, если нужно
	data = pad_data(data)

	# Расширение ключа до 16 байт (AES-128)
	var extended_key = pad_edges(key)

	# Шифрование в режиме ECB
	aes.start(AESContext.MODE_ECB_ENCRYPT, extended_key.to_utf8_buffer())
	encrypted_ecb  = aes.update(data.to_utf8_buffer())
	aes.finish()

	# Обновление текста в Label
	text = encrypted_ecb.hex_encode()


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
