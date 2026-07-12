enum LessonType {
  vocabulary,
  grammar,
  pronunciation,
  listening,
  speaking,
  reading,
  writing,
  review,
}

enum ExerciseType {
  multipleChoice,
  englishToSomali,
  somaliToEnglish,
  fillInTheBlank,
  matchWords,
  arrangeSentence,
  chooseGrammar,
  readingComprehension,
  shortWriting,
  speakingPrompt,
  trueFalse,
}

T _enumByName<T extends Enum>(List<T> values, String value) =>
    values.firstWhere((item) => item.name == value);

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).cast<String>();

class VocabularyEntry {
  const VocabularyEntry({
    required this.englishWord,
    required this.somaliMeaning,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.exampleEnglish,
    required this.exampleSomali,
    required this.explanationSomali,
    required this.commonMistakeSomali,
  });

  final String englishWord;
  final String somaliMeaning;
  final String partOfSpeech;
  final String pronunciation;
  final String exampleEnglish;
  final String exampleSomali;
  final String explanationSomali;
  final String commonMistakeSomali;

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) =>
      VocabularyEntry(
        englishWord: json['englishWord'] as String,
        somaliMeaning: json['somaliMeaning'] as String,
        partOfSpeech: json['partOfSpeech'] as String,
        pronunciation: json['pronunciation'] as String,
        exampleEnglish: json['exampleEnglish'] as String,
        exampleSomali: json['exampleSomali'] as String,
        explanationSomali: json['explanationSomali'] as String,
        commonMistakeSomali: json['commonMistakeSomali'] as String,
      );
}

class BilingualExample {
  const BilingualExample({required this.english, required this.somali});
  final String english;
  final String somali;

  factory BilingualExample.fromJson(Map<String, dynamic> json) =>
      BilingualExample(
        english: json['english'] as String,
        somali: json['somali'] as String,
      );
}

class PracticeExercise {
  const PracticeExercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanationSomali,
  });

  final String id;
  final ExerciseType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanationSomali;

  factory PracticeExercise.fromJson(Map<String, dynamic> json) =>
      PracticeExercise(
        id: json['id'] as String,
        type: _enumByName(ExerciseType.values, json['type'] as String),
        question: json['question'] as String,
        options: _strings(json['options']),
        correctAnswer: json['correctAnswer'] as String,
        explanationSomali: json['explanationSomali'] as String,
      );
}

class GrammarTopic {
  const GrammarTopic({
    required this.titleEnglish,
    required this.titleSomali,
    required this.explanationSomali,
    required this.rule,
    required this.sentenceStructure,
    required this.positiveExamples,
    required this.negativeExamples,
    required this.questionExamples,
    required this.commonMistakesSomali,
    required this.practiceQuestions,
  });

  final String titleEnglish;
  final String titleSomali;
  final String explanationSomali;
  final String rule;
  final String sentenceStructure;
  final List<BilingualExample> positiveExamples;
  final List<BilingualExample> negativeExamples;
  final List<BilingualExample> questionExamples;
  final List<String> commonMistakesSomali;
  final List<PracticeExercise> practiceQuestions;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) => GrammarTopic(
    titleEnglish: json['titleEnglish'] as String,
    titleSomali: json['titleSomali'] as String,
    explanationSomali: json['explanationSomali'] as String,
    rule: json['rule'] as String,
    sentenceStructure: json['sentenceStructure'] as String,
    positiveExamples: _examples(json['positiveExamples']),
    negativeExamples: _examples(json['negativeExamples']),
    questionExamples: _examples(json['questionExamples']),
    commonMistakesSomali: _strings(json['commonMistakesSomali']),
    practiceQuestions: _exercises(json['practiceQuestions']),
  );
}

