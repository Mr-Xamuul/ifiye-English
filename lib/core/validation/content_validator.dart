import '../../models/content/content_models.dart';

class ValidationResult {
  const ValidationResult(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

class ContentValidator {
  const ContentValidator();

  ValidationResult validateLevel(CourseLevel level) {
    final errors = <String>[];
    if (!RegExp(r'^(A1|A2|B1|B2|C1|C2)$').hasMatch(level.id)) {
      errors.add('Level ID-ga ${level.id} ma aha CEFR ID sax ah.');
    }
    if (level.title.trim().isEmpty || level.introductionSomali.trim().isEmpty) {
      errors.add('${level.id}: title iyo introduction waa waajib.');
    }
    if (level.unitFiles.length < 10 || level.unitFiles.length > 15) {
      errors.add('${level.id}: level-ku waa inuu lahaadaa 10 ilaa 15 units.');
    }
    if (level.finalExamFile.trim().isEmpty) {
      errors.add('${level.id}: final exam file maqan.');
    }
    return ValidationResult(errors);
  }

  ValidationResult validateUnit(CourseUnit unit) {
    final errors = <String>[];
    final ids = <String>{};
    if (unit.lessons.length < 4 || unit.lessons.length > 32) {
      errors.add('${unit.id}: unit-ku waa inuu lahaadaa 4 ilaa 32 lessons.');
    }
    for (final lesson in unit.lessons) {
      if (!ids.add(lesson.id)) errors.add('${unit.id}: lesson ID isku mid ah.');
      if (lesson.levelId != unit.levelId || lesson.unitId != unit.id) {
        errors.add('${lesson.id}: levelId ama unitId ma waafaqsana unit-ka.');
      }
      errors.addAll(validateLesson(lesson).errors);
    }
    if (unit.lessons.isNotEmpty &&
        unit.lessons.last.lessonType != LessonType.review) {
      errors.add('${unit.id}: casharka ugu dambeeya waa inuu review noqdaa.');
    }
    if (unit.unitQuiz.length < 10) {
      errors.add(
        '${unit.id}: unit quiz-ku waa inuu lahaadaa ugu yaraan 10 su’aalood.',
      );
    }
    return ValidationResult(errors);
  }

  ValidationResult validateLesson(CourseLesson lesson) {
    final errors = <String>[];
    if (lesson.titleEnglish.trim().isEmpty ||
        lesson.titleSomali.trim().isEmpty ||
        lesson.shortDescriptionSomali.trim().isEmpty) {
      errors.add('${lesson.id}: cinwaannada iyo sharaxaadda waa waajib.');
    }
    if (lesson.learningObjectives.isEmpty) {
      errors.add('${lesson.id}: learning objectives maqan.');
    }
    if (lesson.examples.length < 5) {
      errors.add('${lesson.id}: ugu yaraan 5 tusaale ayaa loo baahan yahay.');
    }
    final maximumExercises = lesson.unitId == 'a1-final-review'
        ? 100
        : lesson.lessonType == LessonType.review
        ? (lesson.unitId == 'a2-u09' || lesson.unitId == 'a2-u10' ? 50 : 45)
        : 15;
    if (lesson.practiceExercises.length < 8 ||
        lesson.practiceExercises.length > maximumExercises) {
      errors.add(
        '${lesson.id}: exercises-ku waa inay noqdaan 8 ilaa $maximumExercises.',
      );
    }
    for (final exercise in [
      ...lesson.practiceExercises,
      ...lesson.quizQuestions,
    ]) {
      if (exercise.question.trim().isEmpty ||
          exercise.explanationSomali.trim().isEmpty) {
        errors.add('${lesson.id}/${exercise.id}: su’aal ama feedback maqan.');
      }
      if (exercise.options.isNotEmpty &&
          !exercise.options.contains(exercise.correctAnswer)) {
        errors.add(
          '${lesson.id}/${exercise.id}: jawaabta saxda ahi options-ka kuma jirto.',
        );
      }
    }
    return ValidationResult(errors);
  }
}
