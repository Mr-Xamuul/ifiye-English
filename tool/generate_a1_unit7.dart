import 'dart:convert';
import 'dart:io';

typedef Json = Map<String, Object?>;
typedef Word = ({String en, String so, String type, String note});

Word w(String en, String so, {String type = 'noun', String note = ''}) =>
    (en: en, so: so, type: type, note: note);

Json vocabulary(Word word, String lessonTitle) => {
  'englishWord': word.en,
  'somaliMeaning': word.so,
  'partOfSpeech': _partOfSpeech(word),
  'pronunciation': _pronunciation(word.en),
  'exampleEnglish': _wordExample(word.en, lessonTitle),
  'exampleSomali': _somaliExample(word.so, lessonTitle),
  'explanationSomali': word.note.isEmpty
      ? '${word.en} waxaa loola jeedaa ${word.so}. Ku baro jumlad gaaban.'
      : word.note,
  'commonMistakeSomali': _mistake(word.en),
};

String _partOfSpeech(Word word) {
  if (word.type != 'noun') return word.type;
  const uncountable = {
    'rice',
    'pasta',
    'bread',
    'meat',
    'beef',
    'fish',
    'cheese',
    'milk',
    'sugar',
    'salt',
    'oil',
    'flour',
    'water',
    'tea',
    'coffee',
    'juice',
  };
  const countable = {
    'egg',
    'eggs',
    'potato',
    'potatoes',
    'apple',
    'banana',
    'orange',
    'mango',
    'watermelon',
    'lemon',
    'grapes',
    'tomato',
    'onion',
    'carrot',
    'cabbage',
    'cucumber',
    'pepper',
    'bottle',
    'cup',
    'glass',
    'plate',
    'spoon',
    'fork',
    'knife',
    'napkin',
    'bag',
    'packet',
    'box',
    'can',
  };
  final value = word.en.toLowerCase();
  if (uncountable.contains(value)) return 'noun • uncountable';
  if (countable.contains(value)) return 'noun • countable';
  return word.type;
}

String _pronunciation(String word) {
  const guides = {
    'rice': 'rays',
    'pasta': 'paas-ta',
    'bread': 'bred',
    'meat': 'miit',
    'beef': 'biif',
    'chicken': 'ji-kin',
    'fish': 'fish',
    'egg': 'eg',
    'potato': 'pa-tay-to',
    'salad': 'sa-lad',
    'soup': 'suup',
    'beans': 'biinz',
    'cheese': 'jiiz',
    'milk': 'milk',
    'sugar': 'shu-gar',
    'salt': 'soolt',
    'oil': 'oyl',
    'flour': 'flaw-ar',
    'apple': 'a-pal',
    'banana': 'ba-naa-na',
    'orange': 'o-rinj',
    'mango': 'man-go',
    'watermelon': 'woo-tar-me-lan',
    'lemon': 'le-man',
    'grapes': 'grayps',
    'tomato': 'ta-maa-to',
    'onion': 'an-yan',
    'carrot': 'ka-rat',
    'cabbage': 'ka-bij',
    'cucumber': 'kyuu-kam-bar',
    'pepper': 'pe-par',
    'garlic': 'gaar-lik',
    'spinach': 'spi-nij',
    'water': 'woo-tar',
    'tea': 'tii',
    'coffee': 'ko-fi',
    'juice': 'juus',
    'breakfast': 'brek-fast',
    'lunch': 'lanj',
    'dinner': 'di-nar',
    'restaurant': 'res-ta-rant',
    'menu': 'men-yuu',
    'waiter': 'wey-tar',
    'waitress': 'wey-tris',
    'customer': 'kas-ta-mar',
    'bill': 'bil',
    'quantity': 'kwon-ti-ti',
    'countable noun': 'kawn-ta-bal nawn',
    'uncountable noun': 'an-kawn-ta-bal nawn',
  };
  final lower = word.toLowerCase();
  return guides[lower] ?? lower.replaceAll('-', ' ');
}

String _wordExample(String word, String lesson) {
  final lower = word.toLowerCase();
  if (lesson.contains('Ordering') || lesson.contains('Restaurant')) {
    return 'I would like $lower, please.';
  }
  if (lesson.contains('Market')) return 'Do you have $lower?';
  if (lesson.contains('Likes')) return 'I like $lower.';
  if (word.contains(' ')) return 'We use $lower in this lesson.';
  return 'This is $lower.';
}

String _somaliExample(String meaning, String lesson) {
  if (lesson.contains('Ordering') || lesson.contains('Restaurant')) {
    return 'Waxaan jeclaan lahaa $meaning, fadlan.';
  }
  if (lesson.contains('Market')) return 'Ma haysaan $meaning?';
  if (lesson.contains('Likes')) return 'Waxaan jeclahay $meaning.';
  return 'Kani waa $meaning.';
}

String _mistake(String word) {
  const uncountable = {
    'rice',
    'bread',
    'meat',
    'cheese',
    'milk',
    'sugar',
    'salt',
    'oil',
    'flour',
    'water',
    'tea',
    'coffee',
    'juice',
    'fish',
    'soup',
  };
  if (uncountable.contains(word.toLowerCase())) {
    return 'Marka macnaha guud laga hadlayo si toos ah a/an ha ula isticmaalin; isticmaal some ama qiyaas.';
  }
  return '';
}

Json example(String en, String so) => {'english': en, 'somali': so};

Json exercise(
  String id,
  String type,
  String question,
  List<String> options,
  String answer,
  String explanation,
) => {
  'id': id,
  'type': type,
  'question': question,
  'options': options,
  'correctAnswer': answer,
  'explanationSomali': explanation,
};

