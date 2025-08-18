import 'dart:io';

import 'package:cached/src/src.dart';

/// Scans the `lib/` directory for classes annotated with `@Cached()` and
/// inspects their fields for `@embedded()` annotations on `List`, `Map`, or `Set` types.
///
/// For each matching field, an entry is added to `embeddeOneToManyRelations` where:
/// - fieldName: the property name
/// - targetName: the enclosing class name
/// - embeddedSymbol: the inner generic type for `List`/`Set`, or the value type `V` for `Map<K, V>`
void collectOneToManyRelations() {
  final source = Directory('lib/src');

  if (!source.existsSync()) {
    return;
  }

  final filesToSearch = source.listSync().length;

  print('Searching $filesToSearch files in ${source.path}');

  // Regex helpers
  final RegExp classDeclRegex = RegExp(r'\bclass\s+(\w+)');
  final RegExp fieldRegex = RegExp(
    r'(?:final|late|var)?\s*(List|Map|Set)\s*<([^>]+)>\s+(\w+)\s*[;=]',
  );

  for (final FileSystemEntity entity in source.listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;
    final String path = entity.path;
    if (!path.endsWith('.dart')) continue;
    if (path.endsWith('.g.dart')) continue; // skip generated files

    final String source = entity.readAsStringSync();

    // Walk all occurrences of @Cached (with or without parentheses)
    int searchIndex = 0;
    while (true) {
      final int atIdx = source.indexOf('@Cached', searchIndex);
      if (atIdx == -1) break;

      // Find the next class declaration following the annotation
      final int classKeywordIdx = source.indexOf(RegExp(r'\bclass\b'), atIdx);
      if (classKeywordIdx == -1) {
        searchIndex = atIdx + 7; // length of '@Cached'
        continue;
      }

      final substring = source.substring(classKeywordIdx);
      final RegExpMatch? classMatch = classDeclRegex.firstMatch(substring);
      if (classMatch == null) {
        searchIndex = atIdx + 7;
        continue;
      }

      final String className = classMatch.group(1)!;

      // Determine the full class body by matching braces
      final int braceOpenIdx = source.indexOf('{', classKeywordIdx);
      if (braceOpenIdx == -1) {
        searchIndex = atIdx + 7;
        continue;
      }

      int braceCount = 0;
      int i = braceOpenIdx;
      for (; i < source.length; i++) {
        final String ch = source[i];
        if (ch == '{') {
          braceCount++;
        } else if (ch == '}') {
          braceCount--;
          if (braceCount == 0) {
            break;
          }
        }
      }
      if (i >= source.length) {
        searchIndex = atIdx + 7;
        continue;
      }

      final String classBody = source.substring(braceOpenIdx + 1, i);

      // Scan class body lines, remembering when we saw @embedded
      bool expectingEmbeddedField = false;
      final List<String> lines = classBody.split('\n');
      for (int li = 0; li < lines.length; li++) {
        final String line = lines[li];

        if (line.contains('@embedded')) {
          expectingEmbeddedField = true;
          // If annotation and field are on the same line, allow matching below
        }

        if (!expectingEmbeddedField) continue;

        final RegExpMatch? fm = fieldRegex.firstMatch(line);
        if (fm == null) {
          continue;
        }

        final String container = fm.group(1)!; // List | Map | Set
        final String generics = fm.group(2)!.trim(); // e.g. T  |  K, V
        final String fieldName = fm.group(3)!;

        String? embeddedSymbol;
        if (container == 'Map') {
          final List<String> parts = generics.split(',');
          if (parts.length >= 2) {
            String valueType = parts[1].trim();
            if (valueType.endsWith('?')) {
              valueType = valueType.substring(0, valueType.length - 1);
            }
            embeddedSymbol = valueType;
          }
        } else {
          String innerType = generics;
          if (innerType.contains(',')) {
            innerType = innerType.split(',').last.trim();
          }
          if (innerType.endsWith('?')) {
            innerType = innerType.substring(0, innerType.length - 1);
          }
          embeddedSymbol = innerType;
        }

        final OneToManyRelation relation = (
          fieldName: fieldName,
          targetName: className,
          embeddedSymbol: embeddedSymbol,
        );
        Cached.embeddeOneToManyRelations.add(relation);

        // Reset for the next possible @embedded occurrence
        expectingEmbeddedField = false;
      }

      // Continue searching after this class
      searchIndex = i + 1;
    }
  }
  print('found entries: ${Cached.embeddeOneToManyRelations.length}');
}
