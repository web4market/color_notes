import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../utils/text_processor.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  Future<void> _copyWithProcessing(BuildContext context) async {
    // Обрабатываем текст: заменяем %d и %t
    final processedContent = TextProcessor.processText(note.content);
    final processedTitle = TextProcessor.processText(note.title);

    // Формируем текст для копирования (заголовок + содержание)
    final textToCopy = '$processedTitle\n\n$processedContent';

    // Копируем в буфер
    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✓ Скопировано с заменой плейсхолдеров:\n$processedContent'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _copyWithProcessing(context), // Используем новую функцию
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Color(note.colorValue),
        child: Dismissible(
          key: Key(note.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Индикатор наличия плейсхолдеров
                    if (note.content.contains('%d') ||
                        note.content.contains('%t'))
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'динамическая',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onLongPress,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Показываем предпросмотр с заменой плейсхолдеров
                Text(
                  _getDisplayContent(),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd.MM.yy HH:mm').format(note.updatedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    // Иконка копирования с подсказкой
                    Tooltip(
                      message:
                          'Нажмите для копирования (плейсхолдеры %d и %t будут заменены)',
                      child:
                          const Icon(Icons.copy, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayContent() {
    // Для отображения в карточке тоже заменяем плейсхолдеры
    // Чтобы пользователь видел актуальную дату/время
    return TextProcessor.processText(note.content);
  }
}
