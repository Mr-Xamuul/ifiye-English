import 'dart:convert';
import 'dart:io';

import 'generate_a1_unit7.dart' as base;

typedef Json = Map<String, Object?>;
typedef Word = ({String en, String so, String plural, String type});

Word w(String en, String so, {String plural = '', String type = 'noun'}) =>
    (en: en, so: so, plural: plural, type: type);

Json vocab(Word word, String title) => {
  'englishWord': word.en,
  'somaliMeaning': word.so,
  'partOfSpeech': word.type,
  'pronunciation': _pronunciation(word.en),
  'exampleEnglish': _exampleFor(word.en, title),
  'exampleSomali': 'Waxaa jira ${word.so} guriga ama qolka tusaalaha ah.',
  'explanationSomali': word.plural.isEmpty
      ? '${word.en} waxaa loola jeedaa ${word.so}.'
      : '${word.en} waa singular; plural-kiisu waa ${word.plural}.',
  'commonMistakeSomali': word.en.toLowerCase() == 'furniture'
      ? 'Ha oran furnitures; furniture waa magaca category-ga. Waxaad oran kartaa pieces of furniture.'
      : '',
};

String _pronunciation(String word) {
  const map = {
    'home': 'howm',
    'house': 'haws',
    'apartment': 'a-paart-ment',
    'building': 'bil-ding',
    'room': 'ruum',
    'floor': 'floor',
    'door': 'door',
    'window': 'win-dow',
    'wall': 'wool',
    'roof': 'ruuf',
    'stairs': 'steers',
    'balcony': 'bal-ka-ni',
    'garden': 'gaar-dan',
    'kitchen': 'ki-jan',
    'bathroom': 'baath-ruum',
    'bedroom': 'bed-ruum',
    'living room': 'li-ving ruum',
    'sofa': 'so-fa',
    'chair': 'jeer',
    'table': 'tey-bal',
    'television': 'te-la-vi-zhan',
    'curtain': 'kar-tan',
    'wardrobe': 'woor-droob',
    'mirror': 'mi-rar',
    'pillow': 'pi-low',
    'blanket': 'blan-kit',
    'refrigerator': 'ri-fri-ja-rey-tar',
    'cupboard': 'ka-bard',
    'toothbrush': 'tuuth-brash',
    'washing machine': 'wo-shing ma-shiin',
    'furniture': 'far-ni-jar',
  };
  return map[word.toLowerCase()] ?? word.toLowerCase().replaceAll('-', ' ');
}

String _exampleFor(String word, String title) {
  final lower = word.toLowerCase();
  if (title.contains('Rooms')) return 'The $lower is part of the home.';
  if (title.contains('Objects')) return 'The $lower is in the room.';
  return 'There is a $lower in the example.';
}

class Seed {
  const Seed(
    this.title,
    this.somali,
    this.description,
    this.words,
    this.examples,
    this.dialogues, {
    this.grammar,
    this.review = false,
  });
  final String title;
  final String somali;
  final String description;
  final List<Word> words;
  final List<(String, String)> examples;
  final List<Json> dialogues;
  final Json? grammar;
  final bool review;
}

List<Json> dialogues(String topic, String object) => [
  base.dialogue('$topic: alaab raadis', [
    ('A', 'Where is the $object?', 'Aaway $object?'),
    ('B', 'It is on the table.', 'Waxay saaran tahay miiska.'),
    ('A', 'Is it next to the book?', 'Ma buugga ayay ku xigtaa?'),
    ('B', 'Yes, it is.', 'Haa, way ku xigtaa.'),
  ]),
  base.dialogue('$topic: qol sharaxid', [
    ('A', 'Is there a $object in the room?', 'Qolka ma ku jiraa $object?'),
    ('B', 'Yes, there is.', 'Haa, way ku jirtaa.'),
    ('A', 'Are there any chairs?', 'Kuraas ma jiraan?'),
    ('B', 'No, there aren’t.', 'Maya, ma jiraan.'),
  ]),
];

List<(String, String)> examples(String a, String b, String c) => [
  (a, 'Tusaalaha koowaad ee goobta.'),
  (b, 'Tusaalaha labaad ee goobta.'),
  (c, 'Tusaalaha saddexaad ee goobta.'),
  ('There is a chair in the room.', 'Qolka waxaa ku jira kursi.'),
  ('There are two windows.', 'Waxaa jira laba daaqadood.'),
  ('Where is the book?', 'Aaway buuggu?'),
];

