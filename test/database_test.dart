import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/models/lesson.dart';
import 'package:spellcraft_academy/models/puzzle.dart';
import 'package:spellcraft_academy/models/school.dart';
import 'package:spellcraft_academy/models/spell.dart';
import 'package:spellcraft_academy/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DatabaseService retrieves the 3 magical schools', () async {
    final List<School> schools = await DatabaseService.instance.getSchools();
    expect(schools.length, equals(3));
    expect(schools.map((s) => s.name), containsAll(['Elemental Arts', 'Arcane Runes', 'Mystic Logic']));
  });

  test('DatabaseService retrieves all 9 lessons', () async {
    final List<Lesson> lessons = await DatabaseService.instance.getAllLessons();
    expect(lessons.length, equals(9));
    expect(
      lessons.map((l) => l.title),
      containsAll([
        'Spark',
        'Flame',
        'Tidal Force',
        'Ancient Marks',
        'Protective Glyph',
        'Key of Ages',
        'Time Pattern',
        'Mind Mirror',
        'Astral Gate',
      ]),
    );
  });

  test('DatabaseService retrieves 3 lessons per school', () async {
    final schools = await DatabaseService.instance.getSchools();
    for (final school in schools) {
      final lessons = await DatabaseService.instance.getLessonsForSchool(school.id);
      expect(lessons.length, equals(3), reason: 'School ${school.name} must have exactly 3 lessons');
    }
  });

  test('DatabaseService retrieves all 9 spells', () async {
    final List<Spell> spells = await DatabaseService.instance.getAllSpells();
    expect(spells.length, equals(9));
    expect(
      spells.map((s) => s.name),
      containsAll([
        'Lumos',
        'Ignis',
        'Aqua',
        'Rune Lock',
        'Arcane Shield',
        'Mystic Key',
        'Time Spark',
        'Mind Echo',
        'Astral Gate',
      ]),
    );
  });

  test('DatabaseService retrieves 3 puzzles for each lesson', () async {
    final lessons = await DatabaseService.instance.getAllLessons();
    for (final lesson in lessons) {
      final List<Puzzle> puzzles = await DatabaseService.instance.getPuzzlesForLesson(lesson.id);
      expect(puzzles.length, equals(3), reason: 'Lesson ${lesson.title} must have exactly 3 puzzles');
      for (final puzzle in puzzles) {
        expect(puzzle.question.isNotEmpty, isTrue);
        expect(puzzle.options.length, greaterThanOrEqualTo(2));
        expect(puzzle.correctAnswer.isNotEmpty, isTrue);
      }
    }
  });
}
