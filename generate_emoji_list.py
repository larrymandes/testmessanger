#!/usr/bin/env python3
"""
Парсит emojis.txt и генерирует Dart код со списком эмодзи
"""

def parse_emojis(filename):
    """Парсит файл и возвращает список эмодзи"""
    emojis = []
    
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            
            # Пропускаем комментарии и пустые строки
            if not line or line.startswith('#'):
                continue
            
            # Парсим строку: "1F600 ; fully-qualified # 😀 E1.0 grinning face"
            parts = line.split(';')
            if len(parts) < 2:
                continue
            
            status = parts[1].strip()
            
            # Берём только fully-qualified (полные эмодзи)
            if 'fully-qualified' not in status:
                continue
            
            # Извлекаем hex коды
            hex_codes = parts[0].strip().split()
            
            # Конвертируем hex в эмодзи
            try:
                emoji = ''.join(chr(int(code, 16)) for code in hex_codes)
                emojis.append(emoji)
            except ValueError:
                continue
    
    return emojis

def generate_dart_code(emojis):
    """Генерирует Dart код"""
    
    # Убираем дубликаты
    emojis = list(dict.fromkeys(emojis))
    
    lines = []
    lines.append(f"// Auto-generated from emojis.txt")
    lines.append(f"// Total emojis: {len(emojis)}")
    lines.append("")
    lines.append("class EmojiList {")
    lines.append("  static const List<String> all = [")
    
    # Выводим по 10 эмодзи в строке
    for i in range(0, len(emojis), 10):
        chunk = emojis[i:i+10]
        emoji_strings = ', '.join(f"'{e}'" for e in chunk)
        lines.append(f"    {emoji_strings},")
    
    lines.append("  ];")
    lines.append("}")
    
    return '\n'.join(lines)

if __name__ == '__main__':
    emojis = parse_emojis('emojis.txt')
    dart_code = generate_dart_code(emojis)
    
    # Записываем в файл с правильной кодировкой
    with open('lib/services/emoji_list.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)