List<Json> practice(int number, Seed seed) {
  final id = 'a1-u08-l${number.toString().padLeft(2, '0')}';
  final one = seed.words[0];
  final two = seed.words.length > 1 ? seed.words[1] : one;
  final three = seed.words.length > 2 ? seed.words[2] : two;
  final result = <Json>[
    base.exercise(
      '$id-p01',
      'multipleChoice',
      '“${one.en}” maxay ka dhigan tahay?',
      [one.so, two.so, three.so, 'cunto'],
      one.so,
      '${one.en} macnihiisu waa ${one.so}.',
    ),
    base.exercise(
      '$id-p02',
      'englishToSomali',
      'U turjun: ${two.en}',
      [two.so, one.so, three.so, 'waqti'],
      two.so,
      '${two.en} waa ${two.so}.',
    ),
    base.exercise(
      '$id-p03',
      'somaliToEnglish',
      'English ku dooro: ${three.so}',
      [three.en, one.en, two.en, 'Monday'],
      three.en,
      '${three.so} waa ${three.en}.',
    ),
    base.exercise(
      '$id-p04',
      'chooseGrammar',
      'Dooro qaabka saxda ah: ___ a table in the room.',
      ['There is', 'There are', 'Are there', 'They are'],
      'There is',
      'Table waa singular, sidaas darteed there is.',
    ),
    base.exercise(
      '$id-p05',
      'chooseGrammar',
      'Dooro qaabka saxda ah: ___ two chairs.',
      ['There are', 'There is', 'Is there', 'It is'],
      'There are',
      'Two chairs waa plural.',
    ),
    base.exercise(
      '$id-p06',
      'fillInTheBlank',
      'The book is ___ the table.',
      ['on', 'in', 'under', 'between'],
      'on',
      'On waxay muujisaa in shay dusha saaran yahay.',
    ),
    base.exercise(
      '$id-p07',
      'fillInTheBlank',
      'The shoes are ___ the bed.',
      ['under', 'on', 'above', 'opposite'],
      'under',
      'Under waxay muujisaa hoosta.',
    ),
    base.exercise(
      '$id-p08',
      'arrangeSentence',
      'Habee: room / a / there / is / bed / the / in',
      [
        'There is a bed in the room.',
        'A bed there room is.',
        'The room a bed in.',
        'Is there room bed.',
      ],
      'There is a bed in the room.',
      'There is + singular noun + place.',
    ),
    base.exercise(
      '$id-p09',
      'chooseGrammar',
      'Su’aasha plural-ka saxda ah dooro.',
      [
        'Where are the keys?',
        'Where is the keys?',
        'Where the keys is?',
        'Where keys are the?',
      ],
      'Where are the keys?',
      'Keys waa plural, sidaas darteed where are.',
    ),
    base.exercise(
      '$id-p10',
      'trueFalse',
      '“There is two chairs” waa jumlad sax ah.',
      ['True', 'False'],
      'False',
      'Waxaa sax ah: There are two chairs.',
    ),
    base.exercise(
      '$id-p11',
      'readingComprehension',
      'Scenario: A bed is near the window. A lamp is next to the bed. Aaway lamp-ku?',
      ['Next to the bed', 'Under the window', 'Behind the door', 'Outside'],
      'Next to the bed',
      'Scenario-gu wuxuu sheegay next to the bed.',
    ),
    base.exercise(
      '$id-p12',
      'multipleChoice',
      'Dooro jawaabta: Is there a bathroom?',
      ['Yes, there is.', 'Yes, there are.', 'Yes, it are.', 'There bathroom.'],
      'Yes, there is.',
      'Is there waxaa looga jawaabaa yes, there is.',
    ),
    base.exercise(
      '$id-p13',
      'speakingPrompt',
      'Ku hadal: sharax meesha saddex shay yaallaan.',
      [],
      'Hawl hadal furan',
      'Isticmaal qol iyo alaab tusaale ah.',
    ),
    base.exercise(
      '$id-p14',
      'shortWriting',
      'Qor laba jumladood oo ku saabsan ${seed.somali}.',
      [],
      'Hawl qoraal furan',
      'Isticmaal there is/are iyo preposition sax ah.',
    ),
  ];
  if (seed.review) {
    for (var i = 15; i <= 30; i++) {
      final plural = i.isEven;
      result.add(
        base.exercise(
          '$id-p${i.toString().padLeft(2, '0')}',
          'chooseGrammar',
          plural
              ? '___ three windows in the room.'
              : '___ a garden behind the house.',
          plural
              ? ['There are', 'There is', 'Is there', 'It is']
              : ['There is', 'There are', 'Are there', 'They are'],
          plural ? 'There are' : 'There is',
          plural ? 'Three windows waa plural.' : 'A garden waa singular.',
        ),
      );
    }
  }
  return result;
}

Json lesson(int number, Seed seed) {
  final id = 'a1-u08-l${number.toString().padLeft(2, '0')}';
  final exercises = practice(number, seed);
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-u08',
    'lessonNumber': number,
    'titleEnglish': seed.title,
    'titleSomali': seed.somali,
    'shortDescriptionSomali': seed.description,
    'learningObjectives': [
      'Bar erayada muhiimka ah ee ${seed.somali}.',
      'Isticmaal grammar-ka goobta jumlado A1 ah.',
      'Ku tababar hadal, qoraal iyo faham.',
    ],
    'lessonType': seed.review
        ? 'review'
        : seed.grammar == null
        ? 'vocabulary'
        : 'grammar',
    'estimatedMinutes': seed.review ? 30 : 20,
    'difficulty': 'A1',
    'isLocked': number != 1,
    'requiredPreviousLessonId': number == 1
        ? null
        : 'a1-u08-l${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': [for (final item in seed.words) vocab(item, seed.title)],
    'grammar': seed.grammar,
    'examples': [
      for (final item in seed.examples) base.example(item.$1, item.$2),
    ],
    'dialogues': seed.dialogues,
    'practiceExercises': exercises,
    'speakingPractice':
        'Sharax qol ama guri tusaale ah adigoo adeegsanaya erayada casharka.',
    'writingPractice':
        'Qor 6 ilaa 10 jumladood oo sharaxaya ${seed.somali}; ha bixin xogta gurigaaga dhabta ah.',
    'summarySomali':
        'Waxaad baratay ${seed.somali}, jumladaha goobta iyo sida alaabta si cad loogu sharaxo.',
    'quizQuestions': [
      for (var i = 0; i < 3; i++)
        {...exercises[i], 'id': '$id-q${(i + 1).toString().padLeft(2, '0')}'},
    ],
  };
}

