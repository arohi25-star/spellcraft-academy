/// Model representing an individual puzzle challenge within a lesson.
class Puzzle {
  final String id;
  final String lessonId;
  final String question;
  final String puzzleType; // sequence, symbol_select, pattern, memory, multiple_choice
  final List<String> options;
  final String correctAnswer;
  final int sortOrder;

  const Puzzle({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.puzzleType,
    required this.options,
    required this.correctAnswer,
    this.sortOrder = 1,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    final rawOptions = json['options'];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    }

    return Puzzle(
      id: json['id'] as String? ?? '',
      lessonId: json['lesson_id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      puzzleType: json['puzzle_type'] as String? ?? 'multiple_choice',
      options: parsedOptions,
      correctAnswer: json['correct_answer'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question': question,
      'puzzle_type': puzzleType,
      'options': options,
      'correct_answer': correctAnswer,
      'sort_order': sortOrder,
    };
  }
}
