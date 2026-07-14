import 'dart:convert';
import 'dart:io';

import 'generate_a1_unit7.dart' as base;

typedef Json = Map<String, Object?>;
typedef Word = ({String en, String so, String type, String purpose});

Word w(String en, String so, {String type = 'noun', String purpose = ''}) =>
    (en: en, so: so, type: type, purpose: purpose);

Json vocab(Word item, String title) => {
  'englishWord': item.en,
  'somaliMeaning': item.so,
  'partOfSpeech': item.type,
  'pronunciation': _pronunciation(item.en),
  'exampleEnglish': title.contains('Transport')
      ? 'I travel by ${item.en.toLowerCase()}.'
      : 'The ${item.en.toLowerCase()} is near here.',
  'exampleSomali':
      '${item.so} waxay ku taal meel u dhow scenario-ga tusaalaha ah.',
  'explanationSomali': item.purpose.isEmpty
      ? '${item.en} waxaa loola jeedaa ${item.so}.'
      : '${item.en}: ${item.purpose}',
  'commonMistakeSomali': item.en == 'On foot'
      ? 'Ha oran by foot; on foot ayaa sax ah.'
      : item.en == 'Can'
      ? 'Can kadib isticmaal base verb; ha ku darin s.'
      : '',
};

String _pronunciation(String value) {
  const map = {
    'hospital': 'hos-pi-tal',
    'pharmacy': 'faar-ma-si',
    'library': 'lay-bre-ri',
    'restaurant': 'res-ta-rant',
    'university': 'yuu-ni-var-si-ti',
    'airport': 'eer-poort',
    'straight': 'streyt',
    'through': 'thruu',
    'opposite': 'o-pa-zit',
    'between': 'bi-twiin',
    'roundabout': 'rawn-da-bawt',
    'intersection': 'in-tar-sek-shan',
    'traffic lights': 'tra-fik layts',
    'junction': 'jangk-shan',
    'directions': 'di-rek-shanz',
    'passenger': 'pa-san-jar',
    'bicycle': 'bay-si-kal',
  };
  return map[value.toLowerCase()] ?? value.toLowerCase().replaceAll('-', ' ');
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

List<(String, String)> examples(String a, String b, String c) => [
  (a, 'Tusaalaha koowaad ee jidka.'),
  (b, 'Tusaalaha labaad ee jidka.'),
  (c, 'Tusaalaha saddexaad ee jidka.'),
  ('Excuse me, where is the bank?', 'Iga raalli ahow, bangigu xaggee ku yaal?'),
  ('Go straight and turn left.', 'Toos u soco kadib bidix u leexo.'),
  (
    'It is about five minutes from here.',
    'Waxay halkan u jirtaa qiyaastii shan daqiiqo.',
  ),
];

List<Json> dialogues(String topic, String place) => [
  base.dialogue('$topic: meel raadis', [
    (
      'A',
      'Excuse me, where is the $place?',
      'Iga raalli ahow, xaggee ku yaal $place?',
    ),
    ('B', 'Go straight and turn left.', 'Toos u soco kadib bidix u leexo.'),
    ('A', 'Is it far?', 'Ma fog tahay?'),
    ('B', 'No, it is near here.', 'Maya, halkan ayay u dhowdahay.'),
  ]),
  base.dialogue('$topic: caawimo', [
    (
      'A',
      'Can you show me the way to the $place?',
      'Ma i tusi kartaa jidka $place?',
    ),
    ('B', 'Yes. Walk past the bank.', 'Haa. Bangiga dhaaf adigoo socda.'),
    ('A', 'Is it on my right?', 'Ma midigtayda ayay ku taallaa?'),
    ('B', 'Yes, it is.', 'Haa, way ku taallaa.'),
  ]),
];

Json topic(
  String id,
  String title,
  String somali,
  String rule,
  String structure,
  List<(String, String)> positive, {
  List<(String, String)> negative = const [],
  List<(String, String)> questions = const [],
  List<String> mistakes = const [],
}) => base.grammar(
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

List<Json> practice(int number, Seed seed) {
  final id = 'a1-u09-l${number.toString().padLeft(2, '0')}';
  final a = seed.words[0];
  final b = seed.words.length > 1 ? seed.words[1] : a;
  final c = seed.words.length > 2 ? seed.words[2] : b;
  final result = <Json>[
    base.exercise(
      '$id-p01',
      'multipleChoice',
      '“${a.en}” maxay ka dhigan tahay?',
      [a.so, b.so, c.so, 'qol jiif'],
      a.so,
      '${a.en} waa ${a.so}.',
    ),
    base.exercise(
      '$id-p02',
      'englishToSomali',
      'U turjun: ${b.en}',
      [b.so, a.so, c.so, 'cunto'],
      b.so,
      '${b.en} waa ${b.so}.',
    ),
    base.exercise(
      '$id-p03',
      'somaliToEnglish',
      'English ku dooro: ${c.so}',
      [c.en, a.en, b.en, 'Bedroom'],
      c.en,
      '${c.so} waa ${c.en}.',
    ),
    base.exercise(
      '$id-p04',
      'chooseGrammar',
      'Dooro tilmaanta saxda ah: ___ straight for two minutes.',
      ['Go', 'Goes', 'Going', 'Went'],
      'Go',
      'Imperative-ku wuxuu ku bilaabmaa base verb Go.',
    ),
    base.exercise(
      '$id-p05',
      'fillInTheBlank',
      'Turn ___ at the bank.',
      ['left', 'opposite', 'near', 'between'],
      'left',
      'Turn left = bidix u leexo.',
    ),
    base.exercise(
      '$id-p06',
      'chooseGrammar',
      'The pharmacy is ___ the clinic.',
      ['next to', 'turn', 'walk', 'straight'],
      'next to',
      'Next to waa preposition goob.',
    ),
    base.exercise(
      '$id-p07',
      'chooseGrammar',
      '___ you show me the way?',
      ['Can', 'Does', 'Are', 'Is'],
      'Can',
      'Can you + base verb waa codsi caawimo.',
    ),
    base.exercise(
      '$id-p08',
      'arrangeSentence',
      'Habee: bank / at / right / turn / the',
      [
        'Turn right at the bank.',
        'Right the bank turn at.',
        'At turn bank the right.',
        'The right at bank turn.',
      ],
      'Turn right at the bank.',
      'Amarku wuxuu ku bilaabmaa Turn.',
    ),
    base.exercise(
      '$id-p09',
      'trueFalse',
      '“Can he walks there?” waa sax.',
      ['True', 'False'],
      'False',
      'Can kadib base verb: Can he walk there?',
    ),
    base.exercise(
      '$id-p10',
      'readingComprehension',
      'Map: Bank is opposite Market. Pharmacy is next to Bank. Maxaa bangiga ka soo horjeeda?',
      ['Market', 'Pharmacy', 'School', 'Park'],
      'Market',
      'Textual map-ku wuxuu sheegay Bank opposite Market.',
    ),
    base.exercise(
      '$id-p11',
      'readingComprehension',
      'Route: Go straight. Turn right at the school. The clinic is on your left. Xaggee lagu leexanayaa?',
      [
        'Right at the school',
        'Left at the bank',
        'Back at the clinic',
        'Straight at the market',
      ],
      'Right at the school',
      'Route-ku wuxuu sheegay turn right at the school.',
    ),
    base.exercise(
      '$id-p12',
      'multipleChoice',
      'Jawaabta edebta leh ee “Thank you” dooro.',
      ['You’re welcome.', 'Go road.', 'No direction.', 'I station.'],
      'You’re welcome.',
      'You’re welcome waa jawaab edeb leh.',
    ),
    base.exercise(
      '$id-p13',
      'speakingPrompt',
      'Ku hadal: sii qof saddex tallaabo oo jid tilmaam ah.',
      [],
      'Hawl hadal furan',
      'Isticmaal go, turn iyo meel tusaale ah.',
    ),
    base.exercise(
      '$id-p14',
      'shortWriting',
      'Qor laba jumladood oo ku saabsan ${seed.somali}.',
      [],
      'Hawl qoraal furan',
      'Ha isticmaalin cinwaan ama xog qof dhab ah.',
    ),
  ];
  if (seed.review) {
    for (var i = 15; i <= 30; i++) {
      final right = i.isEven;
      result.add(
        base.exercise(
          '$id-p${i.toString().padLeft(2, '0')}',
          'chooseGrammar',
          right
              ? 'Turn ___ after the hospital.'
              : 'The bank is ___ the market.',
          right
              ? ['right', 'near', 'between', 'past']
              : ['opposite', 'turn', 'walk', 'straight'],
          right ? 'right' : 'opposite',
          right
              ? 'Turn right waa amar leexasho.'
              : 'Opposite waa meel ka soo horjeedda.',
        ),
      );
    }
  }
  return result;
}

Json lesson(int number, Seed seed) {
  final id = 'a1-u09-l${number.toString().padLeft(2, '0')}';
  final exercises = practice(number, seed);
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-u09',
    'lessonNumber': number,
    'titleEnglish': seed.title,
    'titleSomali': seed.somali,
    'shortDescriptionSomali': seed.description,
    'learningObjectives': [
      'Bar erayada muhiimka ah ee ${seed.somali}.',
      'Faham oo bixi tilmaamo jid oo A1 ah.',
      'Ku tababar hadal, qoraal iyo textual map.',
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
        : 'a1-u09-l${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': [for (final item in seed.words) vocab(item, seed.title)],
    'grammar': seed.grammar,
    'examples': [
      for (final item in seed.examples) base.example(item.$1, item.$2),
    ],
    'dialogues': seed.dialogues,
    'practiceExercises': exercises,
    'speakingPractice':
        'Samee role-play qof jid weydiinaya iyo qof tilmaamo bixinaya.',
    'writingPractice':
        'Qor 6 ilaa 10 jumladood oo ku saabsan ${seed.somali}, adigoo isticmaalaya goob tusaale ah.',
    'summarySomali':
        'Waxaad baratay ${seed.somali}, erayada jidka iyo tilmaamo kooban oo dabiici ah.',
    'quizQuestions': [
      for (var i = 0; i < 3; i++)
        {...exercises[i], 'id': '$id-q${(i + 1).toString().padLeft(2, '0')}'},
    ],
  };
}

void main() {
  final whereGrammar = topic(
    'a1-u09-where',
    'Asking Where a Place Is',
    'Weydiinta halka goob ku taallo',
    'Where is waxaa lagu weydiiyaa hal goob. Excuse me ku billow marka qof aanad aqoon su’aal weydiinayso.',
    'Excuse me + where is + place?',
    [
      ('It is near the mosque.', 'Masaajidka ayay u dhowdahay.'),
      ('It is next to the bank.', 'Bangiga ayay ku xigtaa.'),
      ('It is opposite the market.', 'Suuqa ayay ka soo horjeeddaa.'),
      ('It is on this street.', 'Waddadan ayay ku taallaa.'),
      ('It is not far from here.', 'Halkan kama foga.'),
      ('It is five minutes from here.', 'Halkan waxay u jirtaa shan daqiiqo.'),
    ],
    questions: [
      ('Where is the hospital?', 'Isbitaalku xaggee ku yaal?'),
      ('Is there a pharmacy near here?', 'Farmashiye ma u dhow yahay halkan?'),
    ],
    mistakes: ['Su’aasha qof aan la aqoon ku billow Excuse me si edeb leh.'],
  );
  final imperativeGrammar = topic(
    'a1-u09-imperative',
    'Direction Imperatives',
    'Amarada tilmaamaha jidka',
    'Jumladda amarku base verb ayay ku bilaabataa; subject you lama qoro laakiin waa la fahmayaa.',
    'Base verb + direction/place',
    [
      ('Go straight.', 'Toos u soco.'),
      ('Turn left.', 'Bidix u leexo.'),
      ('Walk past the bank.', 'Bangiga dhaaf adigoo socda.'),
      ('Cross the road.', 'Waddada ka gudub.'),
      ('Follow this street.', 'Waddadan raac.'),
      ('Take the second right.', 'Midigta labaad qaado.'),
    ],
    negative: [('Do not enter.', 'Ha gelin.')],
    questions: [('Should I turn left?', 'Ma bidix ayaan u leexdaa?')],
    mistakes: ['You turn left waa statement; Turn left waa instruction.'],
  );
  final placeGrammar = topic(
    'a1-u09-location',
    'Location Prepositions',
    'Erayada goobta lagu tilmaamo',
    'Next to, near, opposite, between, behind iyo in front of waxay sheegaan xiriirka laba goobood.',
    'Place + be + preposition + place',
    [
      (
        'The pharmacy is next to the clinic.',
        'Farmashiyuhu rugta ayuu ku xigaa.',
      ),
      (
        'The bank is opposite the market.',
        'Bangigu suuqa ayuu ka soo horjeedaa.',
      ),
      (
        'The restaurant is between the hotel and shop.',
        'Makhaayaddu hoteelka iyo dukaanka ayay u dhexaysaa.',
      ),
      (
        'The car park is behind the building.',
        'Baarkinku dhismaha ayuu ka dambeeyaa.',
      ),
      (
        'The station is in front of the park.',
        'Saldhiggu beerta ayuu ka horreeyaa.',
      ),
      ('The shop is on the corner.', 'Dukaanku geeska ayuu ku yaal.'),
    ],
    negative: [('The bank is not near here.', 'Bangigu halkan uma dhowa.')],
    questions: [
      (
        'Is the school opposite the park?',
        'Iskuulku beerta ma ka soo horjeedaa?',
      ),
    ],
    mistakes: [
      'Opposite iyo across from badanaa macne isu dhow ayay leeyihiin.',
    ],
  );
  final townGrammar = topic(
    'a1-u09-town-there',
    'There Is and There Are in a Town',
    'There is/are magaalada',
    'There is singular; there are plural. Some positive, any questions iyo negative.',
    'There is + singular; There are + plural',
    [
      ('There is a hospital in town.', 'Magaalada isbitaal baa ku yaal.'),
      ('There is a bank near the market.', 'Suuqa agtiisa bangi baa yaal.'),
      ('There are three schools.', 'Saddex iskuul baa jira.'),
      ('There are many shops.', 'Dukaamo badan baa jira.'),
      ('There are some restaurants.', 'Makhaayado ayaa jira.'),
      ('There is a bus station.', 'Saldhig bas baa jira.'),
    ],
    negative: [
      ('There isn’t an airport here.', 'Halkan garoon diyaaradeed ma jiro.'),
      ('There aren’t any hotels.', 'Hoteello ma jiraan.'),
    ],
    questions: [
      ('Is there a pharmacy?', 'Farmashiye ma jiraa?'),
      ('Are there any restaurants?', 'Makhaayado ma jiraan?'),
    ],
    mistakes: [
      'There is three schools waa khalad; there are three schools ayaa sax ah.',
    ],
  );
  final canGrammar = topic(
    'a1-u09-can',
    'Can for Asking for Help',
    'Can marka caawimo la weydiisanayo',
    'Can waxaa loo isticmaalaa codsi, awood ama oggolaansho. Waxaa ka dambeeya base verb.',
    'Can + subject + base verb?',
    [
      ('You can take a taxi.', 'Waxaad qaadan kartaa taksi.'),
      ('You can walk from here.', 'Halkan waad ka lugayn kartaa.'),
      ('I can show you the way.', 'Jidka waan ku tusi karaa.'),
      ('We can go this way.', 'Jidkan waan mari karnaa.'),
      ('She can take a bus.', 'Waxay raaci kartaa bas.'),
      ('He can walk there.', 'Halkaas wuu u lugayn karaa.'),
    ],
    negative: [
      ('You cannot enter here.', 'Halkan ma geli kartid.'),
      ('You can’t park here.', 'Halkan ma baarkin kartid.'),
    ],
    questions: [
      ('Can you help me?', 'Ma i caawin kartaa?'),
      ('Can I take a bus?', 'Bas ma raaci karaa?'),
    ],
    mistakes: ['Can he walks waa khalad; Can he walk ayaa sax ah.'],
  );

  final seeds = <Seed>[
    Seed(
      'Places in a Town or City',
      'Goobaha magaalada',
      'Bar goobaha muhiimka ah iyo shaqada goob kasta.',
      [
        w(
          'School',
          'iskuul',
          purpose: 'Ardaydu waxay wax ku bartaan iskuulka.',
        ),
        w(
          'University',
          'jaamacad',
          purpose: 'Waxbarasho sare ayaa lagu dhigtaa.',
        ),
        w(
          'Hospital',
          'isbitaal',
          purpose: 'Dhakhaatiir iyo adeeg caafimaad ayaa ka shaqeeya.',
        ),
        w(
          'Clinic',
          'rug caafimaad',
          purpose: 'Daryeel caafimaad ayaa laga helaa.',
        ),
        w('Pharmacy', 'farmashiye', purpose: 'Daawo ayaa laga iibsan karaa.'),
        w('Bank', 'bangi', purpose: 'Adeegyada lacagta ayaa laga helaa.'),
        w(
          'Market',
          'suuq',
          purpose: 'Alaab ayaa lagu iibiyaa laguna iibsadaa.',
        ),
        w('Shop', 'dukaan'),
        w('Supermarket', 'dukaan weyn'),
        w('Restaurant', 'makhaayad'),
        w('Hotel', 'hoteel'),
        w('Mosque', 'masaajid'),
        w('Police station', 'saldhig boolis'),
        w('Bus station', 'saldhig bas'),
        w('Airport', 'garoon diyaaradeed'),
        w('Office', 'xafiis'),
        w('Park', 'beer nasasho'),
        w('Library', 'maktabad'),
        w('Post office', 'xafiiska boostada'),
        w('Petrol station', 'kaalin shidaal'),
        w('Road', 'waddo'),
        w('Street', 'jid magaalada'),
      ],
      examples(
        'Students study at a school.',
        'You can buy medicine at a pharmacy.',
        'Planes arrive at the airport.',
      ),
      dialogues('Goobaha magaalada', 'hospital'),
    ),
    Seed(
      'Asking Where a Place Is',
      'Weydiinta halka goob ku taallo',
      'Weydii goob si edeb leh oo faham jawaabaha goobta.',
      [
        w('Where is', 'xaggee ku yaal', type: 'question phrase'),
        w('Nearest', 'ugu dhow', type: 'adjective'),
        w('Near here', 'halkan u dhow', type: 'place phrase'),
        w('Nearby', 'agagaarka', type: 'adverb'),
        w('How can I get to', 'sideen ku tagi karaa', type: 'question phrase'),
        w('Excuse me', 'iga raalli ahow', type: 'polite phrase'),
        w('Not far', 'aan fogayn', type: 'place phrase'),
        w(
          'Five minutes from here',
          'halkan shan daqiiqo u jirta',
          type: 'distance phrase',
        ),
      ],
      examples(
        'Where is the nearest bank?',
        'Is there a pharmacy near here?',
        'Can you tell me where the school is?',
      ),
      dialogues('Goob weydiinta', 'bank'),
      grammar: whereGrammar,
    ),
    Seed(
      'Left, Right and Straight',
      'Bidix, midig iyo toos',
      'Kala saar jihada iyo amarka leexashada.',
      [
        w('Left', 'bidix', type: 'direction'),
        w('Right', 'midig', type: 'direction'),
        w('Straight', 'toos', type: 'direction'),
        w('Straight ahead', 'toos hore', type: 'direction phrase'),
        w('Turn left', 'bidix u leexo', type: 'command'),
        w('Turn right', 'midig u leexo', type: 'command'),
        w('Go straight', 'toos u soco', type: 'command'),
        w('Stop', 'joogso', type: 'command'),
        w('Continue', 'sii wad', type: 'command'),
        w('Go back', 'dib u noqo', type: 'command'),
        w('On your left', 'bidixdaada', type: 'location phrase'),
        w('On your right', 'midigtaada', type: 'location phrase'),
      ],
      examples(
        'Turn left at the bank.',
        'Go straight for two minutes.',
        'The school is on your left.',
      ),
      dialogues('Bidix, midig iyo toos', 'school'),
    ),
    Seed(
      'Basic Direction Commands',
      'Amarada fudud ee tilmaamaha jidka',
      'Isticmaal imperative verbs si tilmaamaha jidku u caddaadaan.',
      [
        w('Go', 'soco', type: 'verb'),
        w('Turn', 'leexo', type: 'verb'),
        w('Walk', 'lugee', type: 'verb'),
        w('Continue', 'sii wad', type: 'verb'),
        w('Cross', 'ka gudub', type: 'verb'),
        w('Stop', 'joogso', type: 'verb'),
        w('Pass', 'dhaaf', type: 'verb'),
        w('Follow', 'raac', type: 'verb'),
        w('Take', 'qaado', type: 'verb'),
        w('Enter', 'gal', type: 'verb'),
        w('Leave', 'ka bax', type: 'verb'),
      ],
      examples(
        'Cross the road.',
        'Walk past the bank.',
        'Take the second right.',
      ),
      dialogues('Amarada jidka', 'market'),
      grammar: imperativeGrammar,
    ),
    Seed(
      'Location Prepositions for Places',
      'Erayada goobta lagu tilmaamo',
      'Ku dabaq prepositions-ka goobaha magaalada.',
      [
        w('Next to', 'ku xiga', type: 'preposition'),
        w('Near', 'u dhow', type: 'preposition'),
        w('Opposite', 'ka soo horjeeda', type: 'preposition'),
        w('Between', 'u dhexeeya', type: 'preposition'),
        w('Behind', 'ka dambeeya', type: 'preposition'),
        w('In front of', 'ka horreeya', type: 'preposition'),
        w('On the corner', 'geeska ku yaal', type: 'place phrase'),
        w('At the end of', 'dhammaadka', type: 'place phrase'),
        w('Across from', 'ka soo horjeeda', type: 'preposition'),
        w('Inside', 'gudaha', type: 'preposition'),
        w('Outside', 'bannaanka', type: 'preposition'),
      ],
      examples(
        'The pharmacy is next to the clinic.',
        'The bank is opposite the market.',
        'The school is at the end of the street.',
      ),
      dialogues('Goob-sheegayaasha', 'pharmacy'),
      grammar: placeGrammar,
    ),
    Seed(
      'Roads, Streets and Intersections',
      'Waddooyinka iyo isgoysyada',
      'Bar qaybaha waddada iyo tilmaamo ammaan ah oo scenario ah.',
      [
        w('Road', 'waddo'),
        w('Street', 'jid magaalada'),
        w('Main road', 'waddada weyn'),
        w('Side street', 'jid dhinac'),
        w('Corner', 'gees'),
        w('Junction', 'isgoys'),
        w('Intersection', 'isgoys weyn'),
        w('Traffic lights', 'nalalka taraafikada'),
        w('Roundabout', 'wareegga waddada'),
        w('Bridge', 'buundo'),
        w('Crossing', 'meel laga gudbo'),
        w('Pavement', 'jidka lugta'),
        w('Path', 'dariiq'),
        w('Sign', 'calaamad'),
      ],
      examples(
        'Turn left at the traffic lights.',
        'Go straight through the roundabout.',
        'Cross the road at the crossing.',
      ),
      dialogues('Waddooyinka', 'roundabout'),
    ),
    Seed(
      'There Is and There Are in a Town',
      'There Is iyo There Are marka magaalada laga hadlayo',
      'Ku isticmaal there is/are iyo some/any goobaha magaalada.',
      [
        w('There is', 'waxaa jira hal goob', type: 'grammar phrase'),
        w('There are', 'waxaa jira goobo badan', type: 'grammar phrase'),
        w('There isn’t', 'ma jiro', type: 'negative phrase'),
        w('There aren’t', 'ma jiraan', type: 'negative phrase'),
        w('Some', 'qaar', type: 'determiner'),
        w('Any', 'wax/qaarna', type: 'determiner'),
        w('Area', 'deegaan'),
      ],
      examples(
        'There is a hospital in the town.',
        'There are three schools.',
        'Are there any restaurants?',
      ),
      dialogues('There is/are magaalada', 'restaurant'),
      grammar: townGrammar,
    ),
    Seed(
      'Can for Asking for Help',
      'Isticmaalka Can marka caawimo la weydiisanayo',
      'Codso caawimo oo sii talo jid adigoo adeegsanaya can + base verb.',
      [
        w('Can', 'kara/ma kartaa', type: 'modal verb'),
        w('Cannot', 'ma karo', type: 'modal negative'),
        w('Can’t', 'ma karo', type: 'short negative'),
        w('Help', 'caawin', type: 'verb'),
        w('Show the way', 'jidka tusid', type: 'verb phrase'),
        w('Walk there', 'halkaas u lugayn', type: 'verb phrase'),
        w('Take a bus', 'bas raacid', type: 'verb phrase'),
        w('Park', 'baarkin dhigid', type: 'verb'),
      ],
      examples(
        'Can you help me?',
        'Can I take a bus?',
        'You can walk from here.',
      ),
      dialogues('Can iyo caawimo', 'bus station'),
      grammar: canGrammar,
    ),
    Seed(
      'Transport in the City',
      'Gaadiidka magaalada',
      'Bar gaadiidka iyo by/on foot.',
      [
        w('Bus', 'bas'),
        w('Minibus', 'bas yar'),
        w('Taxi', 'taksi'),
        w('Car', 'baabuur'),
        w('Motorcycle', 'mooto'),
        w('Bicycle', 'baaskiil'),
        w('Tuk-tuk', 'tuk-tuk'),
        w('Train', 'tareen'),
        w('Plane', 'diyaarad'),
        w('Walk', 'lugayn', type: 'verb'),
        w('Driver', 'darawal'),
        w('Passenger', 'rakaab'),
        w('Bus stop', 'joogsiga baska'),
        w('Ticket', 'tigidh'),
        w('Fare', 'lacagta safarka'),
        w('On foot', 'lug', type: 'transport phrase'),
      ],
      examples('I go by bus.', 'We take a taxi.', 'He walks to school.'),
      dialogues('Gaadiidka', 'bus stop'),
    ),
    Seed(
      'Giving Simple Directions',
      'Bixinta tilmaamo jid oo fudud',
      'Isku xir tallaabooyinka jidka first ilaa finally.',
      [
        w('First', 'marka hore', type: 'sequence word'),
        w('Then', 'kadib', type: 'sequence word'),
        w('Next', 'marka xigta', type: 'sequence word'),
        w('After that', 'intaas kadib', type: 'sequence phrase'),
        w('Finally', 'ugu dambayn', type: 'sequence word'),
        w('Along', 'dhererka/raac', type: 'preposition'),
        w('Past', 'dhaafaya', type: 'movement preposition'),
        w('Through', 'dhex mara', type: 'movement preposition'),
      ],
      examples(
        'First, go straight.',
        'Then, turn right.',
        'Finally, the shop is on your left.',
      ),
      dialogues('Bixinta tilmaamaha', 'hotel'),
    ),
    Seed(
      'Following a Simple Map',
      'Raacitaanka khariidad fudud',
      'Akhri textual grid map oo jawaabaha la waafajiyay.',
      [
        w('Textual map', 'khariidad qoraal ah', type: 'noun phrase'),
        w('Grid', 'shabag khariidad', type: 'noun'),
        w('Route', 'jid la raaco'),
        w('Start', 'bilow', type: 'verb'),
        w('Destination', 'meesha loo socdo'),
        w('North', 'waqooyi', type: 'direction'),
        w('South', 'koonfur', type: 'direction'),
        w('East', 'bari', type: 'direction'),
        w('West', 'galbeed', type: 'direction'),
      ],
      examples(
        'The pharmacy is next to the bank.',
        'The market is opposite the park.',
        'Turn right at the school.',
      ),
      dialogues('Textual map', 'pharmacy'),
    ),
    Seed(
      'Asking for and Giving Directions Dialogue',
      'Wada sheekeysiga tilmaamaha jidka',
      'Ku tababar hospital, station iyo pharmacy raadintooda.',
      [
        w('Is it far', 'ma fog tahay', type: 'question phrase'),
        w('Which way', 'jidkee', type: 'question phrase'),
        w('You’re welcome', 'adigaa mudan', type: 'polite phrase'),
        w('First street', 'jidka koowaad', type: 'route phrase'),
        w(
          'About five minutes',
          'qiyaastii shan daqiiqo',
          type: 'distance phrase',
        ),
        w('Tell me where', 'ii sheeg halka', type: 'request phrase'),
      ],
      examples(
        'Excuse me, where is the hospital?',
        'It is opposite the market.',
        'Take the first street on the right.',
      ),
      [
        base.dialogue('Hospital raadis', [
          (
            'A',
            'Excuse me, where is the hospital?',
            'Iga raalli ahow, isbitaalku xaggee ku yaal?',
          ),
          (
            'B',
            'Go straight and turn left at the bank.',
            'Toos u soco, bangigana bidix uga leexo.',
          ),
          ('A', 'Is it far?', 'Ma fog tahay?'),
          (
            'B',
            'No, it is five minutes from here.',
            'Maya, halkan shan daqiiqo ayay u jirtaa.',
          ),
        ]),
        base.dialogue('Pharmacy raadis', [
          (
            'A',
            'Is there a pharmacy near here?',
            'Farmashiye ma u dhow yahay halkan?',
          ),
          (
            'B',
            'Yes, it is next to the clinic.',
            'Haa, rugta caafimaadka ayuu ku xigaa.',
          ),
          ('A', 'Which way should I go?', 'Jidkee ayaan maraa?'),
          (
            'B',
            'Take the first street on the right.',
            'Jidka koowaad ee midig qaado.',
          ),
        ]),
      ],
    ),
    Seed(
      'Describing Your Area',
      'Sharaxaadda deegaanka',
      'Sharax deegaan tusaale ah adigoon bixin xogtaada dhabta ah.',
      [
        w('Busy area', 'deegaan mashquul badan', type: 'noun phrase'),
        w('Quiet area', 'deegaan deggan', type: 'noun phrase'),
        w('Near my home', 'gurigayga u dhow', type: 'place phrase'),
        w('In this area', 'deegaankan', type: 'place phrase'),
        w('Local market', 'suuqa deegaanka', type: 'noun phrase'),
        w('Public transport', 'gaadiidka dadweynaha', type: 'noun phrase'),
      ],
      examples(
        'There is a market near my home.',
        'There are two schools.',
        'The bus stop is next to the mosque.',
      ),
      dialogues('Sharaxaadda deegaan', 'market'),
    ),
    Seed(
      'Travel and Direction Problems',
      'Dhibaatooyinka fudud ee jidka',
      'Bar weedho deggan oo caawimo lagu codsado marka jidku qaldo.',
      [
        w('I am lost', 'jidka ayaan lumay', type: 'problem phrase'),
        w(
          'I don’t know this area',
          'deegaankan ma aqaan',
          type: 'problem phrase',
        ),
        w('Cannot find', 'ma heli karo', type: 'verb phrase'),
        w('Wrong road', 'waddo khaldan', type: 'noun phrase'),
        w('Right way', 'jidka saxda ah', type: 'noun phrase'),
        w('Where am I', 'xaggee ayaan joogaa', type: 'question phrase'),
        w('Show me on the map', 'khariidadda iga tus', type: 'request phrase'),
        w('Need a taxi', 'taksi ayaan u baahanahay', type: 'phrase'),
        w('Missed the bus', 'baskii ayaan seegay', type: 'phrase'),
        w('Information desk', 'miiska macluumaadka', type: 'noun phrase'),
      ],
      examples(
        'I cannot find the hotel.',
        'Is this the right way?',
        'Please show me on the map.',
      ),
      dialogues('Dhibaatooyinka jidka', 'hotel'),
    ),
    Seed(
      'Unit Review',
      'Dib-u-eegista Unit 9',
      'Dib u eeg goobaha, jihada, imperatives, can, gaadiidka iyo textual maps.',
      [
        w('Place', 'goob'),
        w('Direction', 'jiho'),
        w('Left', 'bidix', type: 'direction'),
        w('Right', 'midig', type: 'direction'),
        w('Straight', 'toos', type: 'direction'),
        w('Opposite', 'ka soo horjeeda', type: 'preposition'),
        w('Can', 'kara', type: 'modal verb'),
        w('Transport', 'gaadiid'),
        w('Route', 'jid la raaco'),
        w('Map', 'khariidad'),
      ],
      examples(
        'Go straight and turn left.',
        'Can you show me the way?',
        'The bank is opposite the market.',
      ),
      dialogues('Dib-u-eegista Unit 9', 'hospital'),
      review: true,
    ),
  ];
  final unit = {
    'id': 'a1-u09',
    'levelId': 'A1',
    'unitNumber': 9,
    'titleEnglish': 'Places and Directions',
    'titleSomali': 'Goobaha iyo Tilmaamaha Jidka',
    'introductionSomali':
        'Unit-kan waxaad ku baranaysaa goobaha magaalada, jid weydiinta, left/right/straight, imperatives, location prepositions, can, gaadiidka iyo textual maps.',
    'requiredPreviousUnitId': 'a1-u08',
    'lessons': [for (var i = 0; i < seeds.length; i++) lesson(i + 1, seeds[i])],
    'unitQuiz': unitQuiz(),
    'passingScore': 70,
  };
  File(
    'assets/content/a1/unit_09.json',
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
      'a1-u09-q${(q.length + 1).toString().padLeft(2, '0')}',
      type,
      text,
      options,
      answer,
      why,
    ),
  );
  // 7 places vocabulary.
  add(
    'multipleChoice',
    'Daawo xaggee laga iibsadaa?',
    ['Pharmacy', 'Library', 'Park', 'Hotel'],
    'Pharmacy',
    'Pharmacy waa farmashiye.',
  );
  add(
    'multipleChoice',
    'Planes arrive at the…',
    ['airport', 'market', 'bank', 'clinic'],
    'airport',
    'Diyaaraduhu airport ayay yimaadaan.',
  );
  add(
    'multipleChoice',
    'Books can be read at a…',
    ['library', 'petrol station', 'bus station', 'hotel'],
    'library',
    'Library waa maktabad.',
  );
  add(
    'multipleChoice',
    'Doctors work at a…',
    ['hospital', 'supermarket', 'post office', 'park'],
    'hospital',
    'Doctors waxay ka shaqeeyaan hospital.',
  );
  add(
    'multipleChoice',
    'Money services are at a…',
    ['bank', 'school', 'mosque', 'restaurant'],
    'bank',
    'Bank wuxuu bixiyaa adeegyo lacag.',
  );
  add(
    'multipleChoice',
    'Bus station macnihiisu waa…',
    ['saldhig bas', 'garoon diyaaradeed', 'rug caafimaad', 'dukaan'],
    'saldhig bas',
    'Bus station waa saldhig bas.',
  );
  add(
    'multipleChoice',
    'Petrol station waa…',
    ['kaalin shidaal', 'maktabad', 'xafiis boosto', 'beer'],
    'kaalin shidaal',
    'Petrol station waa kaalin shidaal.',
  );
  // 6 asking directions.
  add(
    'multipleChoice',
    'Habka edebta leh dooro.',
    [
      'Excuse me, where is the bank?',
      'Bank where?',
      'You bank now.',
      'Tell bank.',
    ],
    'Excuse me, where is the bank?',
    'Excuse me ayaa su’aasha edeb ka dhigta.',
  );
  add(
    'chooseGrammar',
    '___ there a pharmacy near here?',
    ['Is', 'Are', 'Do', 'Can be'],
    'Is',
    'A pharmacy waa singular.',
  );
  add(
    'chooseGrammar',
    '___ there any restaurants?',
    ['Are', 'Is', 'Does', 'Can is'],
    'Are',
    'Restaurants waa plural.',
  );
  add(
    'multipleChoice',
    'Sideen suuqa ku tagaa?',
    [
      'How can I get to the market?',
      'How market is get?',
      'Where get I market?',
      'Can market how?',
    ],
    'How can I get to the market?',
    'Tani waa su’aal jid oo sax ah.',
  );
  add(
    'multipleChoice',
    '“Is it far?” jawaab ku habboon?',
    [
      'No, it is five minutes from here.',
      'Turn is far.',
      'Bank no.',
      'It far do.',
    ],
    'No, it is five minutes from here.',
    'Jawaabtu waxay sheegaysaa fogaanta.',
  );
  add(
    'multipleChoice',
    'Nearest maxay ka dhigan tahay?',
    ['ugu dhow', 'ugu fog', 'bidix', 'toos'],
    'ugu dhow',
    'Nearest waa ugu dhow.',
  );
  // 6 direction commands.
  add(
    'multipleChoice',
    'Bidix u leexo.',
    ['Turn left.', 'On the left.', 'Go right.', 'Straight left is.'],
    'Turn left.',
    'Turn left waa amar.',
  );
  add(
    'multipleChoice',
    'Toos u soco.',
    ['Go straight.', 'Turn straight.', 'Straight is.', 'Go opposite.'],
    'Go straight.',
    'Go straight waa amar.',
  );
  add(
    'chooseGrammar',
    '___ the road at the crossing.',
    ['Cross', 'Crosses', 'Crossing', 'To cross'],
    'Cross',
    'Imperative-ku base verb ayuu isticmaalaa.',
  );
  add(
    'chooseGrammar',
    '___ past the bank.',
    ['Walk', 'Walks', 'Walking', 'To walks'],
    'Walk',
    'Instruction-ku wuxuu ku bilaabmaa Walk.',
  );
  add(
    'multipleChoice',
    'Take the second right macnihiisu waa…',
    [
      'Midigta labaad qaado.',
      'Bidixda koowaad qaado.',
      'Toos u soco.',
      'Dib u noqo.',
    ],
    'Midigta labaad qaado.',
    'Second right waa leexashada labaad ee midig.',
  );
  add(
    'multipleChoice',
    'On your left iyo turn left farqigooda?',
    [
      'Kan hore goob ayuu sheegaa; kan dambe amar leexasho.',
      'Labadu bas bay yihiin.',
      'Kan hore amar ayuu yahay.',
      'Wax farqi ah ma leh.',
    ],
    'Kan hore goob ayuu sheegaa; kan dambe amar leexasho.',
    'On your left waa location; turn left waa instruction.',
  );
  // 5 location prepositions.
  add(
    'fillInTheBlank',
    'The pharmacy is ___ the clinic.',
    ['next to', 'turn', 'straight', 'walk'],
    'next to',
    'Next to = ku xiga.',
  );
  add(
    'fillInTheBlank',
    'The bank is ___ the market.',
    ['opposite', 'continue', 'cross', 'take'],
    'opposite',
    'Opposite = ka soo horjeeda.',
  );
  add(
    'fillInTheBlank',
    'The restaurant is ___ the hotel and shop.',
    ['between', 'behind', 'straight', 'past'],
    'between',
    'Between = laba goob u dhexeeya.',
  );
  add(
    'fillInTheBlank',
    'The car park is ___ the building.',
    ['behind', 'opposite', 'turn', 'through'],
    'behind',
    'Behind = gadaashiisa.',
  );
  add(
    'fillInTheBlank',
    'The shop is ___ the corner.',
    ['on', 'in', 'through', 'between'],
    'on',
    'On the corner waa phrase sax ah.',
  );
  // 4 can/cannot.
  add(
    'chooseGrammar',
    'Can you ___ me?',
    ['help', 'helps', 'helping', 'helped'],
    'help',
    'Can kadib base verb.',
  );
  add(
    'chooseGrammar',
    'Can he ___ there?',
    ['walk', 'walks', 'walking', 'walked'],
    'walk',
    'Can kadib walk, ma aha walks.',
  );
  add(
    'multipleChoice',
    'You cannot enter here macnihiisu waa…',
    [
      'Halkan ma geli kartid.',
      'Halkan soo gal.',
      'Halkan ku leexo.',
      'Halkan ka bax.',
    ],
    'Halkan ma geli kartid.',
    'Cannot waa diidmo.',
  );
  add(
    'multipleChoice',
    'Codsi caawimo sax ah?',
    [
      'Can you show me the way?',
      'Can you shows way?',
      'Do can way?',
      'You can the way?',
    ],
    'Can you show me the way?',
    'Can + subject + base verb.',
  );
  // 4 textual map.
  const map =
      'Map: School is north of Bank. Pharmacy is next to Bank. Market is opposite Bank. Park is east of Market.';
  add(
    'readingComprehension',
    '$map Maxaa Bank ku xiga?',
    ['Pharmacy', 'School', 'Park', 'Hotel'],
    'Pharmacy',
    'Map-ku wuxuu sheegay Pharmacy next to Bank.',
  );
  add(
    'readingComprehension',
    '$map Maxaa Bank ka soo horjeeda?',
    ['Market', 'School', 'Pharmacy', 'Park'],
    'Market',
    'Market is opposite Bank.',
  );
  add(
    'readingComprehension',
    '$map Maxaa Bank waqooyi ka xiga?',
    ['School', 'Park', 'Market', 'Pharmacy'],
    'School',
    'School is north of Bank.',
  );
  add(
    'readingComprehension',
    '$map Park-gu xaggee kaga yaal Market?',
    ['East', 'West', 'North', 'South'],
    'East',
    'Park is east of Market.',
  );
  // 3 dialogue comprehension.
  const d =
      'A: Where is the hospital? B: Go straight and turn left at the bank. It is on your right.';
  add(
    'readingComprehension',
    '$d Xaggee lagu leexanayaa?',
    [
      'Left at the bank',
      'Right at the market',
      'Back at the school',
      'Straight at the park',
    ],
    'Left at the bank',
    'Dialogue-gu wuxuu sheegay turn left at the bank.',
  );
  add(
    'readingComprehension',
    '$d Isbitaalku dhinacee ayuu ku yaal?',
    ['On your right', 'On your left', 'Behind you', 'Opposite the bank'],
    'On your right',
    'Dialogue-gu wuxuu sheegay on your right.',
  );
  add(
    'readingComprehension',
    'A: Can I walk to the station? B: Yes. It is five minutes from here. Station-ku ma fog yahay?',
    [
      'No, it is about five minutes away.',
      'Yes, it is one hour away.',
      'It is closed.',
      'No station exists.',
    ],
    'No, it is about five minutes away.',
    'Shan daqiiqo waa meel dhow scenario-gan.',
  );
  return q;
}