class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.levelId,
    required this.unitId,
    required this.lessonNumber,
    required this.titleEnglish,
    required this.titleSomali,
    required this.shortDescriptionSomali,
    required this.learningObjectives,
    required this.lessonType,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.isLocked,
    this.requiredPreviousLessonId,
    required this.vocabulary,
    this.grammar,
    required this.examples,
    required this.practiceExercises,
    required this.speakingPractice,
    required this.writingPractice,
    required this.summarySomali,
    required this.quizQuestions,
  });

  final String id;
  final String levelId;
  final String unitId;
  final int lessonNumber;
  final String titleEnglish;
  final String titleSomali;
  final String shortDescriptionSomali;
  final List<String> learningObjectives;
  final LessonType lessonType;
  final int estimatedMinutes;
  final String difficulty;
  final bool isLocked;
  final String? requiredPreviousLessonId;
  final List<VocabularyEntry> vocabulary;
  final GrammarTopic? grammar;
  final List<BilingualExample> examples;
  final List<PracticeExercise> practiceExercises;
  final String speakingPractice;
  final String writingPractice;
  final String summarySomali;
  final List<PracticeExercise> quizQuestions;

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
    id: json['id'] as String,
    levelId: json['levelId'] as String,
    unitId: json['unitId'] as String,
    lessonNumber: json['lessonNumber'] as int,
    titleEnglish: json['titleEnglish'] as String,
    titleSomali: json['titleSomali'] as String,
    shortDescriptionSomali: json['shortDescriptionSomali'] as String,
    learningObjectives: _strings(json['learningObjectives']),
    lessonType: _enumByName(LessonType.values, json['lessonType'] as String),
    estimatedMinutes: json['estimatedMinutes'] as int,
    difficulty: json['difficulty'] as String,
    isLocked: json['isLocked'] as bool,
    requiredPreviousLessonId: json['requiredPreviousLessonId'] as String?,
    vocabulary: (json['vocabulary'] as List<dynamic>? ?? const [])
        .map((item) => VocabularyEntry.fromJson(item as Map<String, dynamic>))
        .toList(),
    grammar: json['grammar'] == null
        ? null
        : GrammarTopic.fromJson(json['grammar'] as Map<String, dynamic>),
    examples: _examples(json['examples']),
    practiceExercises: _exercises(json['practiceExercises']),
    speakingPractice: json['speakingPractice'] as String,
    writingPractice: json['writingPractice'] as String,
    summarySomali: json['summarySomali'] as String,
    quizQuestions: _exercises(json['quizQuestions']),
  );
}

class CourseUnit {
  const CourseUnit({
    required this.id,
    required this.levelId,
    required this.unitNumber,
    required this.titleEnglish,
    required this.titleSomali,
    required this.introductionSomali,
    required this.requiredPreviousUnitId,
    required this.lessons,
    required this.unitQuiz,
  });

  final String id;
  final String levelId;
  final int unitNumber;
  final String titleEnglish;
  final String titleSomali;
  final String introductionSomali;
  final String? requiredPreviousUnitId;
  final List<CourseLesson> lessons;
  final List<PracticeExercise> unitQuiz;

  factory CourseUnit.fromJson(Map<String, dynamic> json) => CourseUnit(
    id: json['id'] as String,
    levelId: json['levelId'] as String,
    unitNumber: json['unitNumber'] as int,
    titleEnglish: json['titleEnglish'] as String,
    titleSomali: json['titleSomali'] as String,
    introductionSomali: json['introductionSomali'] as String,
    requiredPreviousUnitId: json['requiredPreviousUnitId'] as String?,
    lessons: (json['lessons'] as List<dynamic>)
        .map((item) => CourseLesson.fromJson(item as Map<String, dynamic>))
        .toList(),
    unitQuiz: _exercises(json['unitQuiz']),
  );
}

class CourseLevel {
  const CourseLevel({
    required this.id,
    required this.title,
    required this.descriptionSomali,
    required this.introductionSomali,
    required this.requiredPreviousLevelId,
    required this.unitFiles,
    required this.finalExamFile,
  });

  final String id;
  final String title;
  final String descriptionSomali;
  final String introductionSomali;
  final String? requiredPreviousLevelId;
  final List<String> unitFiles;
  final String finalExamFile;

  factory CourseLevel.fromJson(Map<String, dynamic> json) => CourseLevel(
    id: json['id'] as String,
    title: json['title'] as String,
    descriptionSomali: json['descriptionSomali'] as String,
    introductionSomali: json['introductionSomali'] as String,
    requiredPreviousLevelId: json['requiredPreviousLevelId'] as String?,
    unitFiles: _strings(json['unitFiles']),
    finalExamFile: json['finalExamFile'] as String,
  );
}

List<BilingualExample> _examples(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .map((item) => BilingualExample.fromJson(item as Map<String, dynamic>))
        .toList();

List<PracticeExercise> _exercises(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .map((item) => PracticeExercise.fromJson(item as Map<String, dynamic>))
        .toList();
