import 'dart:convert';
import 'dart:io';

import 'generate_a1_unit7.dart' as base;

typedef Json = Map<String, Object?>;

Json exercise(
  String section,
  int n,
  String type,
  String question,
  List<String> options,
  String answer,
  String why,
) => base.exercise(
  'a1-fr-$section-${n.toString().padLeft(3, '0')}',
  type,
  question,
  options,
  answer,
  why,
);

Json vocabulary(String en, String so, String topic) => {
  'englishWord': en,
  'somaliMeaning': so,
  'partOfSpeech': 'review phrase • $topic',
  'pronunciation': en.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ''),
  'exampleEnglish': 'Review example: $en.',
  'exampleSomali': 'Tusaale dib-u-eegis: $so.',
  'explanationSomali': '$en waxaa dib looga eegayaa mowduuca $topic.',
  'commonMistakeSomali':
      'Hubi macnaha, higgaadda iyo xaaladda lagu isticmaalo.',
};

List<Json> vocabExercises() {
  const pairs = [
    ('letter', 'xaraf'),
    ('greeting', 'salaan'),
    ('age', 'da’'),
    ('family', 'qoys'),
    ('routine', 'jadwal maalinle'),
    ('Monday', 'Isniin'),
    ('rice', 'bariis'),
    ('kitchen', 'jikada'),
    ('hospital', 'isbitaal'),
    ('Excuse me', 'iga raalli ahow'),
  ];
  return [
    for (var i = 0; i < 80; i++)
      exercise(
        'vocab',
        i + 1,
        i % 4 == 0 ? 'fillInTheBlank' : 'multipleChoice',
        'Dooro macnaha saxda ah: ${pairs[i % pairs.length].$1}',
        [
          pairs[i % pairs.length].$2,
          pairs[(i + 1) % pairs.length].$2,
          pairs[(i + 2) % pairs.length].$2,
          pairs[(i + 3) % pairs.length].$2,
        ],
        pairs[i % pairs.length].$2,
        '${pairs[i % pairs.length].$1} macnihiisu waa ${pairs[i % pairs.length].$2}. Dib u eeg Unit ${(i % 10) + 1} haddii aad qaladdo.',
      ),
  ];
}

List<Json> grammarExercises() {
  const items = [
    ('I ___ a student.', ['am', 'is', 'are', 'be'], 'am', 'Verb to be'),
    (
      'She ___ two brothers.',
      ['has', 'have', 'having', 'do'],
      'has',
      'Have/has',
    ),
    (
      'He ___ to work.',
      ['goes', 'go', 'going', 'do go'],
      'goes',
      'Present Simple',
    ),
    (
      'Does she ___ tea?',
      ['like', 'likes', 'liked', 'liking'],
      'like',
      'Do/does',
    ),
    ('There ___ two chairs.', ['are', 'is', 'am', 'be'], 'are', 'There is/are'),
    ('Do you have ___ water?', ['any', 'a', 'many', 'an'], 'any', 'Some/any'),
    ('How ___ apples?', ['many', 'much', 'a', 'an'], 'many', 'Much/many'),
    (
      'Can he ___ there?',
      ['walk', 'walks', 'walking', 'walked'],
      'walk',
      'Can',
    ),
    (
      'The book is ___ the table.',
      ['on', 'at', 'to', 'from'],
      'on',
      'Place prepositions',
    ),
    (
      'We meet ___ Monday.',
      ['on', 'at', 'in', 'to'],
      'on',
      'Time prepositions',
    ),
  ];
  return [
    for (var i = 0; i < 100; i++)
      exercise(
        'grammar',
        i + 1,
        i % 3 == 0 ? 'chooseGrammar' : 'fillInTheBlank',
        items[i % items.length].$1,
        items[i % items.length].$2,
        items[i % items.length].$3,
        '${items[i % items.length].$4}: ${items[i % items.length].$3} ayaa sax ah. Dib u eeg grammar-kan haddii aad qaladdo.',
      ),
  ];
}

