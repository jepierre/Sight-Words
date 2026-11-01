import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'word_progress.dart';

abstract interface class ProgressStore {
  Future<void> migrateLegacyWordIds(Map<String, String> wordIds);

  Future<Map<String, WordProgress>> loadAll();

  Future<WordProgress> recordAnswer(String wordId, bool correct);
}

class SqliteProgressStore implements ProgressStore {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = path.join(
      await getDatabasesPath(),
      'sight_words.db',
    );
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE word_progress (
            word_id TEXT PRIMARY KEY,
            attempts INTEGER NOT NULL,
            correct_count INTEGER NOT NULL,
            incorrect_count INTEGER NOT NULL,
            current_streak INTEGER NOT NULL,
            last_reviewed_at TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  @override
  Future<void> migrateLegacyWordIds(Map<String, String> wordIds) async {
    final database = await _db;
    await database.transaction((transaction) async {
      for (final entry in wordIds.entries) {
        if (entry.key == entry.value) {
          continue;
        }
        await transaction.update(
          'word_progress',
          {'word_id': entry.value},
          where: 'word_id = ?',
          whereArgs: [entry.key],
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  @override
  Future<Map<String, WordProgress>> loadAll() async {
    final rows = await (await _db).query('word_progress');
    return {
      for (final row in rows)
        row['word_id']! as String: WordProgress.fromMap(row),
    };
  }

  @override
  Future<WordProgress> recordAnswer(String wordId, bool correct) async {
    final database = await _db;
    return database.transaction((transaction) async {
      final rows = await transaction.query(
        'word_progress',
        where: 'word_id = ?',
        whereArgs: [wordId],
        limit: 1,
      );
      final previous = rows.isEmpty
          ? WordProgress.empty(wordId)
          : WordProgress.fromMap(rows.single);
      final updated = previous.afterAnswer(correct, DateTime.now().toUtc());
      await transaction.insert(
        'word_progress',
        updated.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return updated;
    });
  }
}
