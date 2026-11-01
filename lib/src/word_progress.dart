class WordProgress {
  const WordProgress({
    required this.wordId,
    required this.attempts,
    required this.correctCount,
    required this.incorrectCount,
    required this.currentStreak,
    required this.lastReviewedAt,
  });

  const WordProgress.empty(String wordId)
      : this(
          wordId: wordId,
          attempts: 0,
          correctCount: 0,
          incorrectCount: 0,
          currentStreak: 0,
          lastReviewedAt: null,
        );

  final String wordId;
  final int attempts;
  final int correctCount;
  final int incorrectCount;
  final int currentStreak;
  final DateTime? lastReviewedAt;

  factory WordProgress.fromMap(Map<String, Object?> map) {
    return WordProgress(
      wordId: map['word_id']! as String,
      attempts: map['attempts']! as int,
      correctCount: map['correct_count']! as int,
      incorrectCount: map['incorrect_count']! as int,
      currentStreak: map['current_streak']! as int,
      lastReviewedAt: map['last_reviewed_at'] == null
          ? null
          : DateTime.parse(map['last_reviewed_at']! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'word_id': wordId,
      'attempts': attempts,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'current_streak': currentStreak,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
    };
  }

  WordProgress afterAnswer(bool correct, DateTime reviewedAt) {
    return WordProgress(
      wordId: wordId,
      attempts: attempts + 1,
      correctCount: correctCount + (correct ? 1 : 0),
      incorrectCount: incorrectCount + (correct ? 0 : 1),
      currentStreak: correct ? currentStreak + 1 : 0,
      lastReviewedAt: reviewedAt,
    );
  }
}