List<Json> situationDialogues() {
  const topics = [
    'meeting someone',
    'introduction',
    'school',
    'work',
    'shop',
    'market',
    'restaurant',
    'phone',
    'home',
    'family',
    'directions',
    'transport',
    'making plans',
    'asking help',
    'time',
    'visiting',
    'ending a conversation',
    'personal information',
  ];
  return [
    for (var i = 0; i < 25; i++)
      base.dialogue('Scenario ${i + 1}: ${topics[i % topics.length]}', [
        (
          'A',
          'Excuse me. Can you help me?',
          'Iga raalli ahow. Ma i caawin kartaa?',
        ),
        (
          'B',
          'Yes, of course. What do you need?',
          'Haa, dabcan. Maxaad u baahan tahay?',
        ),
        ('A', 'Can you repeat that, please?', 'Ma ku celin kartaa, fadlan?'),
        (
          'B',
          'Sure. I can speak slowly.',
          'Haa. Si tartiib ah ayaan u hadli karaa.',
        ),
      ]),
  ];
}

List<Json> situationExercises() => [
  for (var i = 0; i < 25; i++)
    exercise(
      'situation',
      i + 1,
      'multipleChoice',
      'Scenario ${i + 1}: Door jawaabta ugu edebta badan “Can you help me?”',
      ['Yes, of course.', 'Turn left.', 'Five dollars.', 'Monday morning.'],
      'Yes, of course.',
      'Waa best response dabiici ah. Samee role-play-ga scenario-kan.',
    ),
];

String passage(int i) =>
    'My name is Amal and I am a student. I live with my family in a small house. '
    'I wake up at six every morning and go to school at eight. I study English and mathematics. '
    'After school, I help my family and do my homework. On Friday, I visit my grandmother. '
    'I like rice and chicken, and I usually drink tea. This week I have an English lesson on Tuesday.';

List<Json> readingDialogues() => [
  for (var i = 0; i < 10; i++)
    base.dialogue('Reading ${i + 1}', [
      (
        'Text',
        passage(i),
        'Qoraalku wuxuu ka hadlayaa qof, qoys, routine, school, food iyo weekly plan. Akhri ka hor su’aalaha.',
      ),
    ]),
];

List<Json> readingExercises() => [
  for (var i = 0; i < 60; i++)
    exercise(
      'reading',
      i + 1,
      i % 2 == 0 ? 'readingComprehension' : 'trueFalse',
      i % 3 == 0
          ? 'Qoraalka: Goormay Amal toostaa?'
          : 'Qoraalka: Amal ma arday baa?',
      i % 3 == 0
          ? ['At six', 'At eight', 'At ten', 'At noon']
          : ['True', 'False'],
      i % 3 == 0 ? 'At six' : 'True',
      i % 3 == 0
          ? 'Qoraalku wuxuu sheegay six every morning.'
          : 'Bilowga qoraalku wuxuu sheegay I am a student.',
    ),
];

List<Json> conversationDialogues() {
  const topics = [
    'Greetings',
    'Introduction',
    'Family',
    'School',
    'Work',
    'Shopping',
    'Restaurant',
    'Help',
    'Phone',
    'Plans',
    'Time',
    'Directions',
    'Transport',
    'Visiting',
    'Ending',
  ];
  return [
    for (var i = 0; i < 15; i++)
      base.dialogue(topics[i], [
        ('A', 'Hello. How are you?', 'Salaan. Sidee tahay?'),
        (
          'B',
          'I’m fine, thank you. And you?',
          'Waan fiicanahay, mahadsanid. Adiguna?',
        ),
        (
          'A',
          'I’m fine. Can I ask a question?',
          'Waan fiicanahay. Su’aal ma weydiin karaa?',
        ),
        ('B', 'Yes, of course.', 'Haa, dabcan.'),
        (
          'A',
          'Can you speak slowly, please?',
          'Si tartiib ah ma u hadli kartaa?',
        ),
        ('B', 'Sure. No problem.', 'Haa. Dhib ma leh.'),
        ('A', 'Thank you for your help.', 'Waad ku mahadsan tahay caawimada.'),
        ('B', 'You’re welcome. Goodbye.', 'Adigaa mudan. Nabadgelyo.'),
      ]),
  ];
}

List<Json> conversationExercises() => [
  for (var i = 0; i < 30; i++)
    exercise(
      'conversation',
      i + 1,
      'multipleChoice',
      i.isEven
          ? 'Buuxi hadalka: Thank you. — ___'
          : 'Dooro missing line-ka edebta leh.',
      i.isEven
          ? ['You’re welcome.', 'At five.', 'Turn right.', 'Rice.']
          : [
              'Can you repeat that, please?',
              'Repeat now.',
              'You word.',
              'Again no.',
            ],
      i.isEven ? 'You’re welcome.' : 'Can you repeat that, please?',
      'Waa response/codsi dabiici ah. Ku samee role-play.',
    ),
];

