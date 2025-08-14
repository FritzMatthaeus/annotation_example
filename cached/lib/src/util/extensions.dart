import 'package:collection/collection.dart';

extension StringExtension on String {
  /// Converts a string to camel case.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toCamelCase(); // 'helloWorld'
  /// 'HelloWorld'.toCamelCase(); // 'helloWorld'
  /// ```
  String toCamelCase() {
    final words = split(' ');
    if (words.isEmpty) {
      return '';
    }
    if (words.length == 1) {
      return words[0].substring(0, 1).toLowerCase() + words[0].substring(1);
    }
    return words
        .mapIndexed(
          (int index, String word) => index == 0
              ? word.substring(0, 1).toLowerCase() + word.substring(1)
              : word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1),
        )
        .join('');
  }
}