Json dialogue(String title, List<(String, String, String)> lines) => {
  'titleSomali': title,
  'lines': [
    for (final item in lines)
      {'speaker': item.$1, 'english': item.$2, 'somali': item.$3},
  ],
};

Json grammar(
  String id,
  String title,
  String somali,
  String rule,
  String structure,
  List<(String, String)> positives, {
  List<(String, String)> negatives = const [],
  List<(String, String)> questions = const [],
  List<String> mistakes = const [],
}) => {
  'titleEnglish': title,
  'titleSomali': somali,
  'explanationSomali': rule,
  'rule': rule,
  'sentenceStructure': structure,
  'positiveExamples': [for (final e in positives) example(e.$1, e.$2)],
  'negativeExamples': [for (final e in negatives) example(e.$1, e.$2)],
  'questionExamples': [for (final e in questions) example(e.$1, e.$2)],
  'commonMistakesSomali': mistakes,
  'practiceQuestions': [
    exercise(
      '$id-g01',
      'chooseGrammar',
      'Dooro qaabka saxda ah.',
      ['I have some rice.', 'I have a rice.', 'I has rice.', 'I having rice.'],
      'I have some rice.',
      'Some rice waa qaab sax ah marka rice guud ahaan laga hadlayo.',
    ),
  ],
};

class LessonSeed {
  const LessonSeed({
    required this.title,
    required this.somali,
    required this.description,
    required this.words,
    required this.examples,
    required this.dialogues,
    this.grammarTopic,
    this.review = false,
  });
  final String title;
  final String somali;
  final String description;
  final List<Word> words;
  final List<(String, String)> examples;
  final List<Json> dialogues;
  final Json? grammarTopic;
  final bool review;
}

List<Json> practices(int number, LessonSeed seed) {
  final id = 'a1-u07-l${number.toString().padLeft(2, '0')}';
  final first = seed.words.first;
  final second = seed.words.length > 1 ? seed.words[1] : first;
  final third = seed.words.length > 2 ? seed.words[2] : second;
  final items = <Json>[
    exercise(
      '$id-p01',
      'multipleChoice',
      '“${first.en}” maxay ka dhigan tahay?',
      [first.so, second.so, third.so, 'waqti'],
      first.so,
      '${first.en} macnihiisu waa ${first.so}.',
    ),
    exercise(
      '$id-p02',
      'englishToSomali',
      'U turjun: ${second.en}',
      [second.so, first.so, third.so, 'qoys'],
      second.so,
      '${second.en} waxaa Af-Soomaali lagu yiraahdaa ${second.so}.',
    ),
    exercise(
      '$id-p03',
      'somaliToEnglish',
      'English ku dooro: ${third.so}',
      [third.en, first.en, second.en, 'Monday'],
      third.en,
      '${third.so} waa ${third.en}.',
    ),
    exercise(
      '$id-p04',
      'fillInTheBlank',
      'I would like ___ water, please.',
      ['some', 'a', 'an', 'many'],
      'some',
      'Water waa uncountable; codsi edeb leh waxaa ku habboon some.',
    ),
    exercise(
      '$id-p05',
      'chooseGrammar',
      'Dooro jumladda saxda ah.',
      [
        'She likes rice.',
        'She like rice.',
        'She likes a rice.',
        'She liking rice.',
      ],
      'She likes rice.',
      'He/she/it waxaa falka like lagu daraa s.',
    ),
    exercise(
      '$id-p06',
      'arrangeSentence',
      'Habee: tea / I / like',
      ['I like tea.', 'Tea like I.', 'Like I tea.', 'I tea like.'],
      'I like tea.',
      'Qaabku waa subject + like + object.',
    ),
    exercise(
      '$id-p07',
      'chooseGrammar',
      'Dooro a ama an: ___ apple',
      ['an', 'a', 'some', 'many'],
      'an',
      'Apple wuxuu ku bilaabmaa vowel sound, sidaas darteed an.',
    ),
    exercise(
      '$id-p08',
      'chooseGrammar',
      'Do you have ___ milk?',
      ['any', 'a', 'many', 'an'],
      'any',
      'Su’aalaha guud badanaa any ayaa la isticmaalaa.',
    ),
    exercise(
      '$id-p09',
      'chooseGrammar',
      'How ___ bottles do you need?',
      ['many', 'much', 'an', 'some'],
      'many',
      'Bottles waa plural countable, sidaas darteed many.',
    ),
    exercise(
      '$id-p10',
      'trueFalse',
      'Rice badanaa waa uncountable noun.',
      ['True', 'False'],
      'True',
      'Rice guud ahaan mid-mid looma tiriyo; qiyaas ayaa lala isticmaalaa.',
    ),
    exercise(
      '$id-p11',
      'readingComprehension',
      'Menu: tea USD 1, juice USD 2. Immisa ayay tea iyo juice wada yihiin?',
      ['USD 3', 'USD 1', 'USD 2', 'USD 4'],
      'USD 3',
      '1 + 2 = 3 dollars.',
    ),
    exercise(
      '$id-p12',
      'multipleChoice',
      'Jawaabta edebta leh dooro: “Anything else?”',
      ['That’s all, thank you.', 'Give food.', 'No want.', 'I is finished.'],
      'That’s all, thank you.',
      'Tani waa jawaab dabiici ah oo edeb leh.',
    ),
    exercise(
      '$id-p13',
      'speakingPrompt',
      'Ku hadal: samee laba jumladood oo ku saabsan ${seed.title}.',
      [],
      'Hawl hadal furan',
      'Isticmaal xog tusaale ah; xogtaada dhabta ah looma baahna.',
    ),
    exercise(
      '$id-p14',
      'shortWriting',
      'Qor laba jumladood oo sax ah oo ku saabsan ${seed.somali}.',
      [],
      'Hawl qoraal furan',
      'Hubi subject, verb iyo erayada quantity-ga.',
    ),
  ];
  if (!seed.review) return items;
  for (var i = 15; i <= 30; i++) {
    final chooseSome = i.isEven;
    items.add(
      exercise(
        '$id-p${i.toString().padLeft(2, '0')}',
        i % 3 == 0 ? 'fillInTheBlank' : 'multipleChoice',
        chooseSome ? 'We need ___ rice.' : 'How ___ apples are there?',
        chooseSome
            ? ['some', 'a', 'an', 'many']
            : ['many', 'much', 'some', 'a'],
        chooseSome ? 'some' : 'many',
        chooseSome
            ? 'Rice waa uncountable; some ayaa ku habboon.'
            : 'Apples waa plural countable; many ayaa ku habboon.',
      ),
    );
  }
  return items;
}