List<Json> openTasks(String section, int count, String instruction) => [
  for (var i = 0; i < count; i++)
    exercise(
      section,
      i + 1,
      section == 'speaking' ? 'speakingPrompt' : 'shortWriting',
      '$instruction Task ${i + 1}. Isticmaal sentence starters: My name is…, I usually…, Can I…?',
      [],
      'Hawl furan oo la dhammaystiro',
      'Self-check: macnaha, grammar, vocabulary, sentence order, capital letters iyo punctuation. Isbarbar dhig model: My name is Ali. I am a student. I study English every day.',
    ),
];

Json lesson(
  int number,
  String title,
  String somali,
  List<Json> exercises,
  List<Json> dialogues,
  List<String> topics,
) {
  final id = 'a1-fr-s${number.toString().padLeft(2, '0')}';
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-final-review',
    'lessonNumber': number,
    'titleEnglish': title,
    'titleSomali': somali,
    'shortDescriptionSomali':
        'Qaybtani waxay isku daraysaa Unit 1 ilaa Unit 10 iyadoo feedback iyo talo dib-u-noqosho leh.',
    'learningObjectives': [
      'Dib u xasuuso mowduucyada A1.',
      'Ogow meelaha aad ku fiican tahay.',
      'Calaamadee qaybta marka aad dhammeeyso.',
    ],
    'lessonType': 'review',
    'estimatedMinutes': number == 8 ? 45 : 30,
    'difficulty': 'A1',
    'isLocked': number != 1,
    'requiredPreviousLessonId': number == 1
        ? null
        : 'a1-fr-s${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': [for (final item in topics) vocabulary(item, item, title)],
    'grammar': null,
    'examples': [
      base.example('Can you help me, please?', 'Ma i caawin kartaa, fadlan?'),
      base.example(
        'I study English every day.',
        'Waxaan bartaa English maalin kasta.',
      ),
      base.example('There is a bank near here.', 'Bangi ayaa halkan u dhow.'),
      base.example('I would like some tea.', 'Waxaan jeclaan lahaa shaah.'),
      base.example('Have a good day.', 'Maalin wanaagsan.'),
    ],
    'dialogues': dialogues,
    'practiceExercises': exercises,
    'speakingPractice':
        'Ku samee role-play ama prompt; audio recording looma baahna.',
    'writingPractice':
        'Qor jawaab, isticmaal checklist-ka, kadib mark as completed.',
    'summarySomali':
        'Qaybtan markaad dhammayso progress-ka local ahaan ayuu u kaydsamayaa.',
    'quizQuestions': [
      for (var i = 0; i < 3 && i < exercises.length; i++)
        {...exercises[i], 'id': '$id-q${i + 1}'},
    ],
  };
}

List<Json> mixedTest() {
  final result = <Json>[];
  void add(
    int count,
    String group,
    String question,
    List<String> options,
    String answer,
    String why,
  ) {
    for (var i = 0; i < count; i++) {
      result.add(
        exercise(
          'mixed-$group',
          i + 1,
          group == 'reading' ? 'readingComprehension' : 'multipleChoice',
          question,
          options,
          answer,
          '$why Topic: $group. Dib ugu noqo unit-ka la xiriira haddii loo baahdo.',
        ),
      );
    }
  }

  add(
    15,
    'vocab',
    'Hospital maxay ka dhigan tahay?',
    ['isbitaal', 'suuq', 'qol', 'quraac'],
    'isbitaal',
    'Hospital waa isbitaal.',
  );
  add(
    20,
    'grammar',
    'She ___ English every day.',
    ['studies', 'study', 'studying', 'do study'],
    'studies',
    'She + studies.',
  );
  add(
    10,
    'situation',
    'Dooro codsiga edebta leh.',
    ['Could you help me, please?', 'Help now.', 'You help.', 'No help.'],
    'Could you help me, please?',
    'Waa polite request.',
  );
  add(
    8,
    'reading',
    'Amal wakes up at six. Goormay toostaa?',
    ['At six', 'At eight', 'At ten', 'At noon'],
    'At six',
    'Detail-ku waa six.',
  );
  add(
    7,
    'response',
    'Thank you. — ___',
    ['You’re welcome.', 'Turn left.', 'Five dollars.', 'Monday.'],
    'You’re welcome.',
    'Waa conversation response sax ah.',
  );
  return result;
}

