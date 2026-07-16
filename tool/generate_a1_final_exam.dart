import 'dart:convert';
import 'dart:io';

typedef Json = Map<String, Object?>;

void main() {
  final questions = <Json>[];
  void add(
    String section,
    String topic,
    String unit,
    String type,
    String difficulty,
    String text,
    List<String> options,
    String answer,
    String explanation,
  ) {
    questions.add({
      'id': 'a1-fe-${(questions.length + 1).toString().padLeft(3, '0')}',
      'sectionId': section,
      'topic': topic,
      'unitSource': unit,
      'type': type,
      'difficulty': difficulty,
      'question': text,
      'options': options,
      'correctAnswer': answer,
      'explanationSomali': explanation,
      'scoreValue': 1,
      'recommendationUnit': unit,
    });
  }

  const vocabulary = [
    ('letter', 'xaraf', 'Unit 1'),
    ('Hello', 'Salaan', 'Unit 2'),
    ('twenty', 'labaatan', 'Unit 3'),
    ('mother', 'hooyo', 'Unit 4'),
    ('wake up', 'toosid', 'Unit 5'),
    ('Monday', 'Isniin', 'Unit 6'),
    ('rice', 'bariis', 'Unit 7'),
    ('kitchen', 'jikada', 'Unit 8'),
    ('hospital', 'isbitaal', 'Unit 9'),
    ('Excuse me', 'iga raalli ahow', 'Unit 10'),
  ];
  for (var i = 0; i < 20; i++) {
    final item = vocabulary[i % vocabulary.length];
    add(
      'vocabulary',
      'A1 vocabulary',
      item.$3,
      i.isEven ? 'englishToSomali' : 'somaliToEnglish',
      i < 8
          ? 'easy'
          : i < 16
          ? 'medium'
          : 'challenging',
      i.isEven
          ? 'Dooro macnaha “${item.$1}”.'
          : 'English ku dooro “${item.$2}”.',
      i.isEven
          ? [
              item.$2,
              vocabulary[(i + 1) % 10].$2,
              vocabulary[(i + 2) % 10].$2,
              vocabulary[(i + 3) % 10].$2,
            ]
          : [
              item.$1,
              vocabulary[(i + 1) % 10].$1,
              vocabulary[(i + 2) % 10].$1,
              vocabulary[(i + 3) % 10].$1,
            ],
      i.isEven ? item.$2 : item.$1,
      '${item.$1} macnihiisu waa ${item.$2}.',
    );
  }

  const grammar = [
    (
      'I ___ a student.',
      ['am', 'is', 'are', 'be'],
      'am',
      'Verb to be',
      'Unit 2',
    ),
    (
      'She ___ two sisters.',
      ['has', 'have', 'having', 'do'],
      'has',
      'Have/has',
      'Unit 4',
    ),
    (
      'He ___ English daily.',
      ['studies', 'study', 'studys', 'studying'],
      'studies',
      'Present Simple',
      'Unit 5',
    ),
    (
      'Does she ___ tea?',
      ['like', 'likes', 'liking', 'liked'],
      'like',
      'Do/does',
      'Unit 7',
    ),
    (
      'There ___ two chairs.',
      ['are', 'is', 'am', 'be'],
      'are',
      'There is/are',
      'Unit 8',
    ),
    (
      'Do you have ___ water?',
      ['any', 'a', 'many', 'an'],
      'any',
      'Some/any',
      'Unit 7',
    ),
    (
      'How ___ apples?',
      ['many', 'much', 'an', 'a'],
      'many',
      'Much/many',
      'Unit 7',
    ),
    (
      'Can he ___ there?',
      ['walk', 'walks', 'walking', 'walked'],
      'walk',
      'Can',
      'Unit 9',
    ),
    (
      'We meet ___ Monday.',
      ['on', 'at', 'in', 'to'],
      'on',
      'Time prepositions',
      'Unit 6',
    ),
    (
      'The book is ___ the table.',
      ['on', 'at', 'to', 'from'],
      'on',
      'Place prepositions',
      'Unit 8',
    ),
  ];
  for (var i = 0; i < 25; i++) {
    final g = grammar[i % grammar.length];
    add(
      'grammar',
      g.$4,
      g.$5,
      i % 3 == 0 ? 'fillInTheBlank' : 'multipleChoice',
      i < 9
          ? 'easy'
          : i < 19
          ? 'medium'
          : 'challenging',
      g.$1,
      g.$2,
      g.$3,
      '${g.$4}: “${g.$3}” ayaa jumladda saxaya.',
    );
  }

  const passages = [
    'Amina is twenty years old. She lives with her parents and two brothers. She is a student and studies English. Her father is a driver and her mother works in a shop. Amina likes reading and tea. On Friday, she visits her grandmother. Her family eats dinner together in the evening.',
    'Ali wakes up at six every morning. He prays, eats breakfast and leaves home at seven. He starts work at eight. He usually has lunch at one. After work, he studies English for thirty minutes. He goes to bed at ten. On Thursday evening, he plays football with friends.',
    'Hodan is at a restaurant with her friend. She orders rice and chicken for five dollars. Her friend orders fish and salad for six dollars. They both drink mango juice. Hodan asks for the bill after dinner. The total is fifteen dollars because each juice costs two dollars. They thank the waiter.',
    'The hospital is on Peace Road, opposite the market. A pharmacy is next to the hospital. From the bus station, go straight for two minutes and turn left at the bank. Walk past the park. The hospital is on your right. It is about five minutes from the station.',
  ];
  for (var i = 0; i < 12; i++) {
    final p = passages[i ~/ 3];
    final passageIndex = i ~/ 3;
    final data = [
      [
        (
          'How many brothers does Amina have?',
          ['Two', 'One', 'Three', 'Four'],
          'Two',
        ),
        (
          'What does Amina study?',
          ['English', 'Math only', 'Medicine', 'Driving'],
          'English',
        ),
        (
          'Who works in a shop?',
          ['Her mother', 'Her father', 'Amina', 'Her brother'],
          'Her mother',
        ),
      ],
      [
        (
          'What time does Ali wake up?',
          ['Six', 'Seven', 'Eight', 'Ten'],
          'Six',
        ),
        (
          'When does he have lunch?',
          ['At one', 'At six', 'At eight', 'At ten'],
          'At one',
        ),
        (
          'What does he do on Thursday evening?',
          ['Plays football', 'Visits grandmother', 'Works', 'Cooks'],
          'Plays football',
        ),
      ],
      [
        (
          'What does Hodan order?',
          ['Rice and chicken', 'Fish and salad', 'Soup', 'Tea'],
          'Rice and chicken',
        ),
        (
          'How much is fish and salad?',
          ['Six dollars', 'Five dollars', 'Two dollars', 'Fifteen dollars'],
          'Six dollars',
        ),
        (
          'What is the total?',
          ['Fifteen dollars', 'Eleven dollars', 'Ten dollars', 'Four dollars'],
          'Fifteen dollars',
        ),
      ],
      [
        (
          'What is opposite the hospital?',
          ['Market', 'Bank', 'Park', 'Station'],
          'Market',
        ),
        (
          'Where do you turn?',
          [
            'Left at the bank',
            'Right at the market',
            'Left at the park',
            'Back at station',
          ],
          'Left at the bank',
        ),
        (
          'How long is the walk?',
          ['About five minutes', 'One hour', 'Thirty minutes', 'Two hours'],
          'About five minutes',
        ),
      ],
    ][passageIndex][i % 3];
    add(
      'reading',
      'Reading comprehension',
      'Unit ${[4, 5, 7, 9][passageIndex]}',
      'readingComprehension',
      i < 4
          ? 'easy'
          : i < 9
          ? 'medium'
          : 'challenging',
      '$p\n\n${data.$1}',
      data.$2,
      data.$3,
      'Jawaabtu si cad ayay ugu jirtaa qoraalka.',
    );
  }

  const situations = [
    (
      'How are you?',
      ['I’m fine, thank you.', 'At the bank.', 'Five dollars.', 'Turn left.'],
      'I’m fine, thank you.',
      'Unit 2',
    ),
    (
      'Can you help me?',
      ['Yes, of course.', 'Rice and tea.', 'At ten.', 'My mother.'],
      'Yes, of course.',
      'Unit 10',
    ),
    (
      'May I see the menu?',
      ['Yes. Here you are.', 'Turn right.', 'I’m twenty.', 'On Monday.'],
      'Yes. Here you are.',
      'Unit 7',
    ),
    (
      'Who is calling?',
      ['This is Ali.', 'At five.', 'A hospital.', 'Two cups.'],
      'This is Ali.',
      'Unit 10',
    ),
    (
      'Would you like some tea?',
      ['Yes, please.', 'Go straight.', 'I work.', 'It is Monday.'],
      'Yes, please.',
      'Unit 10',
    ),
  ];
  for (var i = 0; i < 13; i++) {
    final s = situations[i % situations.length];
    add(
      'situations',
      'Everyday conversation',
      s.$4,
      'bestResponse',
      i < 5
          ? 'easy'
          : i < 10
          ? 'medium'
          : 'challenging',
      s.$1,
      s.$2,
      s.$3,
      '“${s.$3}” waa jawaabta ugu dabiicisan xaaladdan.',
    );
  }

  const translations = [
    (
      'Waxaan tagaa shaqada sideedda subaxnimo.',
      'I go to work at eight in the morning.',
      'somaliToEnglish',
      'Unit 5',
    ),
    (
      'Miiska waxaa saaran laba buug.',
      'There are two books on the table.',
      'somaliToEnglish',
      'Unit 8',
    ),
    ('Ma jeceshahay shaah?', 'Do you like tea?', 'somaliToEnglish', 'Unit 7'),
    (
      'Bangigu wuxuu ka soo horjeedaa suuqa.',
      'The bank is opposite the market.',
      'somaliToEnglish',
      'Unit 9',
    ),
    (
      'Waxaan jeclaan lahaa koob biyo ah.',
      'I would like a glass of water.',
      'somaliToEnglish',
      'Unit 7',
    ),
    (
      'She studies English every day.',
      'Waxay barataa English maalin kasta.',
      'englishToSomali',
      'Unit 5',
    ),
    (
      'The keys are under the bed.',
      'Furayaashu sariirta ayay hoos yaallaan.',
      'englishToSomali',
      'Unit 8',
    ),
    (
      'Can you repeat that, please?',
      'Ma ku celin kartaa, fadlan?',
      'englishToSomali',
      'Unit 10',
    ),
    (
      'Habee: straight / go / then / left / turn',
      'Go straight, then turn left.',
      'arrangeSentence',
      'Unit 9',
    ),
    (
      'Habee: name / my / is / Asha',
      'My name is Asha.',
      'arrangeSentence',
      'Unit 2',
    ),
  ];
  for (var i = 0; i < 10; i++) {
    final t = translations[i];
    add(
      'translation',
      'Translation and sentence building',
      t.$4,
      t.$3,
      i < 3
          ? 'easy'
          : i < 8
          ? 'medium'
          : 'challenging',
      t.$1,
      [
        t.$2,
        'Turn right at the bank.',
        'There is some rice.',
        'I am from Monday.',
      ],
      t.$2,
      'Qaabka saxda ahi waa: ${t.$2}',
    );
  }

  final exam = {
    'id': 'a1-final-exam',
    'titleEnglish': 'A1 Final Level Exam',
    'titleSomali': 'Imtixaanka Kama Dambaysta ah ee Heerka A1',
    'passingScore': 75,
    'questions': questions,
  };
  File(
    'assets/content/a1/final_exam.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(exam)}\n');
}