Json lesson(int number, LessonSeed seed) {
  final id = 'a1-u07-l${number.toString().padLeft(2, '0')}';
  final practice = practices(number, seed);
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-u07',
    'lessonNumber': number,
    'titleEnglish': seed.title,
    'titleSomali': seed.somali,
    'shortDescriptionSomali': seed.description,
    'learningObjectives': [
      'Faham erayada muhiimka ah ee ${seed.somali}.',
      'Isticmaal erayada jumlado English ah oo A1 ah.',
      'Ku tababar hadal, qoraal iyo faham.',
    ],
    'lessonType': seed.review
        ? 'review'
        : seed.grammarTopic == null
        ? 'vocabulary'
        : 'grammar',
    'estimatedMinutes': seed.review ? 30 : 20,
    'difficulty': 'A1',
    'isLocked': number != 1,
    'requiredPreviousLessonId': number == 1
        ? null
        : 'a1-u07-l${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': [for (final word in seed.words) vocabulary(word, seed.title)],
    'grammar': seed.grammarTopic,
    'examples': [for (final item in seed.examples) example(item.$1, item.$2)],
    'dialogues': seed.dialogues,
    'practiceExercises': practice,
    'speakingPractice':
        'Ku samee role-play ku saabsan ${seed.somali}. Isticmaal qof iyo xaalad tusaale ah.',
    'writingPractice':
        'Qor 6 ilaa 10 jumladood oo fudud oo ku saabsan ${seed.somali}.',
    'summarySomali':
        'Casharkan waxaad ku baratay ${seed.somali}, erayadiisa, jumlado dabiici ah iyo sida xaalad maalinle ah loogu adeegsado.',
    'quizQuestions': [
      for (var i = 0; i < 3; i++)
        {...practice[i], 'id': '$id-q${(i + 1).toString().padLeft(2, '0')}'},
    ],
  };
}

List<(String, String)> baseExamples(String a, String b, String c) => [
  (a, 'Tusaalaha koowaad ee casharka.'),
  (b, 'Tusaalaha labaad ee casharka.'),
  (c, 'Tusaalaha saddexaad ee casharka.'),
  ('Can I have some water, please?', 'Ma heli karaa xoogaa biyo ah, fadlan?'),
  ('We need some food.', 'Waxaan u baahan nahay xoogaa cunto ah.'),
  ('How much is this?', 'Immisa ayuu kani yahay?'),
];

List<Json> twoDialogues(String topic, String item) => [
  dialogue('$topic: wada hadal 1', [
    ('A', 'Do you like $item?', 'Ma jeceshahay $item?'),
    (
      'B',
      'Yes, I do. I really like it.',
      'Haa, waan jeclahay. Aad ayaan u jeclahay.',
    ),
    ('A', 'Would you like some?', 'Ma jeclaan lahayd xoogaa?'),
    ('B', 'Yes, please.', 'Haa, fadlan.'),
  ]),
  dialogue('$topic: wada hadal 2', [
    ('Customer', 'Can I have $item, please?', 'Ma heli karaa $item, fadlan?'),
    ('Server', 'Yes. Anything else?', 'Haa. Wax kale ma jiraan?'),
    ('Customer', 'That’s all, thank you.', 'Intaas ayaa dhan, mahadsanid.'),
    ('Server', 'You’re welcome.', 'Adigaa mudan.'),
  ]),
];