void main() {
  final lessons = [
    lesson(
      1,
      'Vocabulary Review',
      'Dib-u-eegista erayada',
      vocabExercises(),
      [],
      [
        'Alphabet',
        'Greetings',
        'Numbers',
        'Family',
        'Routine',
        'Time',
        'Food',
        'Home',
        'Places',
        'Conversations',
      ],
    ),
    lesson(
      2,
      'Grammar Review',
      'Dib-u-eegista naxwaha',
      grammarExercises(),
      [],
      [
        'Verb to be',
        'Present Simple',
        'Have/has',
        'There is/are',
        'Can',
        'Prepositions',
      ],
    ),
    lesson(
      3,
      'Everyday Situations Review',
      'Dib-u-eegista xaaladaha maalinlaha ah',
      situationExercises(),
      situationDialogues(),
      ['School', 'Work', 'Shop', 'Restaurant', 'Phone'],
    ),
    lesson(
      4,
      'Reading Review',
      'Dib-u-eegista akhriska',
      readingExercises(),
      readingDialogues(),
      ['Personal introduction', 'Family', 'Routine', 'Weekly plan'],
    ),
    lesson(
      5,
      'Conversation Review',
      'Dib-u-eegista wada sheekeysiga',
      conversationExercises(),
      conversationDialogues(),
      ['Greetings', 'Help', 'Plans', 'Directions'],
    ),
    lesson(
      6,
      'Writing Review',
      'Dib-u-eegista qoraalka',
      openTasks('writing', 15, 'Qor qoraal A1 ah.'),
      [],
      ['Sentence starters', 'Model answer', 'Self-check'],
    ),
    lesson(
      7,
      'Speaking Review',
      'Dib-u-eegista hadalka',
      openTasks('speaking', 15, 'Ku hadal 30 ilaa 60 ilbiriqsi.'),
      [],
      ['Role-play', 'Sentence starters', 'Self-check'],
    ),
    lesson(
      8,
      'Mixed Practice Test',
      'Tijaabada isku dhafan',
      [
        for (var i = 0; i < 10; i++)
          exercise(
            'mixed-intro',
            i + 1,
            'multipleChoice',
            'Tani ma Final Exam baa?',
            [
              'Maya, waa practice test.',
              'Haa, waa Final Exam.',
              'Waa A2.',
              'Waa login.',
            ],
            'Maya, waa practice test.',
            'Mixed Practice wuxuu leeyahay 60 su’aalood oo unit quiz-ka hoose ku jira.',
          ),
      ],
      [],
      ['Vocabulary', 'Grammar', 'Reading', 'Conversation'],
    ),
    lesson(
      9,
      'Review Results and Recommendations',
      'Natiijada iyo talooyinka dib-u-eegista',
      [
        for (var i = 0; i < 10; i++)
          exercise(
            'results',
            i + 1,
            'multipleChoice',
            'Haddii score-ku ka hooseeyo 70%, maxaa habboon?',
            [
              'Dib u eeg units-ka lagu taliyay.',
              'A2 si toos ah u fur.',
              'Progress-ka tirtir.',
              'Final Exam pass u qor.',
            ],
            'Dib u eeg units-ka lagu taliyay.',
            'Review waa la dhammayn karaa, laakiin talo xooggan ayaa la bixiyaa.',
          ),
      ],
      [],
      ['Strong topics', 'Topics needing review', 'Recommended units'],
    ),
  ];
  final unit = {
    'id': 'a1-final-review',
    'levelId': 'A1',
    'unitNumber': 11,
    'titleEnglish': 'A1 Final Review',
    'titleSomali': 'Dib-u-eegista Guud ee Heerka A1',
    'introductionSomali':
        'Sagaal qaybood oo isku dara vocabulary, grammar, situations, reading, conversations, writing, speaking, mixed practice iyo recommendations.',
    'requiredPreviousUnitId': 'a1-u10',
    'lessons': lessons,
    'unitQuiz': mixedTest(),
    'passingScore': 0,
  };
  File(
    'assets/content/a1/final_review.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(unit)}\n');
}
