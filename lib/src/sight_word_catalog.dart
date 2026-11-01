import 'dart:convert';

import 'package:flutter/services.dart';

class SightWordGroup {
  const SightWordGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.words,
  });

  final String id;
  final String title;
  final String description;
  final Color color;
  final List<SightWord> words;
}

class SightWord {
  const SightWord({
    required this.id,
    required this.word,
    required this.groupId,
    required this.color,
  });

  final String id;
  final String word;
  final String groupId;
  final Color color;
}

class SightWordCatalog {
  static Future<List<SightWordGroup>> load() async {
    final json = jsonDecode(
      await rootBundle.loadString('assets/sight_words.json'),
    );
    if (json is! Map<String, dynamic> || json['groups'] is! List) {
      throw const FormatException(
        'Sight-word catalog must contain a groups array.',
      );
    }

    final groupIds = <String>{};
    final wordIds = <String>{};
    final groups = <SightWordGroup>[];
    for (final value in json['groups'] as List) {
      if (value is! Map<String, dynamic> || value['words'] is! List) {
        throw const FormatException(
          'Each sight-word group must contain a words array.',
        );
      }

      final id = _requiredString(value, 'id');
      if (!groupIds.add(id)) {
        throw FormatException('Duplicate sight-word group id: $id');
      }
      final title = _requiredString(value, 'title');
      final color = _parseColor(_requiredString(value, 'color'));
      final description = value['description'];
      if (description is! String) {
        throw FormatException(
          'Description for sight-word group "$id" must be a string.',
        );
      }

      final words = <SightWord>[];
      for (final wordValue in value['words'] as List) {
        if (wordValue is! Map<String, dynamic>) {
          throw FormatException('Words in group "$id" must be objects.');
        }
        final wordId = _requiredString(wordValue, 'id');
        if (!wordIds.add(wordId)) {
          throw FormatException('Duplicate sight-word id: $wordId');
        }
        words.add(
          SightWord(
            id: wordId,
            word: _requiredString(wordValue, 'word'),
            groupId: id,
            color: color,
          ),
        );
      }

      groups.add(
        SightWordGroup(
          id: id,
          title: title,
          description: description,
          color: color,
          words: words,
        ),
      );
    }

    return groups;
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Catalog field "$key" must be a non-empty string.');
    }
    return value.trim();
  }

  static Color _parseColor(String value) {
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
      throw FormatException(
        'Invalid sight-word group color "$value"; use #RRGGBB.',
      );
    }
    return Color(0xFF000000 | int.parse(hex, radix: 16));
  }
}