void main() {
  final likeGrammar = grammar(
    'a1-u07-like',
    'Like and Likes',
    'Like iyo likes',
    'Present Simple: I/you/we/they + like; he/she/it + likes. Diidmada waxaa lagu sameeyaa don’t/doesn’t + like.',
    'Subject + like/likes + food',
    [
      ('I like rice.', 'Waxaan jeclahay bariis.'),
      ('You like tea.', 'Waxaad jeceshahay shaah.'),
      ('We like fish.', 'Waxaan jecelnahay kalluun.'),
      ('They like bananas.', 'Waxay jecel yihiin moos.'),
      ('He likes soup.', 'Wuxuu jecel yahay maraq.'),
      ('She likes mangoes.', 'Waxay jeceshahay cambe.'),
    ],
    negatives: [
      ('I don’t like coffee.', 'Ma jecli bun.'),
      ('She doesn’t like milk.', 'Ma jecla caano.'),
    ],
    questions: [
      ('Do you like tea?', 'Ma jeceshahay shaah?'),
      ('Does he like fish?', 'Ma jecel yahay kalluun?'),
    ],
    mistakes: [
      'She like rice waa khalad; She likes rice ayaa sax ah.',
      'She doesn’t likes waa khalad; She doesn’t like ayaa sax ah.',
    ],
  );
  final countGrammar = grammar(
    'a1-u07-count',
    'Countable and Uncountable Nouns',
    'Magacyada la tirin karo iyo kuwa aan la tirin karin',
    'Countable nouns mid-mid ayaa loo tirin karaa; uncountable nouns waxaa lala isticmaalaa qiyaas ama container.',
    'number + countable; quantity/container + uncountable',
    [
      ('one apple', 'hal tufaax'),
      ('two eggs', 'laba ukun'),
      ('three bottles', 'saddex dhalo'),
      ('some rice', 'xoogaa bariis'),
      ('a glass of water', 'koob biyo ah'),
      ('a piece of bread', 'gabal rooti ah'),
    ],
    mistakes: [
      'A rice ha oran; some rice ama a kilo of rice dheh.',
      'Waters ha oran marka biyaha guud laga hadlayo.',
    ],
  );
  final articleGrammar = grammar(
    'a1-u07-articles',
    'A, An and Some',
    'A, an iyo some',
    'A waxaa lala isticmaalaa consonant sound; an vowel sound; some plural countable ama uncountable.',
    'a/an + singular countable; some + plural/uncountable',
    [
      ('a banana', 'hal moos'),
      ('a tomato', 'hal yaanyo'),
      ('an apple', 'hal tufaax'),
      ('an egg', 'hal ukun'),
      ('some apples', 'xoogaa tufaaxyo ah'),
      ('some water', 'xoogaa biyo ah'),
    ],
    mistakes: [
      'A apple waa khalad; an apple ayaa sax ah.',
      'A rice waa khalad; some rice ayaa sax ah.',
    ],
  );
  final someAnyGrammar = grammar(
    'a1-u07-some-any',
    'Some and Any',
    'Some iyo any',
    'Some badanaa positive sentences iyo polite requests; any badanaa questions iyo negatives.',
    'some/any + plural noun ama uncountable noun',
    [
      ('I have some apples.', 'Waxaan hayaa tufaaxyo.'),
      ('We need some rice.', 'Waxaan u baahan nahay bariis.'),
      ('She drinks some water.', 'Waxay cabtaa biyo.'),
      ('Can I have some tea?', 'Ma heli karaa shaah?'),
      ('There is some milk.', 'Waxaa jira caano.'),
      ('He buys some eggs.', 'Wuxuu iibsadaa ukumo.'),
    ],
    negatives: [
      ('I don’t have any sugar.', 'Ma hayo sonkor.'),
      ('We don’t need any bread.', 'Uma baahnin rooti.'),
    ],
    questions: [
      ('Do you have any milk?', 'Ma haysaan caano?'),
      ('Are there any bananas?', 'Moos ma jiraa?'),
    ],
    mistakes: [
      'Positive statement-ka caadiga ah some isticmaal; question/negative any isticmaal.',
    ],
  );
  final muchManyGrammar = grammar(
    'a1-u07-much-many',
    'Much, Many and Quantities',
    'Much, many iyo qiyaasaha',
    'Many waxaa lala isticmaalaa plural countable; much uncountable. A few countable, a little uncountable.',
    'how many + plural; how much + uncountable',
    [
      ('many apples', 'tufaaxyo badan'),
      ('many bottles', 'dhalooyin badan'),
      ('much water', 'biyo badan'),
      ('much rice', 'bariis badan'),
      ('a few eggs', 'ukumo yar'),
      ('a little milk', 'caano yar'),
    ],
    questions: [
      ('How many eggs?', 'Immisa ukun?'),
      ('How much sugar?', 'Intee sonkor ah?'),
    ],
    mistakes: ['How much apples waa khalad; how many apples ayaa sax ah.'],
  );

  final seeds = <LessonSeed>[
    LessonSeed(
      title: 'Common Foods',
      somali: 'Cuntooyinka caadiga ah',
      description:
          'Bar magacyada cuntooyinka caadiga ah iyo kuwa la tirin karo ama aan la tirin karin.',
      words: [
        w(
          'Rice',
          'bariis',
          note: 'Rice waa uncountable marka guud ahaan laga hadlayo.',
        ),
        w('Pasta', 'baasto'),
        w('Bread', 'rooti', note: 'Bread guud ahaan waa uncountable.'),
        w('Meat', 'hilib'),
        w('Beef', 'hilib lo’aad'),
        w('Chicken', 'digaag'),
        w('Fish', 'kalluun'),
        w('Egg', 'ukun'),
        w('Eggs', 'ukumo'),
        w('Potato', 'baradho keli ah'),
        w('Potatoes', 'baradho badan'),
        w('Salad', 'salaad khudaar'),
        w('Soup', 'maraq'),
        w('Beans', 'digir'),
        w('Cheese', 'farmaajo'),
        w('Milk', 'caano'),
        w('Sugar', 'sonkor'),
        w('Salt', 'cusbo'),
        w('Oil', 'saliid'),
        w('Flour', 'bur'),
      ],
      examples: baseExamples(
        'We eat rice and meat.',
        'She cooks chicken.',
        'I need some flour.',
      ),
      dialogues: twoDialogues('Cuntooyinka', 'rice and chicken'),
    ),
    LessonSeed(
      title: 'Fruits and Vegetables',
      somali: 'Miraha iyo khudaarta',
      description: 'Bar miraha, khudaarta iyo plural forms-ka muhiimka ah.',
      words: [
        w('Apple', 'tufaax'),
        w('Banana', 'moos'),
        w('Orange', 'liin macaan'),
        w('Mango', 'cambe'),
        w('Watermelon', 'qaraha'),
        w('Lemon', 'liin dhanaan'),
        w('Grapes', 'canab'),
        w('Tomato', 'yaanyo'),
        w('Onion', 'basal'),
        w('Carrot', 'karooto'),
        w('Cabbage', 'kaabash'),
        w('Cucumber', 'qajaar'),
        w('Pepper', 'basbaas'),
        w('Garlic', 'toon'),
        w('Spinach', 'isbinaaj'),
      ],
      examples: baseExamples(
        'I eat a banana.',
        'She buys three tomatoes.',
        'We need some onions.',
      ),
      dialogues: twoDialogues('Miraha iyo khudaarta', 'mangoes'),
    ),
    LessonSeed(
      title: 'Drinks',
      somali: 'Cabbitaannada',
      description: 'Bar cabbitaannada iyo container phrases-ka saxda ah.',
      words: [
        w('Water', 'biyo'),
        w('Tea', 'shaah'),
        w('Coffee', 'bun'),
        w('Milk', 'caano'),
        w('Juice', 'casiir'),
        w('Orange juice', 'casiir liin macaan'),
        w('Mango juice', 'casiir cambe'),
        w('Soft drink', 'cabbitaan fudud'),
        w('Hot drink', 'cabbitaan kulul'),
        w('Cold drink', 'cabbitaan qabow'),
        w('Cup', 'koob yar'),
        w('Glass', 'koob galaas'),
        w('Bottle', 'dhalo'),
      ],
      examples: baseExamples(
        'I drink a cup of tea.',
        'She has a glass of water.',
        'We buy a bottle of juice.',
      ),
      dialogues: twoDialogues('Cabbitaannada', 'a cup of tea'),
    ),
    LessonSeed(
      title: 'Meals of the Day',
      somali: 'Cuntooyinka waqtiyada maalinta',
      description: 'Bar breakfast, lunch, dinner iyo waqtiyada cuntada.',
      words: [
        w('Breakfast', 'quraac'),
        w('Lunch', 'qado'),
        w('Dinner', 'casho'),
        w('Meal', 'cunto waqtiyeed'),
        w('Snack', 'cunto fudud'),
        w('Main course', 'cuntada ugu weyn'),
        w('Dessert', 'macmacaan'),
      ],
      examples: baseExamples(
        'I eat breakfast in the morning.',
        'We have lunch at one o’clock.',
        'She cooks dinner in the evening.',
      ),
      dialogues: twoDialogues('Waqtiyada cuntada', 'breakfast'),
    ),
    LessonSeed(
      title: 'Likes and Dislikes',
      somali: 'Waxa la jecel yahay iyo waxa aan la jeclayn',
      description: 'Isticmaal like/likes iyo don’t/doesn’t like si sax ah.',
      words: [
        w('Like', 'jeclaan', type: 'verb'),
        w('Likes', 'wuu/way jecel yahay', type: 'verb'),
        w('Love', 'aad u jeclaan', type: 'verb'),
        w('Really like', 'aad u jeclaan', type: 'phrase'),
        w('Do not like', 'aan jeclayn', type: 'phrase'),
        w('Does not like', 'uusan/aysan jeclayn', type: 'phrase'),
        w(
          'Hate',
          'aad u neceb',
          type: 'verb',
          note: 'Hate waa eray xooggan; si taxaddar leh u isticmaal.',
        ),
      ],
      examples: baseExamples(
        'I like rice.',
        'She likes fish.',
        'He doesn’t like milk.',
      ),
      dialogues: twoDialogues('Waxa la jecel yahay', 'tea'),
      grammarTopic: likeGrammar,
    ),
    LessonSeed(
      title: 'Ordering Food and Drinks',
      somali: 'Dalbashada cuntada iyo cabbitaanka',
      description: 'Bar codsiyada edebta leh ee makhaayad iyo adeeg.',
      words: [
        w('I would like', 'waxaan jeclaan lahaa', type: 'polite phrase'),
        w('I’d like', 'waxaan jeclaan lahaa', type: 'short form'),
        w('Can I have', 'ma heli karaa', type: 'request'),
        w('Could I have', 'ma heli karaa', type: 'polite request'),
        w('Please', 'fadlan', type: 'politeness word'),
        w('Anything else', 'wax kale', type: 'question phrase'),
        w('That’s all', 'intaas ayaa dhan', type: 'phrase'),
        w('Customer', 'macmiil'),
        w('Waiter', 'kabalyeeri lab'),
        w('Waitress', 'kabalyeeri dhedig'),
        w('Shopkeeper', 'dukaanle'),
        w('Cashier', 'qasnaji'),
      ],
      examples: baseExamples(
        'I would like rice and chicken.',
        'Can I have a cup of tea?',
        'I’d like some water, please.',
      ),
      dialogues: twoDialogues('Dalbashada', 'rice and chicken'),
    ),
    LessonSeed(
      title: 'At a Restaurant',
      somali: 'Makhaayadda',
      description: 'Bar erayada iyo wada hadalka makhaayadda.',
      words: [
        w('Menu', 'liiska cuntada'),
        w('Table', 'miis'),
        w('Order', 'dalab'),
        w('Waiter', 'kabalyeeri lab'),
        w('Waitress', 'kabalyeeri dhedig'),
        w('Customer', 'macmiil'),
        w('Bill', 'biil'),
        w('Plate', 'saxan'),
        w('Spoon', 'qaaddo'),
        w('Fork', 'fargeeto'),
        w('Knife', 'mindi'),
        w('Cup', 'koob'),
        w('Glass', 'galaas'),
        w('Napkin', 'masar miis'),
      ],
      examples: baseExamples(
        'May I see the menu, please?',
        'I would like chicken and rice.',
        'Can I have the bill, please?',
      ),
      dialogues: twoDialogues('Makhaayadda', 'the menu'),
    ),
    LessonSeed(
      title: 'At a Shop or Market',
      somali: 'Dukaanka ama suuqa',
      description: 'Bar qiime weydiinta, qiyaasaha iyo baakadaha suuqa.',
      words: [
        w('Kilo', 'kiilo'),
        w('Half a kilo', 'nus kiilo'),
        w('Bottle', 'dhalo'),
        w('Bag', 'bac'),
        w('Packet', 'baakad yar'),
        w('Box', 'sanduuq'),
        w('Can', 'qasacad'),
        w('Cup', 'koob'),
        w('Glass', 'galaas'),
        w('Piece', 'gabal'),
        w('Price', 'qiime'),
        w('Total', 'wadarta'),
      ],
      examples: baseExamples(
        'How much are these?',
        'I would like one kilo of rice.',
        'Give me two bottles of water, please.',
      ),
      dialogues: twoDialogues('Dukaanka iyo suuqa', 'one kilo of rice'),
    ),
    LessonSeed(
      title: 'Countable and Uncountable Nouns',
      somali: 'Magacyada la tirin karo iyo kuwa aan si toos ah loo tirin karin',
      description:
          'Kala saar countable iyo uncountable nouns adigoo adeegsanaya qiyaas sax ah.',
      words: [
        w('Countable noun', 'magac la tirin karo', type: 'grammar term'),
        w(
          'Uncountable noun',
          'magac aan si toos ah loo tirin',
          type: 'grammar term',
        ),
        w('Container', 'weel'),
        w('Quantity', 'qiyaas'),
        w('A glass of water', 'galaas biyo ah', type: 'quantity phrase'),
        w('A kilo of rice', 'kiilo bariis ah', type: 'quantity phrase'),
        w('A spoon of sugar', 'qaaddo sonkor ah', type: 'quantity phrase'),
        w('A cup of tea', 'koob shaah ah', type: 'quantity phrase'),
        w('A piece of bread', 'gabal rooti ah', type: 'quantity phrase'),
      ],
      examples: baseExamples(
        'I have two apples.',
        'We need some rice.',
        'She drinks a glass of water.',
      ),
      dialogues: twoDialogues('Tirinta cuntada', 'a glass of water'),
      grammarTopic: countGrammar,
    ),
    LessonSeed(
      title: 'A, An and Some',
      somali: 'Isticmaalka A, An iyo Some',
      description:
          'Dooro a, an ama some iyadoo lagu salaynayo dhawaaqa iyo nooca noun-ka.',
      words: [
        w('A', 'hal', type: 'article'),
        w('An', 'hal', type: 'article'),
        w('Some', 'xoogaa/qaar', type: 'determiner'),
        w('Singular', 'keli', type: 'grammar term'),
        w('Plural', 'badan', type: 'grammar term'),
        w('Vowel sound', 'dhawaaq shaqal', type: 'grammar term'),
        w('Consonant sound', 'dhawaaq shibbane', type: 'grammar term'),
      ],
      examples: baseExamples(
        'I eat a banana.',
        'She has an apple.',
        'We need some water.',
      ),
      dialogues: twoDialogues('A, an iyo some', 'an orange'),
      grammarTopic: articleGrammar,
    ),
    LessonSeed(
      title: 'Some and Any',
      somali: 'Isticmaalka Some iyo Any',
      description:
          'Some ku isticmaal positive iyo codsi; any ku isticmaal su’aal iyo negative.',
      words: [
        w('Some', 'xoogaa/qaar', type: 'determiner'),
        w('Any', 'wax/qaarna', type: 'determiner'),
        w('Positive sentence', 'jumlad xaqiijin ah', type: 'grammar term'),
        w('Negative sentence', 'jumlad diidmo ah', type: 'grammar term'),
        w('Question', 'su’aal', type: 'grammar term'),
        w('Offer', 'soo jeedin', type: 'phrase type'),
        w('Polite request', 'codsi edeb leh', type: 'phrase type'),
      ],
      examples: baseExamples(
        'I have some apples.',
        'Do you have any milk?',
        'I don’t have any sugar.',
      ),
      dialogues: twoDialogues('Some iyo any', 'some tea'),
      grammarTopic: someAnyGrammar,
    ),
    LessonSeed(
      title: 'Much, Many and Basic Quantities',
      somali: 'Much, Many iyo qiyaasaha fudud',
      description:
          'Much, many, a little, a few iyo a lot of si fudud u isticmaal.',
      words: [
        w('Much', 'badan oo aan la tirin', type: 'determiner'),
        w('Many', 'badan oo la tirin karo', type: 'determiner'),
        w('How much', 'intee/immisa oo aan la tirin', type: 'question phrase'),
        w('How many', 'immisa oo la tirin karo', type: 'question phrase'),
        w('A little', 'wax yar', type: 'quantity phrase'),
        w('A few', 'tiro yar', type: 'quantity phrase'),
        w('A lot of', 'wax badan', type: 'quantity phrase'),
      ],
      examples: baseExamples(
        'How many eggs do you need?',
        'How much sugar do you need?',
        'We have a lot of rice.',
      ),
      dialogues: twoDialogues('Much iyo many', 'a few apples'),
      grammarTopic: muchManyGrammar,
    ),
    LessonSeed(
      title: 'Reading a Menu',
      somali: 'Akhrinta menu-ga',
      description:
          'Akhri menu, isbarbar dhig qiimaha oo xisaabi wadarta fudud.',
      words: [
        w('Main dish', 'cuntada ugu weyn'),
        w('Snack', 'cunto fudud'),
        w('Dessert', 'macmacaan'),
        w('Drink', 'cabbitaan'),
        w('Price', 'qiime'),
        w('Cheapest', 'ugu jaban'),
        w('Total', 'wadarta'),
        w('Rice and chicken', 'bariis iyo digaag'),
        w('Fish and salad', 'kalluun iyo salaad'),
        w('Soup', 'maraq'),
        w('Tea', 'shaah'),
        w('Mango juice', 'casiir cambe'),
      ],
      examples: baseExamples(
        'Rice and chicken costs five dollars.',
        'Fish and salad costs six dollars.',
        'Tea and soup cost four dollars together.',
      ),
      dialogues: twoDialogues('Akhrinta menu-ga', 'fish and salad'),
    ),
    LessonSeed(
      title: 'Talking About Food Habits',
      somali: 'Ka hadalka caadooyinka cuntada',
      description:
          'Isticmaal Present Simple iyo frequency words si aad uga hadasho qof tusaale ah.',
      words: [
        w('Usually', 'inta badan', type: 'frequency adverb'),
        w('Often', 'marar badan', type: 'frequency adverb'),
        w('Sometimes', 'mararka qaar', type: 'frequency adverb'),
        w('Never', 'marnaba', type: 'frequency adverb'),
        w('For breakfast', 'quraac ahaan', type: 'time phrase'),
        w('For lunch', 'qado ahaan', type: 'time phrase'),
        w('At night', 'habeenkii', type: 'time phrase'),
      ],
      examples: baseExamples(
        'I usually eat bread and eggs for breakfast.',
        'I often eat rice and chicken for lunch.',
        'I don’t drink coffee at night.',
      ),
      dialogues: twoDialogues('Caadooyinka cuntada', 'breakfast'),
    ),
    LessonSeed(
      title: 'Unit Review',
      somali: 'Dib-u-eegista Unit 7',
      description:
          'Dib u eeg cuntada, cabbitaannada, dalbashada, grammar-ka quantities iyo menu reading.',
      words: [
        w('Food', 'cunto'),
        w('Drink', 'cabbitaan'),
        w('Order', 'dalab'),
        w('Countable', 'la tirin karo', type: 'grammar term'),
        w('Uncountable', 'aan si toos ah loo tirin', type: 'grammar term'),
        w('Some', 'xoogaa/qaar'),
        w('Any', 'wax/qaarna'),
        w('Much', 'badan oo uncountable ah'),
        w('Many', 'badan oo countable ah'),
        w('Menu', 'liiska cuntada'),
      ],
      examples: baseExamples(
        'I would like some rice.',
        'Do you have any juice?',
        'How many bottles do you need?',
      ),
      dialogues: twoDialogues('Dib-u-eegista Unit 7', 'some food'),
      review: true,
    ),
  ];

  final lessons = [
    for (var i = 0; i < seeds.length; i++) lesson(i + 1, seeds[i]),
  ];
  final quiz = _unitQuiz();
  final unit = {
    'id': 'a1-u07',
    'levelId': 'A1',
    'unitNumber': 7,
    'titleEnglish': 'Food and Drinks',
    'titleSomali': 'Cuntada iyo Cabbitaannada',
    'introductionSomali':
        'Unit-kan waxaad ku baranaysaa cuntooyinka, cabbitaannada, waxa la jecel yahay, dalbashada, suuqa, countable/uncountable nouns, a/an/some, some/any, much/many iyo akhrinta menu-ga.',
    'requiredPreviousUnitId': 'a1-u06',
    'lessons': lessons,
    'unitQuiz': quiz,
    'passingScore': 70,
  };
  File(
    'assets/content/a1/unit_07.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(unit)}\n');
}

