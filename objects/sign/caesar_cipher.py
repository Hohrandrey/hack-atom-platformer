def caesar_cipher(text, shift):
    result = ""

    for char in text:
        # Проверяем, является ли символ буквой
        if char.isalpha():
            base = ord('a') if char.islower() else ord('A')
            # Сдвигаем символ и добавляем его в результат
            result += chr((ord(char) - base + shift) % 26 + base)
        else:
            # Если символ не буква, добавляем его без изменений
            result += char

    return result