Json grammarTopic(
  String id,
  String title,
  String somali,
  String rule,
  String structure,
  List<(String, String)> positive,
  List<(String, String)> negative,
  List<(String, String)> questions,
  List<String> mistakes,
) => base.grammar(
  id,
  title,
  somali,
  rule,
  structure,
  positive,
  negatives: negative,
  questions: questions,
  mistakes: mistakes,
);

void main() {
  final thereGrammar = grammarTopic(
    'a1-u08-there',
    'There Is and There Are',
    'There is iyo there are',
    'There is waxaa loo isticmaalaa hal shay; there are waxyaabo badan. Negative-ku waa there isn’t/aren’t; su’aashuna is there/are there.',
    'There is + singular; There are + plural',
    [
      ('There is a chair.', 'Waxaa jira kursi.'),
      ('There is a bed near the window.', 'Daaqadda agteeda sariir baa taal.'),
      ('There is a television.', 'Telefishan baa jira.'),
      ('There are two windows.', 'Laba daaqadood baa jira.'),
      ('There are four chairs.', 'Afar kursi baa jira.'),
      ('There are some books.', 'Buugaag baa jira.'),
    ],
    [
      ('There isn’t a table.', 'Miis ma jiro.'),
      ('There aren’t any chairs.', 'Kuraas ma jiraan.'),
    ],
    [
      ('Is there a bathroom?', 'Musqul ma jirtaa?'),
      ('Are there any windows?', 'Daaqado ma jiraan?'),
    ],
    [
      'There is two chairs waa khalad; there are two chairs ayaa sax ah.',
      'There are a bed waa khalad; there is a bed ayaa sax ah.',
    ],
  );
  final placeGrammar = grammarTopic(
    'a1-u08-place',
    'In, On and Under',
    'In, on iyo under',
    'In waa gudaha, on waa dusha, under waa hoosta.',
    'Subject + be + preposition + place',
    [
      ('The clothes are in the wardrobe.', 'Dharku wuxuu ku jiraa armaajada.'),
      ('The water is in the bottle.', 'Biyuhu waxay ku jiraan dhalada.'),
      ('The book is on the table.', 'Buuggu miiska ayuu saaran yahay.'),
      ('The clock is on the wall.', 'Saacaddu derbiga ayay saaran tahay.'),
      ('The shoes are under the bed.', 'Kabuhu sariirta ayay hoos yaallaan.'),
      ('The carpet is under the table.', 'Rooggu miiska ayuu hoos yaal.'),
    ],
    [('The keys are not on the table.', 'Furayaashu miiska ma saarna.')],
    [('Is it in the bag?', 'Boorsada ma ku jirtaa?')],
    ['On the wall ayaa sax ah marka shay derbi ku dheggan yahay.'],
  );
  final morePlace = grammarTopic(
    'a1-u08-more-place',
    'More Prepositions of Place',
    'Erayo dheeraad ah oo goobta',
    'Next to waa dhinac aad ugu dhow; near waa meel u dhow. Between, behind, in front of, above, below iyo opposite waxay bixiyaan goob cad.',
    'Noun + be + place phrase',
    [
      ('The lamp is next to the bed.', 'Laambaddu sariirta ayay ku xigtaa.'),
      ('The chair is near the door.', 'Kursigu albaabka ayuu u dhow yahay.'),
      ('The table is between the chairs.', 'Miisku kuraasta ayuu u dhexeeyaa.'),
      ('The broom is behind the door.', 'Xaaqinku albaabka ayuu ka dambeeyaa.'),
      (
        'The car is in front of the house.',
        'Baabuurku guriga ayuu ka horreeyaa.',
      ),
      ('The picture is above the sofa.', 'Sawirku fadhiga ayuu ka sarreeyaa.'),
    ],
    [
      (
        'The shop is not opposite the house.',
        'Dukaanku guriga kama soo horjeedo.',
      ),
    ],
    [('Is the chair near the door?', 'Kursigu albaabka ma u dhow yahay?')],
    ['Next to iyo near isku mid ma aha: next to waa dhinac aad ugu dhow.'],
  );
  final whereGrammar = grammarTopic(
    'a1-u08-where',
    'Where Is and Where Are',
    'Where is iyo where are',
    'Where is waxaa lala isticmaalaa hal shay; where are waxaa lala isticmaalaa waxyaabo badan. Jawaabtu waa it is ama they are.',
    'Where is + singular? Where are + plural?',
    [
      ('It is on the table.', 'Miiska ayay saaran tahay.'),
      ('It is near the door.', 'Albaabka ayay u dhowdahay.'),
      ('It is in the bag.', 'Boorsada ayay ku jirtaa.'),
      ('They are under the bed.', 'Sariirta ayay hoos yaallaan.'),
      ('They are next to the door.', 'Albaabka ayay ku xigaan.'),
      ('They are in the kitchen.', 'Jikada ayay ku jiraan.'),
    ],
    [('It isn’t on the table.', 'Miiska ma saarna.')],
    [
      ('Where is the book?', 'Aaway buuggu?'),
      ('Where are the keys?', 'Aaway furayaashu?'),
    ],
    ['Where is the keys waa khalad; where are the keys ayaa sax ah.'],
  );
  final demonstrativeGrammar = grammarTopic(
    'a1-u08-demonstratives',
    'This, That, These and Those',
    'This, that, these iyo those',
    'This/that waa singular; these/those waa plural. This/these dhow, that/those fog.',
    'This/That is; These/Those are',
    [
      ('This is a chair.', 'Kani waa kursi.'),
      ('That is a window.', 'Kaasi waa daaqad.'),
      ('This is my phone.', 'Kani waa telefoonkayga.'),
      ('These are books.', 'Kuwani waa buugaag.'),
      ('Those are plates.', 'Kuwaasi waa saxamo.'),
      ('These are my keys.', 'Kuwani waa furayaashayda.'),
    ],
    [('Those are not my shoes.', 'Kuwaasi ma aha kabahayga.')],
    [
      ('What is this?', 'Waa maxay kani?'),
      ('What are those?', 'Waa maxay kuwaasi?'),
    ],
    ['These is waa khalad; these are ayaa sax ah.'],
  );

  final seeds = <Seed>[
    Seed(
      'Types of Homes',
      'Noocyada guryaha',
      'Bar noocyada guryaha iyo qaybaha bannaanka iyo dhismaha.',
      [
        w('Home', 'hoy/guri'),
        w('House', 'dhismaha guri', plural: 'houses'),
        w('Apartment', 'guri dabaq ah', plural: 'apartments'),
        w('Flat', 'guri dabaq ah', plural: 'flats'),
        w('Building', 'dhisme', plural: 'buildings'),
        w('Room', 'qol', plural: 'rooms'),
        w('Floor', 'dabaq', plural: 'floors'),
        w('Door', 'albaab', plural: 'doors'),
        w('Window', 'daaqad', plural: 'windows'),
        w('Wall', 'derbi', plural: 'walls'),
        w('Roof', 'saqaf', plural: 'roofs'),
        w('Gate', 'albaabka weyn', plural: 'gates'),
        w('Stairs', 'jaranjaro', type: 'plural noun'),
        w('Balcony', 'balakoon', plural: 'balconies'),
        w('Yard', 'barxad', plural: 'yards'),
        w('Garden', 'beer yar', plural: 'gardens'),
      ],
      examples(
        'This is my house.',
        'I live in an apartment.',
        'There is a garden behind the house.',
      ),
      dialogues('Noocyada guryaha', 'garden'),
    ),
    Seed(
      'Rooms in a Home',
      'Qolalka guriga',
      'Bar qolalka iyo hawsha qol kasta.',
      [
        w('Living room', 'qolka fadhiga', plural: 'living rooms'),
        w('Bedroom', 'qolka jiifka', plural: 'bedrooms'),
        w('Kitchen', 'jikada', plural: 'kitchens'),
        w('Bathroom', 'musqusha', plural: 'bathrooms'),
        w('Dining room', 'qolka cuntada', plural: 'dining rooms'),
        w('Study room', 'qolka waxbarashada', plural: 'study rooms'),
        w('Guest room', 'qolka martida', plural: 'guest rooms'),
        w('Hall', 'hool', plural: 'halls'),
        w('Store room', 'qolka kaydka', plural: 'store rooms'),
        w('Garage', 'garaash', plural: 'garages'),
      ],
      examples(
        'We cook in the kitchen.',
        'We sleep in the bedroom.',
        'We sit in the living room.',
      ),
      dialogues('Qolalka guriga', 'guest room'),
    ),
    Seed(
      'Living Room Objects',
      'Alaabta qolka fadhiga',
      'Bar alaabta qolka fadhiga iyo goobtooda.',
      [
        w('Sofa', 'fadhiga dheer', plural: 'sofas'),
        w('Chair', 'kursi', plural: 'chairs'),
        w('Table', 'miis', plural: 'tables'),
        w('Television', 'telefishan', plural: 'televisions'),
        w('Remote control', 'kontorool fog', plural: 'remote controls'),
        w('Carpet', 'roog', plural: 'carpets'),
        w('Curtain', 'daah', plural: 'curtains'),
        w('Lamp', 'laambad', plural: 'lamps'),
        w('Fan', 'marawaxad', plural: 'fans'),
        w('Air conditioner', 'qaboojiye', plural: 'air conditioners'),
        w('Clock', 'saacad', plural: 'clocks'),
        w('Picture', 'sawir', plural: 'pictures'),
        w('Shelf', 'khaanad furan', plural: 'shelves'),
        w('Cushion', 'barkin fadhi', plural: 'cushions'),
        w('Furniture', 'alaabta guriga', type: 'uncountable noun'),
      ],
      examples(
        'The television is on the table.',
        'The sofa is next to the window.',
        'The carpet is under the table.',
      ),
      dialogues('Qolka fadhiga', 'remote control'),
    ),
    Seed(
      'Bedroom Objects',
      'Alaabta qolka jiifka',
      'Bar alaabta qolka jiifka iyo singular/plural.',
      [
        w('Bed', 'sariir', plural: 'beds'),
        w('Pillow', 'barkin', plural: 'pillows'),
        w('Blanket', 'buste', plural: 'blankets'),
        w('Sheet', 'go’ sariireed', plural: 'sheets'),
        w('Wardrobe', 'armaajo dhar', plural: 'wardrobes'),
        w('Mirror', 'muraayad', plural: 'mirrors'),
        w('Drawer', 'khaanad', plural: 'drawers'),
        w('Clothes', 'dhar', type: 'plural noun'),
        w('Alarm clock', 'saacad digniin', plural: 'alarm clocks'),
        w('Mattress', 'furaash', plural: 'mattresses'),
        w('Bedroom lamp', 'laambad qolka jiifka', plural: 'bedroom lamps'),
        w('Bag', 'boorso', plural: 'bags'),
        w('Shoes', 'kabo', type: 'plural noun'),
      ],
      examples(
        'The pillow is on the bed.',
        'My clothes are in the wardrobe.',
        'The shoes are under the bed.',
      ),
      dialogues('Qolka jiifka', 'alarm clock'),
    ),
    Seed(
      'Kitchen Objects',
      'Alaabta jikada',
      'Bar alaabta jikada adigoon gelin tilmaamo khatar ah.',
      [
        w('Cooker', 'makiinadda wax lagu karsado', plural: 'cookers'),
        w('Stove', 'shoolad', plural: 'stoves'),
        w('Fridge', 'qaboojiye', plural: 'fridges'),
        w('Refrigerator', 'qaboojiye', plural: 'refrigerators'),
        w('Oven', 'foorno', plural: 'ovens'),
        w('Sink', 'meesha weelka lagu dhaqo', plural: 'sinks'),
        w('Cup', 'koob', plural: 'cups'),
        w('Glass', 'galaas', plural: 'glasses'),
        w('Plate', 'saxan', plural: 'plates'),
        w('Bowl', 'baaquli', plural: 'bowls'),
        w('Spoon', 'qaaddo', plural: 'spoons'),
        w('Fork', 'fargeeto', plural: 'forks'),
        w('Knife', 'mindi', plural: 'knives'),
        w('Pot', 'dheri', plural: 'pots'),
        w('Pan', 'digsi', plural: 'pans'),
        w('Kettle', 'kildhi', plural: 'kettles'),
        w('Bottle', 'dhalo', plural: 'bottles'),
        w('Container', 'weel', plural: 'containers'),
        w('Cupboard', 'armaajo jikada', plural: 'cupboards'),
      ],
      examples(
        'The plates are in the cupboard.',
        'The pot is on the stove.',
        'The fridge is near the door.',
      ),
      dialogues('Jikada', 'cup'),
    ),
    Seed(
      'Bathroom and Cleaning Objects',
      'Alaabta musqusha iyo nadaafadda',
      'Bar alaabta musqusha iyo nadaafadda.',
      [
        w('Soap', 'saabuun'),
        w('Towel', 'tuwaal', plural: 'towels'),
        w('Toothbrush', 'burush ilko', plural: 'toothbrushes'),
        w('Toothpaste', 'daawada ilkaha'),
        w('Shower', 'qubays', plural: 'showers'),
        w('Tap', 'qasabad', plural: 'taps'),
        w('Water', 'biyo', type: 'uncountable noun'),
        w('Bucket', 'baaldi', plural: 'buckets'),
        w('Brush', 'burush', plural: 'brushes'),
        w('Broom', 'xaaqin', plural: 'brooms'),
        w('Mop', 'masaxad', plural: 'mops'),
        w('Bin', 'haan qashin', plural: 'bins'),
        w('Washing machine', 'makiinadda dharka', plural: 'washing machines'),
      ],
      examples(
        'The towel is next to the shower.',
        'The soap is near the tap.',
        'The broom is behind the door.',
      ),
      dialogues('Musqusha iyo nadaafadda', 'towel'),
    ),
    Seed(
      'There Is and There Are',
      'Isticmaalka There Is iyo There Are',
      'Samee positive, negative, questions iyo short answers.',
      [
        w('There is', 'waxaa jira hal shay', type: 'grammar phrase'),
        w('There are', 'waxaa jira waxyaabo badan', type: 'grammar phrase'),
        w('There isn’t', 'ma jiro hal shay', type: 'negative phrase'),
        w('There aren’t', 'ma jiraan waxyaabo badan', type: 'negative phrase'),
        w('Is there', 'ma jiraa/jirtaa', type: 'question phrase'),
        w('Are there', 'ma jiraan', type: 'question phrase'),
      ],
      examples(
        'There is a chair in the room.',
        'There are four chairs.',
        'Are there any windows?',
      ),
      dialogues('There is iyo there are', 'television'),
      grammar: thereGrammar,
    ),
    Seed(
      'Prepositions of Place — In, On and Under',
      'Goobta shayga — In, On iyo Under',
      'Kala saar gudaha, dusha iyo hoosta.',
      [
        w('In', 'gudaha', type: 'preposition'),
        w('On', 'dusha', type: 'preposition'),
        w('Under', 'hoosta', type: 'preposition'),
        w('Inside', 'gudaha', type: 'preposition'),
        w('Surface', 'oog/dusha', plural: 'surfaces'),
        w('Below', 'ka hooseeya', type: 'preposition'),
      ],
      examples(
        'The clothes are in the wardrobe.',
        'The book is on the table.',
        'The shoes are under the bed.',
      ),
      dialogues('In, on iyo under', 'book'),
      grammar: placeGrammar,
    ),
    Seed(
      'More Prepositions of Place',
      'Erayo dheeraad ah oo goobta tilmaama',
      'Bar next to, near, between, behind iyo goobaha kale.',
      [
        w('Next to', 'ku xiga', type: 'preposition'),
        w('Near', 'u dhow', type: 'preposition'),
        w('Between', 'u dhexeeya', type: 'preposition'),
        w('Behind', 'ka dambeeya', type: 'preposition'),
        w('In front of', 'hortiisa', type: 'preposition'),
        w('Above', 'ka sarreeya', type: 'preposition'),
        w('Below', 'ka hooseeya', type: 'preposition'),
        w('Opposite', 'ka soo horjeeda', type: 'preposition'),
        w('Inside', 'gudaha', type: 'preposition'),
        w('Outside', 'bannaanka', type: 'preposition'),
      ],
      examples(
        'The lamp is next to the bed.',
        'The table is between the chairs.',
        'The broom is behind the door.',
      ),
      dialogues('Goobaha dheeraadka ah', 'lamp'),
      grammar: morePlace,
    ),
    Seed(
      'Asking Where Things Are',
      'Weydiinta meesha alaabtu taal',
      'Weydii oo ka jawaab meesha singular iyo plural objects yaallaan.',
      [
        w('Where is', 'aaway hal shay', type: 'question phrase'),
        w('Where are', 'aaway waxyaabo badan', type: 'question phrase'),
        w('It is', 'wuxuu/waxay ku yaal', type: 'answer phrase'),
        w('They are', 'waxay ku yaallaan', type: 'answer phrase'),
        w('Keys', 'furayaal', type: 'plural noun'),
        w('Find', 'helid', type: 'verb'),
      ],
      examples(
        'Where is the book?',
        'Where are the keys?',
        'They are next to the door.',
      ),
      dialogues('Alaab raadinta', 'phone'),
      grammar: whereGrammar,
    ),
    Seed(
      'This, That, These and Those for Objects',
      'Tilmaamidda alaabta',
      'Ku tilmaam alaabta dhow ama fog, singular ama plural.',
      [
        w('This', 'kan/tan dhow', type: 'demonstrative'),
        w('That', 'kaas/taas fog', type: 'demonstrative'),
        w('These', 'kuwan dhow', type: 'demonstrative'),
        w('Those', 'kuwaas fog', type: 'demonstrative'),
        w('Object', 'shay', plural: 'objects'),
        w('Close', 'dhow', type: 'adjective'),
        w('Far', 'fog', type: 'adjective'),
      ],
      examples('This is a chair.', 'That is a window.', 'These are books.'),
      dialogues('Tilmaamidda alaabta', 'chair'),
      grammar: demonstrativeGrammar,
    ),
    Seed(
      'Describing a Room',
      'Sharaxaadda qol',
      'Isku dar furniture, there is/are, prepositions iyo adjectives.',
      [
        w('Small room', 'qol yar', type: 'noun phrase'),
        w('Large room', 'qol weyn', type: 'noun phrase'),
        w('Bright', 'iftiin leh', type: 'adjective'),
        w('Clean', 'nadiif', type: 'adjective'),
        w('Comfortable', 'raaxo leh', type: 'adjective'),
        w('Corner', 'gees', plural: 'corners'),
        w('Furniture', 'alaabta guriga', type: 'uncountable noun'),
      ],
      examples(
        'This is a small bedroom.',
        'There is a bed near the window.',
        'There are two pictures on the wall.',
      ),
      dialogues('Sharaxaadda qol', 'bed'),
    ),
    Seed(
      'Describing a Home',
      'Sharaxaadda guri',
      'Sharax tirada qolalka, goobtooda, alaabta iyo bannaanka.',
      [
        w('Number of rooms', 'tirada qolalka', type: 'phrase'),
        w('Outside area', 'aagga bannaanka', type: 'phrase'),
        w('Entrance', 'iridda laga galo', plural: 'entrances'),
        w('Back of the house', 'guriga gadaashiisa', type: 'place phrase'),
        w('Together', 'wadajir', type: 'adverb'),
        w('Family home', 'guriga qoyska', type: 'noun phrase'),
      ],
      examples(
        'There are three bedrooms.',
        'The kitchen is next to the dining room.',
        'There is a garden behind the house.',
      ),
      dialogues('Sharaxaadda guri', 'garden'),
    ),
    Seed(
      'Household Dialogues',
      'Wada sheekeysiyada guriga',
      'Ku tababar alaab raadis, guri weydiin iyo marti soo dhoweyn.',
      [
        w('Please sit', 'fadlan fadhiiso', type: 'polite phrase'),
        w('Would you like', 'ma jeclaan lahayd', type: 'offer'),
        w('How many bedrooms', 'immisa qol jiif', type: 'question phrase'),
        w('Guest', 'marti', plural: 'guests'),
        w('Host', 'martigeliye', plural: 'hosts'),
        w('Welcome', 'soo dhowow', type: 'polite word'),
      ],
      examples(
        'Where is my phone?',
        'How many bedrooms are there?',
        'Would you like some water?',
      ),
      [
        base.dialogue('Alaab raadis', [
          ('A', 'Where is my phone?', 'Aaway telefoonkaygu?'),
          ('B', 'It is on the table.', 'Miiska ayuu saaran yahay.'),
          ('A', 'Is it next to the book?', 'Buugga ma ku xigaa?'),
          ('B', 'Yes, it is.', 'Haa, wuu ku xigaa.'),
        ]),
        base.dialogue('Marti guriga timid', [
          (
            'Host',
            'Please sit in the living room.',
            'Fadlan fadhiiso qolka fadhiga.',
          ),
          ('Guest', 'Thank you.', 'Mahadsanid.'),
          ('Host', 'Would you like some water?', 'Ma jeclaan lahayd biyo?'),
          ('Guest', 'Yes, please.', 'Haa, fadlan.'),
        ]),
      ],
    ),
    Seed(
      'Unit Review',
      'Dib-u-eegista Unit 8',
      'Dib u eeg guriga, qolalka, alaabta, there is/are, goobaha iyo descriptions.',
      [
        w('Home', 'hoy/guri'),
        w('Room', 'qol', plural: 'rooms'),
        w('Furniture', 'alaabta guriga', type: 'uncountable noun'),
        w('There is', 'waxaa jira hal shay', type: 'grammar phrase'),
        w('There are', 'waxaa jira waxyaabo badan', type: 'grammar phrase'),
        w('Under', 'hoosta', type: 'preposition'),
        w('Between', 'u dhexeeya', type: 'preposition'),
        w('Where', 'xaggee/aaway', type: 'question word'),
        w('These', 'kuwan dhow', type: 'demonstrative'),
        w('Those', 'kuwaas fog', type: 'demonstrative'),
      ],
      examples(
        'There is a table in the room.',
        'There are books on the shelf.',
        'Where are the keys?',
      ),
      dialogues('Dib-u-eegista Unit 8', 'keys'),
      review: true,
    ),
  ];
  final unit = {
    'id': 'a1-u08',
    'levelId': 'A1',
    'unitNumber': 8,
    'titleEnglish': 'Home and Objects',
    'titleSomali': 'Guriga iyo Alaabta',
    'introductionSomali':
        'Unit-kan waxaad ku baranaysaa noocyada guryaha, qolalka, alaabta, there is/there are, prepositions of place, where questions iyo sharaxaadda qol ama guri tusaale ah.',
    'requiredPreviousUnitId': 'a1-u07',
    'lessons': [for (var i = 0; i < seeds.length; i++) lesson(i + 1, seeds[i])],
    'unitQuiz': unitQuiz(),
    'passingScore': 70,
  };
  File(
    'assets/content/a1/unit_08.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(unit)}\n');
}