List<Json> _unitQuiz() {
  final q = <Json>[];
  void add(
    String type,
    String text,
    List<String> options,
    String answer,
    String why,
  ) {
    q.add(
      exercise(
        'a1-u07-q${(q.length + 1).toString().padLeft(2, '0')}',
        type,
        text,
        options,
        answer,
        why,
      ),
    );
  }

  // 7 food and drink vocabulary questions.
  add(
    'multipleChoice',
    'Rice maxay ka dhigan tahay?',
    ['Bariis', 'Caano', 'Biyo', 'Tufaax'],
    'Bariis',
    'Rice waa bariis.',
  );
  add(
    'multipleChoice',
    'Cabbitaankee ayaa ah “tea”?',
    ['Shaah', 'Bun', 'Casiir', 'Caano'],
    'Shaah',
    'Tea waa shaah.',
  );
  add(
    'multipleChoice',
    'Dooro fruit-ka.',
    ['Mango', 'Rice', 'Salt', 'Meat'],
    'Mango',
    'Mango waa miro.',
  );
  add(
    'multipleChoice',
    'Dooro vegetable-ka.',
    ['Carrot', 'Juice', 'Bread', 'Fish'],
    'Carrot',
    'Carrot waa khudaar.',
  );
  add(
    'multipleChoice',
    'A ___ of water.',
    ['glass', 'plate', 'fork', 'menu'],
    'glass',
    'A glass of water waa qiyaas sax ah.',
  );
  add(
    'multipleChoice',
    'Breakfast waa…',
    ['quraac', 'qado', 'casho', 'macmacaan'],
    'quraac',
    'Breakfast waa quraac.',
  );
  add(
    'multipleChoice',
    'Bill maxay ka dhigan tahay makhaayad?',
    ['biil', 'miis', 'qaaddo', 'liis'],
    'biil',
    'Bill waa lacagta lagugu leeyahay.',
  );
  // 5 likes/dislikes.
  add(
    'chooseGrammar',
    'She ___ fish.',
    ['likes', 'like', 'liking', 'liked'],
    'likes',
    'She waxaa la socda likes.',
  );
  add(
    'chooseGrammar',
    'I ___ like coffee.',
    ['don’t', 'doesn’t', 'isn’t', 'aren’t'],
    'don’t',
    'I waxaa la socda don’t.',
  );
  add(
    'chooseGrammar',
    'He doesn’t ___ milk.',
    ['like', 'likes', 'liked', 'liking'],
    'like',
    'Doesn’t kadib base verb like.',
  );
  add(
    'chooseGrammar',
    '___ you like tea?',
    ['Do', 'Does', 'Is', 'Are'],
    'Do',
    'Do you like…?',
  );
  add(
    'chooseGrammar',
    'Does she like chicken? — Yes, she ___.',
    ['does', 'do', 'is', 'likes'],
    'does',
    'Short answer-ku waa Yes, she does.',
  );
  // 5 restaurant and ordering.
  add(
    'multipleChoice',
    'Codsiga ugu edebta badan dooro.',
    ['I would like soup, please.', 'Give soup.', 'I want now.', 'Soup me.'],
    'I would like soup, please.',
    'Would like waa codsi edeb leh.',
  );
  add(
    'multipleChoice',
    '“Anything else?” jawaabtee ku habboon?',
    ['That’s all, thank you.', 'I no.', 'Else food.', 'You stop.'],
    'That’s all, thank you.',
    'Waa jawaab dabiici ah.',
  );
  add(
    'multipleChoice',
    'Maxaad dalbashada ka akhridaa?',
    ['Menu', 'Napkin', 'Fork', 'Table'],
    'Menu',
    'Menu waa liiska cuntada.',
  );
  add(
    'multipleChoice',
    'Biilka sidee si edeb leh loo codsadaa?',
    ['Can I have the bill, please?', 'Bill now.', 'You bill.', 'I am bill.'],
    'Can I have the bill, please?',
    'Can I have…please waa codsi edeb leh.',
  );
  add(
    'multipleChoice',
    'Qofka cuntada dalbanaya waa…',
    ['customer', 'menu', 'plate', 'bill'],
    'customer',
    'Customer waa macmiilka.',
  );
  // 5 countable/uncountable.
  add(
    'multipleChoice',
    'Kee countable ah?',
    ['apple', 'rice', 'water', 'sugar'],
    'apple',
    'Apple mid-mid ayaa loo tirin karaa.',
  );
  add(
    'multipleChoice',
    'Kee uncountable ah?',
    ['milk', 'egg', 'bottle', 'banana'],
    'milk',
    'Milk guud ahaan qiyaas ayaa lagu cabbiraa.',
  );
  add(
    'multipleChoice',
    'Qaabka saxda ah ee bread dooro.',
    ['a piece of bread', 'a bread', 'two bread', 'an bread'],
    'a piece of bread',
    'Bread waxaa lagu qiyaasi karaa piece.',
  );
  add(
    'multipleChoice',
    'Qaabka saxda ah ee rice dooro.',
    ['a kilo of rice', 'an rice', 'three rice', 'a rice'],
    'a kilo of rice',
    'Rice waxaa lagu qiyaasi karaa kilo.',
  );
  add(
    'trueFalse',
    'Eggs waa plural countable noun.',
    ['True', 'False'],
    'True',
    'Eggs waa la tirin karaa waana plural.',
  );
  // 4 a/an/some.
  add(
    'fillInTheBlank',
    '___ apple',
    ['an', 'a', 'some', 'any'],
    'an',
    'Apple wuxuu ku bilaabmaa vowel sound.',
  );
  add(
    'fillInTheBlank',
    '___ banana',
    ['a', 'an', 'some', 'much'],
    'a',
    'Banana wuxuu ku bilaabmaa consonant sound.',
  );
  add(
    'fillInTheBlank',
    'We need ___ rice.',
    ['some', 'a', 'an', 'many'],
    'some',
    'Rice waa uncountable.',
  );
  add(
    'fillInTheBlank',
    'She buys ___ eggs.',
    ['some', 'an', 'a', 'much'],
    'some',
    'Eggs waa plural countable.',
  );
  // 4 some/any.
  add(
    'fillInTheBlank',
    'I have ___ apples.',
    ['some', 'any', 'a', 'much'],
    'some',
    'Positive sentence-ka some ayaa caadi ah.',
  );
  add(
    'fillInTheBlank',
    'Do you have ___ milk?',
    ['any', 'some', 'many', 'a'],
    'any',
    'Question-ka guud any ayaa caadi ah.',
  );
  add(
    'fillInTheBlank',
    'We don’t need ___ sugar.',
    ['any', 'some', 'many', 'an'],
    'any',
    'Negative sentence-ka any ayaa caadi ah.',
  );
  add(
    'fillInTheBlank',
    'Can I have ___ water?',
    ['some', 'any', 'a', 'many'],
    'some',
    'Polite request-ka some ayaa sax ah.',
  );
  // 3 much/many.
  add(
    'fillInTheBlank',
    'How ___ bottles?',
    ['many', 'much', 'some', 'a'],
    'many',
    'Bottles waa plural countable.',
  );
  add(
    'fillInTheBlank',
    'How ___ water?',
    ['much', 'many', 'an', 'few'],
    'much',
    'Water waa uncountable.',
  );
  add(
    'multipleChoice',
    'Dooro qaabka saxda ah.',
    ['a few apples', 'a little apples', 'much apples', 'an apples'],
    'a few apples',
    'A few waxaa lala isticmaalaa plural countable.',
  );
  // 2 menu-reading questions. Menu: rice/chicken $5, fish/salad $6, soup $3, tea $1, juice $2.
  add(
    'readingComprehension',
    'Menu: soup USD 3, tea USD 1. Wadartu waa immisa?',
    ['USD 4', 'USD 3', 'USD 2', 'USD 5'],
    'USD 4',
    '3 + 1 = 4 dollars.',
  );
  add(
    'readingComprehension',
    'Menu: fish and salad USD 6; rice and chicken USD 5. Kee qaali badan?',
    ['Fish and salad', 'Rice and chicken', 'Isku qiime', 'Tea'],
    'Fish and salad',
    '6 dollars ayaa ka badan 5 dollars.',
  );
  return q;
}
