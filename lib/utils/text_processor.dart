import 'package:intl/intl.dart';

class TextProcessor {
  /// Заменяет плейсхолдеры в тексте:
  /// %d - текущая дата в формате ДД.ММ.ГГГГ
  /// %t - текущее время в формате ЧЧ:ММ
  static String processText(String text) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');

    String processedText = text;

    // Заменяем %d на дату
    processedText = processedText.replaceAll('%d', dateFormat.format(now));

    // Заменяем %t на время
    processedText = processedText.replaceAll('%t', timeFormat.format(now));

    return processedText;
  }

  /// Показывает предпросмотр того, как будет выглядеть текст после замены
  static String getPreview(String text) {
    return processText(text);
  }
}