List<Json> unitQuiz() {
  final q = <Json>[];
  void add(
    String type,
    String text,
    List<String> options,
    String answer,
    String why,
  ) => q.add(
    base.exercise(
      'a1-u08-q${(q.length + 1).toString().padLeft(2, '0')}',
      type,
      text,
      options,
      answer,
      why,
    ),
  );
  // 7 home and room vocabulary.
  add(
    'multipleChoice',
    'Kitchen waa…',
    ['jikada', 'qolka jiifka', 'musqusha', 'garaashka'],
    'jikada',
    'Kitchen waa jikada.',
  );
  add(
    'multipleChoice',
    'Bedroom waa…',
    ['qolka jiifka', 'qolka fadhiga', 'qolka cuntada', 'barxadda'],
    'qolka jiifka',
    'Bedroom waa qolka jiifka.',
  );
  add(
    'multipleChoice',
    'Kee waa qayb dhisme?',
    ['Roof', 'Pillow', 'Spoon', 'Soap'],
    'Roof',
    'Roof waa saqafka dhismaha.',
  );
  add(
    'multipleChoice',
    'We cook in the…',
    ['kitchen', 'bedroom', 'garage', 'garden'],
    'kitchen',
    'Waxaan wax ku karsannaa kitchen-ka.',
  );
  add(
    'multipleChoice',
    'We sleep in the…',
    ['bedroom', 'bathroom', 'hall', 'yard'],
    'bedroom',
    'Waxaan ku seexannaa bedroom-ka.',
  );
  add(
    'multipleChoice',
    'Window maxay tahay?',
    ['daaqad', 'albaab', 'derbi', 'saqaf'],
    'daaqad',
    'Window waa daaqad.',
  );
  add(
    'multipleChoice',
    'Home iyo house farqigooda saxda ah?',
    [
      'House waa dhisme; home waa meesha qofku hoy u arko.',
      'Labadu waa cunto.',
      'Home waa daaqad.',
      'House waa kursi.',
    ],
    'House waa dhisme; home waa meesha qofku hoy u arko.',
    'House dhismaha ayuu tilmaamaa, home-na hoyga.',
  );
  // 6 household objects.
  add(
    'multipleChoice',
    'Kee qolka fadhiga ku habboon?',
    ['Sofa', 'Toothbrush', 'Kettle', 'Mattress'],
    'Sofa',
    'Sofa badanaa qolka fadhiga ayuu yaal.',
  );
  add(
    'multipleChoice',
    'Kee qolka jiifka ku habboon?',
    ['Pillow', 'Fork', 'Broom', 'Oven'],
    'Pillow',
    'Pillow sariirta ayuu la xiriiraa.',
  );
  add(
    'multipleChoice',
    'Kee jikada ku habboon?',
    ['Plate', 'Blanket', 'Curtain', 'Alarm clock'],
    'Plate',
    'Plate waa saxan jikada laga isticmaalo.',
  );
  add(
    'multipleChoice',
    'Kee nadaafadda lagu isticmaalaa?',
    ['Broom', 'Sofa', 'Television', 'Wardrobe'],
    'Broom',
    'Broom waa xaaqin.',
  );
  add(
    'multipleChoice',
    'Furniture plural sax ah waa…',
    ['furniture', 'furnitures', 'furniturees', 'furniturs'],
    'furniture',
    'Furniture waa uncountable category noun.',
  );
  add(
    'multipleChoice',
    'Plural-ka shelf waa…',
    ['shelves', 'shelfs', 'shelfes', 'shelvies'],
    'shelves',
    'Shelf → shelves.',
  );
  // 6 there is/are.
  add(
    'fillInTheBlank',
    '___ a bed in the room.',
    ['There is', 'There are', 'Are there', 'They are'],
    'There is',
    'A bed waa singular.',
  );
  add(
    'fillInTheBlank',
    '___ two windows.',
    ['There are', 'There is', 'Is there', 'It is'],
    'There are',
    'Two windows waa plural.',
  );
  add(
    'fillInTheBlank',
    'There ___ not any chairs.',
    ['are', 'is', 'am', 'be'],
    'are',
    'Chairs waa plural: there are not.',
  );
  add(
    'multipleChoice',
    'Su’aasha singular-ka saxda ah?',
    [
      'Is there a bathroom?',
      'Are there a bathroom?',
      'There is bathroom?',
      'Is a bathroom there are?',
    ],
    'Is there a bathroom?',
    'Is there + singular noun.',
  );
  add(
    'multipleChoice',
    'Su’aasha plural-ka saxda ah?',
    [
      'Are there any plates?',
      'Is there any plates?',
      'Are there a plate?',
      'There plates are?',
    ],
    'Are there any plates?',
    'Are there + plural noun.',
  );
  add(
    'multipleChoice',
    'Are there windows? Jawaab negative?',
    ['No, there aren’t.', 'No, there isn’t.', 'No, it isn’t.', 'No, they is.'],
    'No, there aren’t.',
    'Are there waxaa looga jawaabaa there aren’t.',
  );
  // 6 prepositions.
  add(
    'fillInTheBlank',
    'The book is ___ the table.',
    ['on', 'in', 'under', 'behind'],
    'on',
    'Dusha miiska = on.',
  );
  add(
    'fillInTheBlank',
    'The shoes are ___ the bed.',
    ['under', 'above', 'on', 'opposite'],
    'under',
    'Hoosta sariirta = under.',
  );
  add(
    'fillInTheBlank',
    'The clothes are ___ the wardrobe.',
    ['in', 'on', 'above', 'between'],
    'in',
    'Gudaha armaajada = in.',
  );
  add(
    'fillInTheBlank',
    'The lamp is ___ the bed.',
    ['next to', 'inside', 'below', 'opposite'],
    'next to',
    'Dhinaca sariirta = next to.',
  );
  add(
    'fillInTheBlank',
    'The table is ___ the two chairs.',
    ['between', 'behind', 'under', 'outside'],
    'between',
    'Laba shay dhexdooda = between.',
  );
  add(
    'fillInTheBlank',
    'The broom is ___ the door.',
    ['behind', 'above', 'opposite', 'between'],
    'behind',
    'Albaabka gadaashiisa = behind.',
  );
  // 4 where questions.
  add(
    'chooseGrammar',
    '___ the book?',
    ['Where is', 'Where are', 'Are there', 'They are'],
    'Where is',
    'Book waa singular.',
  );
  add(
    'chooseGrammar',
    '___ the keys?',
    ['Where are', 'Where is', 'Is there', 'It is'],
    'Where are',
    'Keys waa plural.',
  );
  add(
    'multipleChoice',
    'Where is the phone? Jawaab sax ah?',
    [
      'It is on the table.',
      'They are on table.',
      'There are phone.',
      'It on is table.',
    ],
    'It is on the table.',
    'Phone singular waxaa lagu beddelaa it.',
  );
  add(
    'multipleChoice',
    'Where are the shoes? Jawaab sax ah?',
    [
      'They are under the bed.',
      'It is under bed.',
      'There is shoes.',
      'They under is bed.',
    ],
    'They are under the bed.',
    'Shoes plural waxaa lagu beddelaa they.',
  );
  // 3 demonstratives.
  add(
    'fillInTheBlank',
    '___ is a chair near me.',
    ['This', 'These', 'Those', 'They'],
    'This',
    'Hal shay oo dhow = this.',
  );
  add(
    'fillInTheBlank',
    '___ are books near me.',
    ['These', 'This', 'That', 'It'],
    'These',
    'Waxyaabo badan oo dhow = these.',
  );
  add(
    'fillInTheBlank',
    '___ are plates far from me.',
    ['Those', 'That', 'This', 'It'],
    'Those',
    'Waxyaabo badan oo fog = those.',
  );
  // 3 reading comprehension.
  const room =
      'Room: There is a bed near the window. Two books are on the table. The shoes are under the bed.';
  add(
    'readingComprehension',
    '$room Aaway sariirtu?',
    ['Near the window', 'Under the table', 'Behind the door', 'Outside'],
    'Near the window',
    'Qoraalku wuxuu sheegay near the window.',
  );
  add(
    'readingComprehension',
    '$room Immisa buug ayaa jira?',
    ['Two', 'One', 'Three', 'Four'],
    'Two',
    'Qoraalku wuxuu sheegay two books.',
  );
  add(
    'readingComprehension',
    '$room Aaway kabuhu?',
    ['Under the bed', 'On the table', 'Near the window', 'In the wardrobe'],
    'Under the bed',
    'Qoraalku wuxuu sheegay under the bed.',
  );
  return q;
}
