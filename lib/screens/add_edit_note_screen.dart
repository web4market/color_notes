import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../utils/text_processor.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColor;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<Color> _colorPalette = [
    Colors.white,
    Colors.yellow,
    Colors.green.shade300,
    Colors.green,
    Colors.red,
    Colors.red.shade200,
    Colors.yellow.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.colorValue ?? Colors.white.value;

    // Добавляем слушатель для предпросмотра
    _contentController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _previewText = '';

  void _updatePreview() {
    setState(() {
      _previewText = TextProcessor.processText(_contentController.text);
    });
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      colorValue: _selectedColor,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.note == null) {
      await _dbHelper.insertNote(note);
    } else {
      await _dbHelper.updateNote(note);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Новая заметка' : 'Редактировать'),
        backgroundColor: Color(_selectedColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Информационная карточка о плейсхолдерах
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Динамические плейсхолдеры',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• %d — текущая дата (ДД.ММ.ГГГГ)\n'
                      '• %t — текущее время (ЧЧ:ММ)\n'
                      'При копировании заметки плейсхолдеры будут заменены на актуальные значения',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                hintText: 'Например: Встреча %t',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Введите заголовок' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Текст заметки',
                hintText:
                    'Используйте %d для даты и %t для времени\nПример: Сегодня %d, встреча в %t',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Введите текст' : null,
            ),

            // Предпросмотр результата
            if (_contentController.text.isNotEmpty &&
                (_contentController.text.contains('%d') ||
                    _contentController.text.contains('%t')))
              Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.preview,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Предпросмотр при копировании:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _previewText.isEmpty
                              ? _contentController.text
                              : _previewText,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),
            const Text(
              'Выберите цвет заметки:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorPalette.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color.value;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color.value
                            ? Colors.black
                            : Colors.grey.shade300,
                        width: _selectedColor == color.value ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _selectedColor == color.value
                        ? const Icon(Icons.check, size: 30)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
