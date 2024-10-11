extends Node2D

var aes = AESContext.new()
var text
var edit

var decrypted_ecb
var encrypted_ecb


func _ready() -> void:
	text = $Label
	edit = $TextEdit
	text.visible = false
	edit.visible = false


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept"):  # Проверка нажатия клавиши (например, Enter)
		encrypt_data()
		edit.clear()


func encrypt_data() -> void:
	var key = "Afrn"  # Ключ длиной 5 байт (32 бита)
	var iv = "TheSocietyofFact"  # IV должен быть ровно 16 байт
	var data = edit.text  # Получение текста из TextEdit

	# Убедитесь, что длина данных кратна 16, добавьте паддинг, если нужно
	data = pad_data(data)

	# Расширение ключа до 16 байт (AES-128)
	var extended_key = pad_edges(key)

	# Шифрование в режиме ECB
	aes.start(AESContext.MODE_ECB_ENCRYPT, extended_key.to_utf8_buffer())
	encrypted_ecb  = aes.update(data.to_utf8_buffer())
	aes.finish()

	# Расшифровка в режиме ECB
	aes.start(AESContext.MODE_ECB_DECRYPT, extended_key.to_utf8_buffer())
	decrypted_ecb = aes.update(encrypted_ecb)
	aes.finish()

	# Обновление текста в Label
	text.text = "Зашифрованный текст: " + encrypted_ecb.hex_encode() + "\nРасшифрованный текст: " + decrypted_ecb.get_string_from_utf8()


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
		text.visible = true
		edit.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		text.visible = false
		edit.visible = false
