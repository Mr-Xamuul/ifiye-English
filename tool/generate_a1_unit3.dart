import 'dart:convert';
import 'dart:io';

Map<String, dynamic> v(
  String word,
  String meaning,
  String type,
  String pronunciation,
  String exampleEnglish,
  String exampleSomali,
  String explanation, [
  String mistake = '',
]) => {
  'englishWord': word,
  'somaliMeaning': meaning,
  'partOfSpeech': type,
  'pronunciation': pronunciation,
  'exampleEnglish': exampleEnglish,
  'exampleSomali': exampleSomali,
  'explanationSomali': explanation,
  'commonMistakeSomali': mistake,
};

Map<String, String> ex(String english, String somali) => {
  'english': english,
  'somali': somali,
};
Map<String, dynamic> line(String speaker, String english, String somali) => {
  'speaker': speaker,
  'english': english,
  'somali': somali,
};
Map<String, dynamic> dialogue(String title, List<Map<String, dynamic>> lines) =>
    {'titleSomali': title, 'lines': lines};
Map<String, dynamic> exercise(
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

const numberWords = <int, String>{
  0: 'zero',
  1: 'one',
  2: 'two',
  3: 'three',
  4: 'four',
  5: 'five',
  6: 'six',
  7: 'seven',
  8: 'eight',
  9: 'nine',
  10: 'ten',
  11: 'eleven',
  12: 'twelve',
  13: 'thirteen',
  14: 'fourteen',
  15: 'fifteen',
  16: 'sixteen',
  17: 'seventeen',
  18: 'eighteen',
  19: 'nineteen',
  20: 'twenty',
  30: 'thirty',
  40: 'forty',
  50: 'fifty',
  60: 'sixty',
  70: 'seventy',
  80: 'eighty',
  90: 'ninety',
  100: 'one hundred',
};

const numberPronunciations = <int, String>{
  0: 'zii-ro',
  1: 'wan',
  2: 'tuu',
  3: 'thrii',
  4: 'foor',
  5: 'faayv',
  6: 'siks',
  7: 'se-van',
  8: 'eyt',
  9: 'naayn',
  10: 'ten',
  11: 'i-le-van',
  12: 'twelv',
  13: 'ther-tiin',
  14: 'foor-tiin',
  15: 'fif-tiin',
  16: 'siks-tiin',
  17: 'se-van-tiin',
  18: 'ey-tiin',
  19: 'naayn-tiin',
  20: 'twen-ti',
  30: 'ther-ti',
  40: 'foor-ti',
  50: 'fif-ti',
  60: 'siks-ti',
  70: 'se-van-ti',
  80: 'ey-ti',
  90: 'naayn-ti',
  100: 'wan han-dred',
};

String numberWord(int number) {
  if (numberWords.containsKey(number)) {
    return numberWords[number]!;
  }
  final tens = number ~/ 10 * 10;
  return '${numberWords[tens]}-${numberWords[number % 10]}';
}

String numberPronunciation(int number) {
  if (numberPronunciations.containsKey(number)) {
    return numberPronunciations[number]!;
  }
  final tens = number ~/ 10 * 10;
  return '${numberPronunciations[tens]} ${numberPronunciations[number % 10]}';
}

Map<String, dynamic> numberVocab(int number) => v(
  numberWord(number),
  '$number',
  'number',
  numberPronunciation(number),
  'The number is ${numberWord(number)}.',
  'Tiradu waa $number.',
  '${numberWord(number)} waa sida tirada $number loogu qoro English.',
  number == 13
      ? 'Thirteen waa 13; thirty waa 30. Dhawaaqa -teen dheer u sheeg.'
      : number == 14
      ? 'Fourteen waa 14; forty waa 40. Forty laguma qoro fourty.'
      : number == 15
      ? 'Fifteen waa 15; fifty waa 50.'
      : number == 18
      ? 'Eighteen waa 18; eighty waa 80.'
      : '',
);

Map<String, dynamic> grammar(
  String titleEnglish,
  String titleSomali,
  String explanation,
  String rule,
  String structure,
  List<Map<String, String>> examples,
  List<String> mistakes,
) => {
  'titleEnglish': titleEnglish,
  'titleSomali': titleSomali,
  'explanationSomali': explanation,
  'rule': rule,
  'sentenceStructure': structure,
  'positiveExamples': examples,
  'negativeExamples': const [],
  'questionExamples': examples,
  'commonMistakesSomali': mistakes,
  'practiceQuestions': const [],
};

List<Map<String, dynamic>> practices(
  String id,
  List<Map<String, dynamic>> words,
  List<Map<String, String>> examples, {
  required String fillQuestion,
  required String fillAnswer,
  required String arrangeQuestion,
  required String arrangeAnswer,
  required String contextQuestion,
  required List<String> contextOptions,
  required String contextAnswer,
  required String speaking,
  required String writing,
  bool review = false,
}) {
  final items = <Map<String, dynamic>>[
    exercise(
      '$id-p01',
      'multipleChoice',
      '“${words[0]['englishWord']}” maxay ka dhigan tahay?',
      [
        words[1]['somaliMeaning'] as String,
        words[0]['somaliMeaning'] as String,
        words[2]['somaliMeaning'] as String,
        words[3]['somaliMeaning'] as String,
      ],
      words[0]['somaliMeaning'] as String,
      'Jawaabta saxda ahi waa ${words[0]['somaliMeaning']}; xulashooyinka kale waxay la xiriiraan erayo kale oo casharka ku jira.',
    ),
    exercise(
      '$id-p02',
      'fillInTheBlank',
      fillQuestion,
      [
        words[1]['englishWord'] as String,
        fillAnswer,
        words[2]['englishWord'] as String,
        words[3]['englishWord'] as String,
      ],
      fillAnswer,
      '“$fillAnswer” ayaa jumladda ka dhigaya mid naxwe iyo macne ahaan sax ah.',
    ),
    exercise(
      '$id-p03',
      'matchWords',
      'Isku aadi “${words[1]['englishWord']}” iyo macnihiisa.',
      [
        words[3]['somaliMeaning'] as String,
        words[2]['somaliMeaning'] as String,
        words[1]['somaliMeaning'] as String,
        words[0]['somaliMeaning'] as String,
      ],
      words[1]['somaliMeaning'] as String,
      '${words[1]['englishWord']} waxaa loola jeedaa ${words[1]['somaliMeaning']}.',
    ),
    exercise(
      '$id-p04',
      'arrangeSentence',
      arrangeQuestion,
      const [],
      arrangeAnswer,
      'Kala horreynta saxda ahi waa “$arrangeAnswer”.',
    ),
    exercise(
      '$id-p05',
      'englishToSomali',
      'Turjun: ${examples[0]['english']}',
      [
        examples[2]['somali']!,
        examples[1]['somali']!,
        examples[3]['somali']!,
        examples[0]['somali']!,
      ],
      examples[0]['somali']!,
      'Turjumaadda saxda ahi waxay gudbinaysaa macnaha jumladda oo dhan.',
    ),
    exercise(
      '$id-p06',
      'somaliToEnglish',
      'U beddel English: ${examples[1]['somali']}',
      [
        examples[3]['english']!,
        examples[0]['english']!,
        examples[1]['english']!,
        examples[2]['english']!,
      ],
      examples[1]['english']!,
      'Qaabka dabiiciga ah waa “${examples[1]['english']}”.',
    ),
    exercise(
      '$id-p07',
      'trueFalse',
      'Xogta tusaalaha ah ayaa lagu isticmaali karaa layliga halkii xogtaada dhabta ah.',
      const ['True', 'False'],
      'True',
      'Layliga uma baahna xog gaar ah; xog male-awaal ah ayaa ammaan ah.',
    ),
    exercise(
      '$id-p08',
      'multipleChoice',
      contextQuestion,
      contextOptions,
      contextAnswer,
      '“$contextAnswer” ayaa xaaladda ku habboon; xulashooyinka kale waxay bixiyaan tiro ama qaab aan sax ahayn.',
    ),
    exercise(
      '$id-p09',
      'speakingPrompt',
      speaking,
      const [],
      'Teacher review',
      'Isticmaal xog tusaale ah, si tartiib ahna u sheeg tiro ama jumlad kasta.',
    ),
    exercise(
      '$id-p10',
      'shortWriting',
      writing,
      const [],
      'Teacher review',
      'Hubi higgaadda tirooyinka, capital letters-ka magacyada iyo calaamadaha jumladda.',
    ),
  ];
  if (review) {
    items.addAll([
      exercise(
        '$id-p11',
        'multipleChoice',
        '35 sidee loo qoraa?',
        ['thirteen-five', 'thirty-five', 'three-five', 'fifty-three'],
        'thirty-five',
        '35 waa thirty-five, waxaana labada qaybood isku xira hyphen.',
      ),
      exercise(
        '$id-p12',
        'fillInTheBlank',
        'I ___ twenty years old.',
        ['is', 'are', 'am', 'have'],
        'am',
        'Da’da English-ka waxaa lagu sheegaa I am…, ma aha I have….',
      ),
      exercise(
        '$id-p13',
        'multipleChoice',
        'Lambar telefoon sidee badanaa loo akhriyaa?',
        ['Digit-digit', 'Hal eray oo dheer', 'Sida lacagta', 'Sida taariikhda'],
        'Digit-digit',
        'Lambarka telefoonka waxaa la akhriyaa digit kasta gooni.',
      ),
      exercise(
        '$id-p14',
        'fillInTheBlank',
        'I live ___ Mogadishu.',
        ['on', 'at', 'in', 'is'],
        'in',
        'In waxaa lala isticmaalaa magaalo ama dal.',
      ),
      exercise(
        '$id-p15',
        'multipleChoice',
        'Qiimaha hal buug sidee loo weydiiyaa?',
        [
          'How many is this?',
          'How old is this?',
          'How much is this?',
          'Where is this?',
        ],
        'How much is this?',
        'How much waxaa lagu weydiiyaa qiimaha.',
      ),
      exercise(
        '$id-p16',
        'multipleChoice',
        'Bisha 7-aad waa tee?',
        ['June', 'July', 'August', 'May'],
        'July',
        'July waa bisha toddobaad.',
      ),
      exercise(
        '$id-p17',
        'multipleChoice',
        'Foomka “occupation” muxuu weydiinayaa?',
        ['Shaqada', 'Da’da', 'Cinwaanka', 'Telefoonka'],
        'Shaqada',
        'Occupation waa shaqada qofka.',
      ),
      exercise(
        '$id-p18',
        'somaliToEnglish',
        'U beddel: “Waxaan degganahay Soomaaliya.”',
        [
          'I live on Somalia.',
          'I live in Somalia.',
          'I am Somalia.',
          'I live at country.',
        ],
        'I live in Somalia.',
        'Dal waxaa lala isticmaalaa preposition-ka in.',
      ),
      exercise(
        '$id-p19',
        'englishToSomali',
        'Turjun: “It costs ten dollars.”',
        [
          'Waxay joogtaa toban doolar.',
          'Waxay ku kacaysaa toban doolar.',
          'Waxaan hayaa toban doolar.',
          'Tobanku waa qaali.',
        ],
        'Waxay ku kacaysaa toban doolar.',
        'Costs wuxuu tilmaamayaa qiimaha shayga.',
      ),
      exercise(
        '$id-p20',
        'shortWriting',
        'Buuxi foom tusaale ah: full name, age, phone, city, country iyo occupation.',
        const [],
        'Teacher review',
        'Isticmaal xog male-awaal ah; ha gelin xogtaada gaarka ah haddii aadan rabin.',
      ),
    ]);
  }
  return items;
}

Map<String, dynamic> lesson({
  required String id,
  required int number,
  required String titleEnglish,
  required String titleSomali,
  required String description,
  required List<String> objectives,
  required String type,
  required int minutes,
  required String? previous,
  required List<Map<String, dynamic>> vocabulary,
  Map<String, dynamic>? grammarTopic,
  required List<Map<String, String>> examples,
  required List<Map<String, dynamic>> dialogues,
  required List<Map<String, dynamic>> exercises,
  required String speaking,
  required String writing,
  required String summary,
}) => {
  'id': id,
  'levelId': 'A1',
  'unitId': 'a1-u03',
  'lessonNumber': number,
  'titleEnglish': titleEnglish,
  'titleSomali': titleSomali,
  'shortDescriptionSomali': description,
  'learningObjectives': objectives,
  'lessonType': type,
  'estimatedMinutes': minutes,
  'difficulty': 'beginner',
  'isLocked': number != 1,
  'requiredPreviousLessonId': previous,
  'vocabulary': vocabulary,
  'grammar': grammarTopic,
  'examples': examples,
  'dialogues': dialogues,
  'practiceExercises': exercises,
  'speakingPractice': speaking,
  'writingPractice': writing,
  'summarySomali': summary,
  'quizQuestions': exercises.take(3).toList().asMap().entries.map((entry) {
    return {
      ...entry.value,
      'id': '$id-q${(entry.key + 1).toString().padLeft(2, '0')}',
    };
  }).toList(),
};

List<Map<String, dynamic>> twoDialogues(
  String titleOne,
  List<Map<String, dynamic>> one,
  String titleTwo,
  List<Map<String, dynamic>> two,
) => [dialogue(titleOne, one), dialogue(titleTwo, two)];

void main() {
  final l1v = List.generate(21, numberVocab);
  final l1e = [
    ex('I have two books.', 'Waxaan haystaa laba buug.'),
    ex('There are thirteen students.', 'Waxaa jira saddex iyo toban arday.'),
    ex('My number is eighteen.', 'Tiradaydu waa siddeed iyo toban.'),
    ex('She has twenty pens.', 'Waxay haysataa labaatan qalin.'),
    ex('Count from zero to ten.', 'Tiri eber ilaa toban.'),
  ];
  const l1s =
      'Tirso 0 ilaa 20, kadib si cad u kala sheeg thirteen/thirty, fourteen/forty, fifteen/fifty iyo eighteen/eighty.';
  const l1w =
      'Tirooyinka 0 ilaa 20 ku qor English, kadib qor afar lammaane oo -teen iyo -ty ah.';
  final l1x = practices(
    'a1-u03-l01',
    l1v,
    l1e,
    fillQuestion: 'There are ___ students. (13)',
    fillAnswer: 'thirteen',
    arrangeQuestion: 'Kala hagaaji: books / have / two / I',
    arrangeAnswer: 'I have two books.',
    contextQuestion: 'Kee ayaa ah 18?',
    contextOptions: const ['eighty', 'eight', 'eighteen', 'thirteen'],
    contextAnswer: 'eighteen',
    speaking: l1s,
    writing: l1w,
  );

  final l2numbers = [
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    24,
    35,
    48,
    57,
    69,
    73,
    86,
    99,
  ];
  final l2v = l2numbers.map(numberVocab).toList();
  final l2e = [
    ex(
      'The price is twenty-four dollars.',
      'Qiimuhu waa afar iyo labaatan doolar.',
    ),
    ex('There are thirty-five chairs.', 'Waxaa jira shan iyo soddon kursi.'),
    ex(
      'Page forty-eight is open.',
      'Bogga siddeed iyo afartan waa furan yahay.',
    ),
    ex(
      'He is seventy-three years old.',
      'Wuxuu jiraa saddex iyo toddobaatan sano.',
    ),
    ex('One hundred students are here.', 'Boqol arday ayaa halkan jooga.'),
  ];
  const l2s = 'Akhri tirooyinkan: 24, 35, 48, 57, 69, 73, 86, 99 iyo 100.';
  const l2w =
      'Tirooyinka 21, 34, 46, 58, 67, 79, 82, 95 iyo 100 ku qor English adigoo hyphen isticmaalaya.';
  final l2x = practices(
    'a1-u03-l02',
    l2v,
    l2e,
    fillQuestion: 'The number 48 is ___.',
    fillAnswer: 'forty-eight',
    arrangeQuestion: 'Kala hagaaji: is / ninety-nine / number / The',
    arrangeAnswer: 'The number is ninety-nine.',
    contextQuestion: 'Kee ayaa si sax ah loo qoray 40?',
    contextOptions: const ['fourty', 'forty', 'four-ty', 'fourteen'],
    contextAnswer: 'forty',
    speaking: l2s,
    writing: l2w,
  );

  final l3v = [
    v(
      'How old are you?',
      'Immisa jir baad tahay?',
      'age question',
      'haw old aar yuu',
      'How old are you?',
      'Immisa jir baad tahay?',
      'Waxaa lagu weydiiyaa da’da qofka.',
    ),
    v(
      'Years old',
      'Jir/sano da’ ah',
      'age phrase',
      'yiirs old',
      'I am twenty years old.',
      'Waxaan jiraa labaatan sano.',
      'Waxaa tirada kadib lagu caddeeyaa da’da.',
    ),
    v(
      'I am…',
      'Waxaan ahay/jiraa…',
      'verb phrase',
      'aay am',
      'I am eighteen.',
      'Waxaan jiraa siddeed iyo toban.',
      'Da’daada waxaa lagu sheegaa I am, ma aha I have.',
      'Ha oran I have twenty years.',
    ),
    v(
      'How old is he?',
      'Immisa jir buu yahay?',
      'age question',
      'haw old iz hii',
      'How old is he?',
      'Immisa jir buu yahay?',
      'He waxaa la socda is.',
    ),
    v(
      'How old is she?',
      'Immisa jir bay tahay?',
      'age question',
      'haw old iz shii',
      'How old is she?',
      'Immisa jir bay tahay?',
      'She waxaa la socda is.',
    ),
    v(
      'Age',
      'Da’',
      'noun',
      'eyj',
      'Write your example age.',
      'Qor da’ tusaale ah.',
      'Age waa tirada sannadaha qofku jiro.',
    ),
    v(
      'Old',
      'Jir/da’ leh',
      'adjective',
      'old',
      'He is fifteen years old.',
      'Wuxuu jiraa shan iyo toban sano.',
      'Old halkan wuxuu qayb ka yahay qaabka sheegidda da’da.',
    ),
  ];
  final l3e = [
    ex('I am twenty years old.', 'Waxaan jiraa labaatan sano.'),
    ex('I’m twenty.', 'Waxaan jiraa labaatan.'),
    ex('He is fifteen years old.', 'Wuxuu jiraa shan iyo toban sano.'),
    ex('She is eighteen.', 'Waxay jirtaa siddeed iyo toban.'),
    ex('How old are you?', 'Immisa jir baad tahay?'),
  ];
  const l3s =
      'Isticmaal da’ tusaale ah: weydii How old are you? kadib ku jawaab I am … years old.';
  const l3w =
      'Qor da’da saddex qof oo tusaale ah adigoo isticmaalaya I am, he is iyo she is.';
  final l3x = practices(
    'a1-u03-l03',
    l3v,
    l3e,
    fillQuestion: 'I ___ twenty years old.',
    fillAnswer: 'am',
    arrangeQuestion: 'Kala hagaaji: old / are / How / you',
    arrangeAnswer: 'How old are you?',
    contextQuestion: 'Kee ayaa ah qaabka saxda ah?',
    contextOptions: const [
      'I have twenty years.',
      'I am twenty years old.',
      'I is twenty.',
      'I are twenty old.',
    ],
    contextAnswer: 'I am twenty years old.',
    speaking: l3s,
    writing: l3w,
  );

  final l4v = [
    v(
      'Phone number',
      'Lambarka telefoonka',
      'noun phrase',
      'foon nam-ber',
      'My phone number is 000 123 4567.',
      'Lambarkayga tusaalaha ahi waa 000 123 4567.',
      'Lambar telefoon waa taxane digits ah; tusaalahan ma aha lambar qof dhab ah.',
    ),
    v(
      'What is your phone number?',
      'Waa maxay lambarka telefoonkaagu?',
      'question',
      'wot iz yor foon nam-ber',
      'What is your phone number?',
      'Waa maxay lambarka telefoonkaagu?',
      'Waxaa lagu codsadaa lambarka telefoonka.',
    ),
    v(
      'Repeat',
      'Ku celi',
      'verb',
      'ri-piit',
      'Can you repeat that?',
      'Ma ku celin kartaa taas?',
      'Waxaa la yiraahdaa marka lambar aan la maqal.',
    ),
    v(
      'Say it again',
      'Mar kale sheeg',
      'request',
      'sey it a-gen',
      'Please say it again.',
      'Fadlan mar kale sheeg.',
      'Waa codsi edeb leh oo ku celin ah.',
    ),
    v(
      'Double',
      'Laba jeer isku mid ah',
      'number word',
      'da-bal',
      'Double zero means 00.',
      'Double zero wuxuu ka dhigan yahay 00.',
      'Double waxaa lagu gaabiyaa laba digit oo isku mid ah.',
    ),
    v(
      'Zero',
      'Eber',
      'number',
      'zii-ro',
      'The first digit is zero.',
      'Digit-ka koowaad waa eber.',
      'Zero ayaa si rasmi ah loo akhriyaa 0.',
    ),
    v(
      'Oh',
      'O; mararka qaar 0',
      'phone-number word',
      'ow',
      'You can say oh for zero in a phone number.',
      'Lambar telefoon waxaad zero u oran kartaa oh.',
      'Oh waxaa lagu isticmaali karaa 0 marka lambar telefoon la akhrinayo.',
    ),
  ];
  final l4e = [
    ex(
      'My phone number is 000 123 4567.',
      'Lambarkayga tusaalaha ahi waa 000 123 4567.',
    ),
    ex('Zero six one, two three four.', 'Eber lix kow, laba saddex afar.'),
    ex('Can you repeat that?', 'Ma ku celin kartaa taas?'),
    ex('Please say it again.', 'Fadlan mar kale sheeg.'),
    ex('Double zero, one two.', 'Laba eber, kow laba.'),
  ];
  const l4s =
      'Akhri lambarro tusaale ah digit-digit: 000 123 4567 iyo 061 000 0000. Ha isticmaalin lambar dhab ah.';
  const l4w =
      'Qor laba lambar telefoon oo male-awaal ah, kadib hoostooda ku qor sida digit-digit loogu akhriyo.';
  final l4x = practices(
    'a1-u03-l04',
    l4v,
    l4e,
    fillQuestion: 'My phone ___ is 000 123 4567.',
    fillAnswer: 'number',
    arrangeQuestion: 'Kala hagaaji: number / phone / your / is / What',
    arrangeAnswer: 'What is your phone number?',
    contextQuestion: '“Double zero” waa tee?',
    contextOptions: const ['20', '00', '02', '200'],
    contextAnswer: '00',
    speaking: l4s,
    writing: l4w,
  );

  final l5v = [
    v(
      'Where do you live?',
      'Xaggee baad degan tahay?',
      'question',
      'wer duu yuu liv',
      'Where do you live?',
      'Xaggee baad degan tahay?',
      'Waxaa lagu weydiiyaa meesha qof degan yahay.',
    ),
    v(
      'Address',
      'Cinwaan',
      'noun',
      'a-dres',
      'What is your address?',
      'Waa maxay cinwaankaagu?',
      'Address wuxuu tilmaamaa meesha lagu heli karo guri ama dhisme.',
    ),
    v(
      'Street',
      'Jid waddo yar',
      'noun',
      'striit',
      'The shop is on Market Street.',
      'Dukaanku wuxuu ku yaal Market Street.',
      'Street waa jid magaalo.',
    ),
    v(
      'Road',
      'Waddo',
      'noun',
      'rood',
      'I live on Peace Road.',
      'Waxaan degganahay Peace Road.',
      'On waxaa badanaa lala isticmaalaa magaca waddada.',
    ),
    v(
      'House',
      'Guri',
      'noun',
      'haws',
      'My house number is twelve.',
      'Lambarka gurigaygu waa laba iyo toban.',
      'House waa guri la deggan yahay.',
    ),
    v(
      'Building',
      'Dhisme',
      'noun',
      'bil-ding',
      'The office is in this building.',
      'Xafiisku wuxuu ku jiraa dhismahan.',
      'Building waa dhisme guryo ama xafiisyo leh.',
    ),
    v(
      'City',
      'Magaalo',
      'noun',
      'si-ti',
      'Mogadishu is a city.',
      'Muqdisho waa magaalo.',
      'In waxaa lala isticmaalaa magaalo.',
    ),
    v(
      'District',
      'Degmo',
      'noun',
      'dis-trikt',
      'I live in Hodan District.',
      'Waxaan degganahay Degmada Hodan.',
      'District waa qayb ka mid ah magaalo ama gobol.',
    ),
    v(
      'Country',
      'Dal',
      'noun',
      'kan-tri',
      'I live in Somalia.',
      'Waxaan degganahay Soomaaliya.',
      'Country waa dal.',
    ),
    v(
      'In',
      'Gudaha/ku jira',
      'preposition',
      'in',
      'I live in Nairobi.',
      'Waxaan degganahay Nairobi.',
      'In waxaa lala isticmaalaa magaalo, degmo ama dal.',
    ),
    v(
      'On',
      'Dusha/ku yaal',
      'preposition',
      'on',
      'I live on Peace Road.',
      'Waxaan degganahay Peace Road.',
      'On waxaa lala isticmaalaa magaca waddo.',
    ),
  ];
  final l5e = [
    ex('I live in Mogadishu.', 'Waxaan degganahay Muqdisho.'),
    ex('I live in Hodan District.', 'Waxaan degganahay Degmada Hodan.'),
    ex('I live on Peace Road.', 'Waxaan degganahay Peace Road.'),
    ex('My house number is twelve.', 'Lambarka gurigaygu waa laba iyo toban.'),
    ex('I live in Somalia.', 'Waxaan degganahay Soomaaliya.'),
  ];
  const l5s =
      'Isticmaal cinwaan male-awaal ah: sheeg magaalo, degmo, waddo iyo lambar guri.';
  const l5w =
      'Qor cinwaan tusaale ah oo leh city, district, road iyo house number; ha isticmaalin cinwaan dhab ah.';
  final l5x = practices(
    'a1-u03-l05',
    l5v,
    l5e,
    fillQuestion: 'I live ___ Somalia.',
    fillAnswer: 'in',
    arrangeQuestion: 'Kala hagaaji: live / Where / you / do',
    arrangeAnswer: 'Where do you live?',
    contextQuestion: 'Magaca waddo preposition kee la socda?',
    contextOptions: const ['in', 'on', 'is', 'am'],
    contextAnswer: 'on',
    speaking: l5s,
    writing: l5w,
  );

  final l6v = [
    v(
      'How much is this?',
      'Immisa ayuu kani yahay?',
      'price question',
      'haw mach iz dhis',
      'How much is this book?',
      'Immisa ayuu yahay buuggan?',
      'How much waxaa lagu weydiiyaa qiimaha.',
    ),
    v(
      'How much does it cost?',
      'Immisa ayuu ku kacayaa?',
      'price question',
      'haw mach daz it kost',
      'How much does it cost?',
      'Immisa ayuu ku kacayaa?',
      'Cost wuxuu weydiinayaa qiimaha shayga.',
    ),
    v(
      'Price',
      'Qiime',
      'noun',
      'praays',
      'The price is five dollars.',
      'Qiimuhu waa shan doolar.',
      'Price waa lacagta shay lagu iibiyo.',
    ),
    v(
      'Cost',
      'Ku kac/qiime leeyahay',
      'verb',
      'kost',
      'It costs ten dollars.',
      'Waxay ku kacaysaa toban doolar.',
      'Costs waxaa lala isticmaalaa it.',
    ),
    v(
      'Cheap',
      'Raqiis',
      'adjective',
      'jiip',
      'The pen is cheap.',
      'Qalinku waa raqiis.',
      'Cheap wuxuu tilmaamaa qiime hoose.',
    ),
    v(
      'Expensive',
      'Qaali',
      'adjective',
      'ik-spen-siv',
      'The phone is expensive.',
      'Telefoonku waa qaali.',
      'Expensive wuxuu tilmaamaa qiime sare.',
    ),
    v(
      'Dollar',
      'Doolar',
      'noun',
      'do-lar',
      'It is one dollar.',
      'Waa hal doolar.',
      'Dollar waa lacag; plural-ku waa dollars.',
    ),
    v(
      'Cent',
      'Senti',
      'noun',
      'sent',
      'It is fifty cents.',
      'Waa konton senti.',
      'Boqol cents waxay la mid yihiin hal dollar.',
    ),
    v(
      'Total',
      'Wadarta',
      'noun',
      'to-tal',
      'The total is twelve dollars.',
      'Wadartu waa laba iyo toban doolar.',
      'Total waa qiimaha dhammaan waxyaabaha la isku daray.',
    ),
    v(
      'How many?',
      'Immisa xabbo?',
      'quantity question',
      'haw me-ni',
      'How many books do you want?',
      'Immisa buug ayaad rabtaa?',
      'How many waxaa lagu weydiiyaa tirada shay la tirin karo; How much halkan qiime ayuu weydiinayaa.',
    ),
  ];
  final l6e = [
    ex('How much is this?', 'Immisa ayuu kani yahay?'),
    ex('It is five dollars.', 'Waa shan doolar.'),
    ex('How much does it cost?', 'Immisa ayuu ku kacayaa?'),
    ex('The book costs ten dollars.', 'Buuggu wuxuu ku kacayaa toban doolar.'),
    ex('The total is twelve dollars.', 'Wadartu waa laba iyo toban doolar.'),
  ];
  const l6s =
      'Samee xaalad dukaan: weydii qiimaha buug, cunto, gaadiid iyo shay kale oo tusaale ah.';
  const l6w =
      'Qor wada sheekeysi dukaan oo shan sadar ah, kuna dar price, cheap ama expensive iyo total.';
  final l6x = practices(
    'a1-u03-l06',
    l6v,
    l6e,
    fillQuestion: 'How ___ is this?',
    fillAnswer: 'much',
    arrangeQuestion: 'Kala hagaaji: cost / does / it / much / How',
    arrangeAnswer: 'How much does it cost?',
    contextQuestion: 'Waxaad rabtaa qiimaha hal buug. Kee sax ah?',
    contextOptions: const [
      'How many is this?',
      'How much is this?',
      'How old is this?',
      'Where is this?',
    ],
    contextAnswer: 'How much is this?',
    speaking: l6s,
    writing: l6w,
  );

  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final monthSomali = [
    'Jannaayo',
    'Febraayo',
    'Maarso',
    'Abriil',
    'Maajo',
    'Juun',
    'Luulyo',
    'Agoosto',
    'Sebtembar',
    'Oktoobar',
    'Nofeembar',
    'Diseembar',
  ];
  final l7v = <Map<String, dynamic>>[
    v(
      'Date',
      'Taariikh',
      'noun',
      'deyt',
      'What is today’s date?',
      'Waa maxay taariikhda maanta?',
      'Date waa maalinta, bisha iyo sannadka.',
    ),
    v(
      'Date of birth',
      'Taariikhda dhalashada',
      'noun phrase',
      'deyt ov berth',
      'My example date of birth is 5 July 2000.',
      'Taariikhda dhalashada tusaalaha ahi waa 5 Luulyo 2000.',
      'Waxaad layliga ku isticmaali kartaa taariikh male-awaal ah.',
    ),
    v(
      'Day',
      'Maalin',
      'noun',
      'dey',
      'The day is the fifth.',
      'Maalintu waa shanta.',
      'Taariikhaha waxay isticmaalaan ordinal numbers sida first iyo fifth.',
    ),
    v(
      'Month',
      'Bil',
      'noun',
      'manth',
      'July is a month.',
      'Luulyo waa bil.',
      'Sannadku wuxuu leeyahay 12 bilood.',
    ),
    v(
      'Year',
      'Sannad',
      'noun',
      'yiir',
      'The year is 2026.',
      'Sannadku waa 2026.',
      'Year waa sannad.',
    ),
    ...List.generate(
      12,
      (index) => v(
        monthNames[index],
        monthSomali[index],
        'month',
        monthNames[index].toLowerCase(),
        '${monthNames[index]} is month ${index + 1}.',
        '${monthSomali[index]} waa bisha ${index + 1}.',
        '${monthNames[index]} waa magaca bisha ${index + 1} ee sannadka.',
      ),
    ),
    v(
      'First',
      'Koowaad',
      'ordinal number',
      'ferst',
      'January is the first month.',
      'Jannaayo waa bisha koowaad.',
      'Ordinal number wuxuu muujinayaa kala horreyn.',
    ),
  ];
  final l7e = [
    ex('Today is 5 July 2026.', 'Maanta waa 5 Luulyo 2026.'),
    ex('Today is July 5, 2026.', 'Maanta waa Luulyo 5, 2026.'),
    ex('What is your date of birth?', 'Waa maxay taariikhda dhalashadaadu?'),
    ex(
      'My example date of birth is 1 January 2000.',
      'Taariikhda dhalashada tusaalaha ahi waa 1 Jannaayo 2000.',
    ),
    ex(
      'December is the twelfth month.',
      'Diseembar waa bisha laba iyo tobnaad.',
    ),
  ];
  const l7s =
      'Sheeg saddex taariikhood oo tusaale ah, hal mar qaabka 5 July 2026, marna July 5, 2026.';
  const l7w =
      'Qor 12-ka bilood, kadib qor saddex taariikhood oo male-awaal ah labada qaab.';
  final l7x = practices(
    'a1-u03-l07',
    l7v,
    l7e,
    fillQuestion: 'July is the seventh ___.',
    fillAnswer: 'month',
    arrangeQuestion: 'Kala hagaaji: date / today’s / is / What',
    arrangeAnswer: 'What is today’s date?',
    contextQuestion: 'Kee ayaa ah taariikh si sax ah loo qoray?',
    contextOptions: const [
      '5 July 2026',
      'July of five is',
      '2026 fifth July is',
      'Five 2026 July',
    ],
    contextAnswer: '5 July 2026',
    speaking: l7s,
    writing: l7w,
  );

  final l8v = [
    v(
      'First name',
      'Magaca koowaad',
      'form field',
      'ferst neym',
      'First name: Amina.',
      'Magaca koowaad: Aamina.',
      'First name waa magaca qofka loogu yeero.',
    ),
    v(
      'Last name',
      'Magaca dambe/qoyska',
      'form field',
      'laast neym',
      'Last name: Noor.',
      'Magaca dambe: Nuur.',
      'Last name waa magaca dambe ee foomka.',
    ),
    v(
      'Full name',
      'Magaca oo buuxa',
      'form field',
      'ful neym',
      'Full name: Amina Noor.',
      'Magaca oo buuxa: Aamina Nuur.',
      'Full name wuxuu isku daraa magaca koowaad iyo kan dambe.',
    ),
    v(
      'Age',
      'Da’',
      'form field',
      'eyj',
      'Age: 20.',
      'Da’da: 20.',
      'Age field-ku wuxuu rabaa tirada sannadaha.',
    ),
    v(
      'Phone number',
      'Lambarka telefoonka',
      'form field',
      'foon nam-ber',
      'Phone number: 000 123 4567.',
      'Lambarka tusaalaha: 000 123 4567.',
      'Isticmaal lambar male-awaal ah markaad ku tababaranayso.',
    ),
    v(
      'Address',
      'Cinwaan',
      'form field',
      'a-dres',
      'Address: Example Road.',
      'Cinwaan: Example Road.',
      'Address field-ku wuxuu rabaa meesha tusaalaha ah.',
    ),
    v(
      'City',
      'Magaalo',
      'form field',
      'si-ti',
      'City: Mogadishu.',
      'Magaalo: Muqdisho.',
      'City waa magaalada.',
    ),
    v(
      'Country',
      'Dal',
      'form field',
      'kan-tri',
      'Country: Somalia.',
      'Dal: Soomaaliya.',
      'Country waa dalka.',
    ),
    v(
      'Nationality',
      'Jinsiyad/dhalasho dal',
      'form field',
      'na-sha-na-li-ti',
      'Nationality: Somali.',
      'Jinsiyad: Soomaali.',
      'Nationality wuxuu tilmaamaa dalka ama jinsiyadda qofka.',
    ),
    v(
      'Date of birth',
      'Taariikhda dhalashada',
      'form field',
      'deyt ov berth',
      'Date of birth: 1 January 2000.',
      'Taariikh dhalasho tusaale: 1 Jannaayo 2000.',
      'Isticmaal taariikh male-awaal ah layliga.',
    ),
    v(
      'Occupation',
      'Shaqo',
      'form field',
      'o-kyu-pey-shan',
      'Occupation: Student.',
      'Shaqo: Arday.',
      'Occupation waa shaqada qofka.',
    ),
    v(
      'Employee',
      'Shaqaale',
      'noun',
      'em-ploy-ii',
      'She is an employee.',
      'Iyadu waa shaqaale.',
      'Employee waa qof u shaqeeya hay’ad ama ganacsi.',
    ),
    v(
      'Businessperson',
      'Ganacsade',
      'noun',
      'biz-nis per-san',
      'He is a businessperson.',
      'Isagu waa ganacsade.',
      'Businessperson waa qof ganacsi sameeya.',
    ),
  ];
  final l8e = [
    ex('My first name is Amina.', 'Magacayga koowaad waa Aamina.'),
    ex('My full name is Amina Noor.', 'Magacayga oo buuxa waa Aamina Nuur.'),
    ex('I am twenty years old.', 'Waxaan jiraa labaatan sano.'),
    ex(
      'I live in Mogadishu, Somalia.',
      'Waxaan degganahay Muqdisho, Soomaaliya.',
    ),
    ex('My occupation is student.', 'Shaqadaydu waa arday.'),
  ];
  const l8s =
      'Akhri foom tusaale ah oo leh magac, da’ tusaale, telefoon male-awaal, magaalo, dal iyo occupation.';
  const l8w =
      'Buuxi sample form adigoo isticmaalaya qof male-awaal ah; ha qorin xogtaada dhabta ah.';
  final l8x = practices(
    'a1-u03-l08',
    l8v,
    l8e,
    fillQuestion: 'My full ___ is Amina Noor.',
    fillAnswer: 'name',
    arrangeQuestion: 'Kala hagaaji: occupation / is / My / student',
    arrangeAnswer: 'My occupation is student.',
    contextQuestion: 'Foomka “Nationality” maxaa lagu qoraa?',
    contextOptions: const ['Da’da', 'Jinsiyadda', 'Telefoonka', 'Qiimaha'],
    contextAnswer: 'Jinsiyadda',
    speaking: l8s,
    writing: l8w,
  );

  final l9v = [
    v(
      'Number',
      'Tiro',
      'noun',
      'nam-ber',
      'Write the number in English.',
      'Tirada ku qor English.',
      'Number waa tiro.',
    ),
    v(
      'Age',
      'Da’',
      'noun',
      'eyj',
      'Ask an example age.',
      'Weydii da’ tusaale ah.',
      'Age waa sannadaha qofku jiro.',
    ),
    v(
      'Phone number',
      'Lambar telefoon',
      'noun phrase',
      'foon nam-ber',
      'Read the phone number digit by digit.',
      'Lambarka digit-digit u akhri.',
      'Telefoonka digit kasta gooni ayaa loo akhriyaa.',
    ),
    v(
      'Address',
      'Cinwaan',
      'noun',
      'a-dres',
      'Give an example address.',
      'Sheeg cinwaan tusaale ah.',
      'Cinwaan dhab ah looma baahna.',
    ),
    v(
      'Price',
      'Qiime',
      'noun',
      'praays',
      'Ask the price.',
      'Weydii qiimaha.',
      'How much ayaa qiime lagu weydiiyaa.',
    ),
    v(
      'Date',
      'Taariikh',
      'noun',
      'deyt',
      'Write an example date.',
      'Qor taariikh tusaale ah.',
      'Taariikhdu waxay leedahay maalin, bil iyo sannad.',
    ),
    v(
      'Form',
      'Foom',
      'noun',
      'foorm',
      'Complete the form.',
      'Buuxi foomka.',
      'Foomku wuxuu ururiyaa macluumaad aasaasi ah.',
    ),
    v(
      'Personal information',
      'Macluumaad qofeed',
      'noun phrase',
      'per-sa-nal in-for-mey-shan',
      'Use fictional personal information.',
      'Isticmaal macluumaad qofeed oo male-awaal ah.',
      'Xog tusaale ah ayaa ammaan u ah practice-ka.',
    ),
  ];
  final l9e = [
    ex('I am twenty years old.', 'Waxaan jiraa labaatan sano.'),
    ex(
      'My example phone number is 000 123 4567.',
      'Lambarkayga tusaalaha ahi waa 000 123 4567.',
    ),
    ex('I live in Mogadishu.', 'Waxaan degganahay Muqdisho.'),
    ex('It costs five dollars.', 'Waxay ku kacaysaa shan doolar.'),
    ex('Today is 5 July 2026.', 'Maanta waa 5 Luulyo 2026.'),
  ];
  const l9s =
      'Tirso, sheeg da’ tusaale, akhri lambar male-awaal ah, sheeg cinwaan, weydii qiime, kadib sheeg taariikh.';
  const l9w =
      'Samee foom iyo wada sheekeysi isku dara da’, telefoon, cinwaan, qiime iyo taariikh.';
  final l9x = practices(
    'a1-u03-l09',
    l9v,
    l9e,
    fillQuestion: 'How ___ is this book?',
    fillAnswer: 'much',
    arrangeQuestion: 'Kala hagaaji: live / Somalia / in / I',
    arrangeAnswer: 'I live in Somalia.',
    contextQuestion: 'Kee ayaa sax u sheegaya da’da?',
    contextOptions: const [
      'I have twenty years.',
      'I am twenty years old.',
      'I is twenty.',
      'I live twenty.',
    ],
    contextAnswer: 'I am twenty years old.',
    speaking: l9s,
    writing: l9w,
    review: true,
  );

  List<Map<String, dynamic>> d(String key) => switch (key) {
    'l1' => twoDialogues(
      'Laba arday oo tirinaya',
      [
        line('Asha', 'How many books?', 'Immisa buug?'),
        line('Ali', 'Thirteen books.', 'Saddex iyo toban buug.'),
        line(
          'Asha',
          'Thirteen, not thirty?',
          'Saddex iyo toban, ma aha soddon?',
        ),
        line('Ali', 'Yes, thirteen.', 'Haa, saddex iyo toban.'),
      ],
      'Fasalka',
      [
        line('Teacher', 'Count from zero to five.', 'Tiri eber ilaa shan.'),
        line(
          'Student',
          'Zero, one, two, three, four, five.',
          'Eber, kow, laba, saddex, afar, shan.',
        ),
        line('Teacher', 'Good.', 'Fiican.'),
        line('Student', 'Thank you.', 'Mahadsanid.'),
      ],
    ),
    'l2' => twoDialogues(
      'Tiro bog',
      [
        line(
          'Teacher',
          'Open page forty-eight.',
          'Fur bogga siddeed iyo afartan.',
        ),
        line('Student', 'Page forty-eight?', 'Bogga siddeed iyo afartan?'),
        line('Teacher', 'Yes.', 'Haa.'),
        line('Student', 'It is open.', 'Waa furan yahay.'),
      ],
      'Tirada kuraasta',
      [
        line('A', 'How many chairs?', 'Immisa kursi?'),
        line('B', 'Thirty-five.', 'Shan iyo soddon.'),
        line('A', 'Please repeat.', 'Fadlan ku celi.'),
        line('B', 'Thirty-five chairs.', 'Shan iyo soddon kursi.'),
      ],
    ),
    'l3' => twoDialogues(
      'Laba arday oo da’dooda sheegaya',
      [
        line('Amina', 'How old are you?', 'Immisa jir baad tahay?'),
        line('Hassan', 'I am twenty years old.', 'Waxaan jiraa labaatan sano.'),
        line('Hassan', 'How old are you?', 'Adigu immisa jir baad tahay?'),
        line('Amina', 'I’m eighteen.', 'Waxaan jiraa siddeed iyo toban.'),
      ],
      'Da’da qof kale',
      [
        line('A', 'How old is he?', 'Immisa jir buu yahay?'),
        line('B', 'He is fifteen.', 'Wuxuu jiraa shan iyo toban.'),
        line('A', 'How old is she?', 'Immisa jir bay tahay?'),
        line('B', 'She is eighteen.', 'Waxay jirtaa siddeed iyo toban.'),
      ],
    ),
    'l4' => twoDialogues(
      'Lambar telefoon tusaale ah',
      [
        line(
          'A',
          'What is your example phone number?',
          'Waa maxay lambarkaaga tusaalaha ahi?',
        ),
        line('B', 'It is 000 123 4567.', 'Waa 000 123 4567.'),
        line('A', 'Can you repeat that?', 'Ma ku celin kartaa?'),
        line(
          'B',
          'Double zero, zero, one two three…',
          'Laba eber, eber, kow laba saddex…',
        ),
      ],
      'Telefoonka xafiiska',
      [
        line(
          'Worker',
          'Please say the number again.',
          'Fadlan lambarka mar kale sheeg.',
        ),
        line(
          'Caller',
          'Zero six one, double zero…',
          'Eber lix kow, laba eber…',
        ),
        line('Worker', 'Thank you.', 'Mahadsanid.'),
        line('Caller', 'You are welcome.', 'Adigaa mudan.'),
      ],
    ),
    'l5' => twoDialogues(
      'Cinwaan tusaale ah',
      [
        line('A', 'Where do you live?', 'Xaggee baad degan tahay?'),
        line(
          'B',
          'I live in Hodan District.',
          'Waxaan degganahay Degmada Hodan.',
        ),
        line('A', 'What road?', 'Waddadee?'),
        line('B', 'Example Road.', 'Example Road.'),
      ],
      'Magaalo iyo dal',
      [
        line('Worker', 'What is your city?', 'Waa maxay magaaladaadu?'),
        line('Student', 'Mogadishu.', 'Muqdisho.'),
        line('Worker', 'Country?', 'Dal?'),
        line('Student', 'Somalia.', 'Soomaaliya.'),
      ],
    ),
    'l6' => twoDialogues(
      'Dukaan buug',
      [
        line(
          'Customer',
          'How much is this book?',
          'Immisa ayuu yahay buuggan?',
        ),
        line('Seller', 'It is five dollars.', 'Waa shan doolar.'),
        line('Customer', 'That is cheap.', 'Taasi waa raqiis.'),
        line('Seller', 'Yes.', 'Haa.'),
      ],
      'Makhaayad',
      [
        line('Customer', 'How much does it cost?', 'Immisa ayuu ku kacayaa?'),
        line(
          'Worker',
          'It costs ten dollars.',
          'Waxay ku kacaysaa toban doolar.',
        ),
        line('Customer', 'What is the total?', 'Waa maxay wadartu?'),
        line('Worker', 'Twelve dollars.', 'Laba iyo toban doolar.'),
      ],
    ),
    'l7' => twoDialogues(
      'Taariikhda maanta',
      [
        line('A', 'What is today’s date?', 'Waa maxay taariikhda maanta?'),
        line('B', 'Today is 5 July 2026.', 'Maanta waa 5 Luulyo 2026.'),
        line('A', 'July fifth?', 'Luulyo shanteeda?'),
        line('B', 'Yes.', 'Haa.'),
      ],
      'Taariikh dhalasho tusaale ah',
      [
        line(
          'Worker',
          'What is your example date of birth?',
          'Waa maxay taariikhda dhalashada tusaalaha ahi?',
        ),
        line('Student', '1 January 2000.', '1 Jannaayo 2000.'),
        line('Worker', 'Thank you.', 'Mahadsanid.'),
        line('Student', 'You are welcome.', 'Adigaa mudan.'),
      ],
    ),
    'l8' => twoDialogues(
      'Foom shaqaale',
      [
        line(
          'Worker',
          'What is your full name?',
          'Waa maxay magacaaga oo buuxa?',
        ),
        line('Applicant', 'Amina Noor.', 'Aamina Nuur.'),
        line('Worker', 'Occupation?', 'Shaqo?'),
        line('Applicant', 'Student.', 'Arday.'),
      ],
      'Foom tusaale ah',
      [
        line('A', 'City?', 'Magaalo?'),
        line('B', 'Mogadishu.', 'Muqdisho.'),
        line('A', 'Country?', 'Dal?'),
        line('B', 'Somalia.', 'Soomaaliya.'),
      ],
    ),
    _ => twoDialogues(
      'Dib-u-eegis xog qofeed',
      [
        line('A', 'How old are you?', 'Immisa jir baad tahay?'),
        line('B', 'I am twenty.', 'Waxaan jiraa labaatan.'),
        line('A', 'Where do you live?', 'Xaggee baad degan tahay?'),
        line('B', 'I live in Mogadishu.', 'Waxaan degganahay Muqdisho.'),
      ],
      'Dib-u-eegis dukaan',
      [
        line('Customer', 'How much is this?', 'Immisa ayuu kani yahay?'),
        line('Seller', 'Five dollars.', 'Shan doolar.'),
        line('Customer', 'Thank you.', 'Mahadsanid.'),
        line('Seller', 'You are welcome.', 'Adigaa mudan.'),
      ],
    ),
  };

  final lessons = [
    lesson(
      id: 'a1-u03-l01',
      number: 1,
      titleEnglish: 'Numbers 0–20',
      titleSomali: 'Tirooyinka eber ilaa labaatan',
      description:
          'Bar qorista iyo dhawaaqa zero ilaa twenty, iyo farqiga hordhaca ah ee -teen iyo -ty.',
      objectives: const [
        'Akhri oo qor 0 ilaa 20.',
        'Tirso si sax ah zero ilaa twenty.',
        'Kala saar thirteen/thirty iyo lammaanayaasha la midka ah.',
      ],
      type: 'vocabulary',
      minutes: 24,
      previous: null,
      vocabulary: l1v,
      examples: l1e,
      dialogues: d('l1'),
      exercises: l1x,
      speaking: l1s,
      writing: l1w,
      summary:
          'Waxaad baratay zero ilaa twenty. -teen wuxuu tilmaamaa 13–19; -ty wuxuu yimaadaa tobannada sida thirty iyo forty.',
    ),
    lesson(
      id: 'a1-u03-l02',
      number: 2,
      titleEnglish: 'Numbers 21–100',
      titleSomali: 'Tirooyinka kow iyo labaatan ilaa boqol',
      description:
          'Bar tobannada, tirooyinka isku dhafan iyo hyphen-ka twenty-one ilaa ninety-nine.',
      objectives: const [
        'Akhri tirooyinka 21 ilaa 100.',
        'Samee tiro isku dhafan tens + ones.',
        'Hyphen si sax ah ugu qor tirooyinka isku dhafan.',
      ],
      type: 'vocabulary',
      minutes: 25,
      previous: 'a1-u03-l01',
      vocabulary: l2v,
      examples: l2e,
      dialogues: d('l2'),
      exercises: l2x,
      speaking: l2s,
      writing: l2w,
      summary:
          'Tirooyinka isku dhafan waxay ka kooban yihiin tens iyo ones: twenty-four. 40 waxaa loo qoraa forty, 100-na one hundred.',
    ),
    lesson(
      id: 'a1-u03-l03',
      number: 3,
      titleEnglish: 'Asking and Saying Age',
      titleSomali: 'Weydiinta iyo sheegidda da’da',
      description: 'Bar How old…? iyo sida am, is, are loogu isticmaalo da’da.',
      objectives: const [
        'Da’da qof weydii.',
        'Da’ tusaale ah ku sheeg I am… years old.',
        'Am, is iyo are ku waafaji subject-ka.',
      ],
      type: 'grammar',
      minutes: 20,
      previous: 'a1-u03-l02',
      vocabulary: l3v,
      grammarTopic: grammar(
        'How old with am, is, are',
        'How old iyo am, is, are',
        'Da’da waxaa English-ka lagu sheegaa verb to be: I am, he/she is, you are.',
        'I am; he/she is; you are',
        'How old + am/is/are + subject?',
        l3e,
        const [
          'Ha oran I have twenty years.',
          'Ha oran How old you are? su’aal toos ah.',
        ],
      ),
      examples: l3e,
      dialogues: d('l3'),
      exercises: l3x,
      speaking: l3s,
      writing: l3w,
      summary:
          'Qaabka saxda ahi waa I am twenty years old. How old are you? iyo How old is he/she? ayaa da’da lagu weydiiyaa.',
    ),
    lesson(
      id: 'a1-u03-l04',
      number: 4,
      titleEnglish: 'Phone Numbers',
      titleSomali: 'Lambarrada telefoonka',
      description:
          'Bar codsiga, ku celinta iyo akhrinta lambar telefoon digit-digit adigoo adeegsanaya zero, oh iyo double.',
      objectives: const [
        'Lambar tusaale digit-digit u akhri.',
        'Codso lambar telefoon.',
        'Weydii in lambar lagu celiyo.',
      ],
      type: 'speaking',
      minutes: 21,
      previous: 'a1-u03-l03',
      vocabulary: l4v,
      examples: l4e,
      dialogues: d('l4'),
      exercises: l4x,
      speaking: l4s,
      writing: l4w,
      summary:
          'Lambarrada telefoonka digit-digit ayaa loo akhriyaa. Zero waxaa mararka qaar loo dhihi karaa oh; double zero waa 00.',
    ),
    lesson(
      id: 'a1-u03-l05',
      number: 5,
      titleEnglish: 'Addresses',
      titleSomali: 'Cinwaannada',
      description:
          'Bar sida magaalo, degmo, waddo, guri, dhisme iyo dal loogu sheego cinwaan fudud.',
      objectives: const [
        'Weydii Where do you live?',
        'Sheeg magaalo iyo dal.',
        'In iyo on si sax ah ugu isticmaal cinwaan.',
      ],
      type: 'grammar',
      minutes: 22,
      previous: 'a1-u03-l04',
      vocabulary: l5v,
      grammarTopic: grammar(
        'In and on for addresses',
        'In iyo on ee cinwaannada',
        'In waxaa lala isticmaalaa magaalo, degmo iyo dal. On waxaa lala isticmaalaa magaca waddada.',
        'in + city/district/country; on + road/street',
        'I live + in/on + place',
        l5e,
        const [
          'Ha oran in Peace Road; qaabka la bartay waa on Peace Road.',
          'Ha gelin cinwaan dhab ah layliga.',
        ],
      ),
      examples: l5e,
      dialogues: d('l5'),
      exercises: l5x,
      speaking: l5s,
      writing: l5w,
      summary:
          'I live in… waxaa lala isticmaalaa magaalo, degmo ama dal. I live on… waxaa lala isticmaalaa waddo.',
    ),
    lesson(
      id: 'a1-u03-l06',
      number: 6,
      titleEnglish: 'Prices and Money',
      titleSomali: 'Qiimaha iyo lacagta',
      description:
          'Bar sida qiime loo weydiiyo loogana jawaabo dukaan, suuq, makhaayad ama gaadiid.',
      objectives: const [
        'Qiimaha shay weydii.',
        'Qiime ku sheeg dollars ama cents.',
        'Kala saar How much iyo How many hordhac ahaan.',
      ],
      type: 'grammar',
      minutes: 22,
      previous: 'a1-u03-l05',
      vocabulary: l6v,
      grammarTopic: grammar(
        'How much, this, and it',
        'How much, this iyo it',
        'How much is this? wuxuu weydiiyaa qiimaha shay la tilmaamayo. How much does it cost? isla qiimaha ayuu weydiiyaa. How many wuxuu weydiiyaa tiro xabbo.',
        'How much + is + this?; How much + does + it + cost?',
        'It is/costs + price',
        l6e,
        const [
          'Ha oran How many is this? marka qiime la weydiinayo.',
          'It cost ten dollars waxaa A1 present simple sax ahaan loo yiraahdaa It costs ten dollars.',
        ],
      ),
      examples: l6e,
      dialogues: d('l6'),
      exercises: l6x,
      speaking: l6s,
      writing: l6w,
      summary:
          'How much is this? iyo How much does it cost? labaduba qiime ayay weydiiyaan. How many wuxuu weydiiyaa tiro xabbo.',
    ),
    lesson(
      id: 'a1-u03-l07',
      number: 7,
      titleEnglish: 'Dates and Basic Personal Details',
      titleSomali: 'Taariikhaha iyo macluumaadka qofka',
      description:
          'Bar day, month, year, 12-ka bilood iyo labada qaab ee taariikhda.',
      objectives: const [
        'Magacow 12-ka bilood.',
        'Akhri taariikh fudud.',
        'Taariikh tusaale ah ku qor laba qaab.',
      ],
      type: 'vocabulary',
      minutes: 25,
      previous: 'a1-u03-l06',
      vocabulary: l7v,
      examples: l7e,
      dialogues: d('l7'),
      exercises: l7x,
      speaking: l7s,
      writing: l7w,
      summary:
          'Taariikhdu waxay leedahay day, month iyo year. 5 July 2026 iyo July 5, 2026 labaduba waa sax; dalalku qaabka way ku kala duwanaan karaan.',
    ),
    lesson(
      id: 'a1-u03-l08',
      number: 8,
      titleEnglish: 'Forms and Personal Information',
      titleSomali: 'Buuxinta foomamka macluumaadka qofka',
      description:
          'Bar fields-ka foom fudud iyo sida xog male-awaal ah loogu buuxiyo English.',
      objectives: const [
        'Aqoonso fields-ka foomka.',
        'Kala saar first, last iyo full name.',
        'Buuxi sample form adigoon xog dhab ah isticmaalin.',
      ],
      type: 'writing',
      minutes: 24,
      previous: 'a1-u03-l07',
      vocabulary: l8v,
      examples: l8e,
      dialogues: d('l8'),
      exercises: l8x,
      speaking: l8s,
      writing: l8w,
      summary:
          'Foomku wuxuu codsan karaa full name, age, phone, address, nationality, date of birth iyo occupation. Xog male-awaal ah ku tababar.',
    ),
    lesson(
      id: 'a1-u03-l09',
      number: 9,
      titleEnglish: 'Unit Review',
      titleSomali: 'Dib-u-eegista Unit 3',
      description:
          'Dib u eeg numbers 0–100, age, phone, address, prices, dates iyo personal information forms.',
      objectives: const [
        'Isku dar dhammaan xirfadaha Unit 3.',
        'Sax khaladaadka tiro, da’ iyo prepositions.',
        'Buuxi foom iyo wada sheekeysi mixed ah.',
      ],
      type: 'review',
      minutes: 32,
      previous: 'a1-u03-l08',
      vocabulary: l9v,
      examples: l9e,
      dialogues: d('l9'),
      exercises: l9x,
      speaking: l9s,
      writing: l9w,
      summary:
          'Waxaad dib u eegtay tirooyinka, da’da, telefoonka, cinwaanka, qiimaha, taariikhda iyo foomamka. Isticmaal xog tusaale ah si aad ammaan ugu tababarto.',
    ),
  ];

  final quiz = [
    exercise(
      'a1-u03-q01',
      'multipleChoice',
      '13 sidee loo qoraa?',
      ['thirty', 'thirteen', 'three-ten', 'fifty'],
      'thirteen',
      '13 waa thirteen; 30 waa thirty.',
    ),
    exercise(
      'a1-u03-q02',
      'multipleChoice',
      '40 sidee loo qoraa?',
      ['fourty', 'forty', 'fourteen', 'four-zero'],
      'forty',
      'Higgaadda saxda ahi waa forty, ma aha fourty.',
    ),
    exercise(
      'a1-u03-q03',
      'multipleChoice',
      'Tirada “fifty-seven” waa tee?',
      ['75', '47', '57', '67'],
      '57',
      'Fifty waa 50, seven waa 7; wadajir waa 57.',
    ),
    exercise(
      'a1-u03-q04',
      'multipleChoice',
      '86 sidee loo qoraa?',
      ['eighty-six', 'eighteen-six', 'sixty-eight', 'eight-sixteen'],
      'eighty-six',
      '86 waa eighty-six.',
    ),
    exercise(
      'a1-u03-q05',
      'multipleChoice',
      'Kee ayaa ah 100?',
      ['ninety-nine', 'one hundred', 'one thousand', 'ten hundred'],
      'one hundred',
      '100 waa one hundred.',
    ),
    exercise(
      'a1-u03-q06',
      'trueFalse',
      'Twenty-one waxaa lagu qoraa hyphen.',
      ['True', 'False'],
      'True',
      'Tirooyinka isku dhafan 21–99 waxaa caadi ahaan lagu qoraa hyphen.',
    ),
    exercise(
      'a1-u03-q07',
      'fillInTheBlank',
      'I ___ twenty years old.',
      ['have', 'is', 'am', 'are'],
      'am',
      'I waxaa la socda am; da’da laguma dhaho I have twenty years.',
    ),
    exercise(
      'a1-u03-q08',
      'multipleChoice',
      'Sidee da’da qofka loo weydiiyaa?',
      [
        'How many are you?',
        'How old are you?',
        'What age have you?',
        'How much are you?',
      ],
      'How old are you?',
      'How old are you? waa qaabka saxda ah.',
    ),
    exercise(
      'a1-u03-q09',
      'fillInTheBlank',
      'He ___ fifteen years old.',
      ['am', 'are', 'is', 'have'],
      'is',
      'He waxaa la socda is.',
    ),
    exercise(
      'a1-u03-q10',
      'multipleChoice',
      'Kee ayaa khalad ah?',
      [
        'She is eighteen.',
        'I’m twenty.',
        'I have twenty years.',
        'He is fifteen years old.',
      ],
      'I have twenty years.',
      'English-ku da’da wuxuu isticmaalaa verb to be: I am twenty.',
    ),
    exercise(
      'a1-u03-q11',
      'multipleChoice',
      'Lambar telefoon badanaa sidee loo akhriyaa?',
      ['Digit-digit', 'Sida hal tiro weyn', 'Sida taariikh', 'Sida qiime'],
      'Digit-digit',
      'Digit kasta gooni ayaa loo akhriyaa.',
    ),
    exercise(
      'a1-u03-q12',
      'multipleChoice',
      '“Double zero” waa tee?',
      ['20', '00', '02', '200'],
      '00',
      'Double zero waa laba eber oo isku xiga.',
    ),
    exercise(
      'a1-u03-q13',
      'multipleChoice',
      'Maxaad tiraahdaa marka lambar aan la maqal?',
      [
        'How old are you?',
        'Can you repeat that?',
        'How much is it?',
        'Where do you live?',
      ],
      'Can you repeat that?',
      'Can you repeat that? wuxuu codsanayaa ku celin.',
    ),
    exercise(
      'a1-u03-q14',
      'trueFalse',
      'Oh mararka qaar wuxuu matali karaa zero marka phone number la akhrinayo.',
      ['True', 'False'],
      'True',
      'Phone numbers dhexdiisa zero mararka qaar waxaa loo akhriyaa oh.',
    ),
    exercise(
      'a1-u03-q15',
      'fillInTheBlank',
      'I live ___ Mogadishu.',
      ['on', 'in', 'is', 'at road'],
      'in',
      'In waxaa lala isticmaalaa magaalo.',
    ),
    exercise(
      'a1-u03-q16',
      'fillInTheBlank',
      'I live ___ Peace Road.',
      ['in', 'on', 'am', 'to'],
      'on',
      'On waxaa lala isticmaalaa magaca waddada.',
    ),
    exercise(
      'a1-u03-q17',
      'multipleChoice',
      '“District” maxay ka dhigan tahay?',
      ['Dal', 'Degmo', 'Dhisme', 'Qiime'],
      'Degmo',
      'District waa degmo ama qayb maamul.',
    ),
    exercise(
      'a1-u03-q18',
      'multipleChoice',
      'Qiimaha shay sidee loo weydiiyaa?',
      [
        'How many is this?',
        'How much is this?',
        'How old is this?',
        'What date is this?',
      ],
      'How much is this?',
      'How much is this? wuxuu weydiiyaa qiimaha.',
    ),
    exercise(
      'a1-u03-q19',
      'fillInTheBlank',
      'It ___ ten dollars.',
      ['cost', 'costs', 'is cost', 'many'],
      'costs',
      'It waxaa present simple la socda costs.',
    ),
    exercise(
      'a1-u03-q20',
      'multipleChoice',
      'Cheap lidkiisu waa tee?',
      ['total', 'cent', 'expensive', 'price'],
      'expensive',
      'Cheap waa raqiis; expensive waa qaali.',
    ),
    exercise(
      'a1-u03-q21',
      'multipleChoice',
      'Bisha 7-aad waa tee?',
      ['June', 'July', 'August', 'January'],
      'July',
      'July waa bisha toddobaad.',
    ),
    exercise(
      'a1-u03-q22',
      'multipleChoice',
      'Kee ayaa taariikh sax ah?',
      [
        '5 July 2026',
        'July is five 2026',
        '2026 of July five is',
        'Five month year',
      ],
      '5 July 2026',
      'Day + month + year waa qaab sax ah.',
    ),
    exercise(
      'a1-u03-q23',
      'multipleChoice',
      '“Date of birth” maxay ka dhigan tahay?',
      ['Taariikhda maanta', 'Taariikhda dhalashada', 'Da’da', 'Cinwaanka'],
      'Taariikhda dhalashada',
      'Date of birth waa taariikhda qofku dhashay.',
    ),
    exercise(
      'a1-u03-q24',
      'multipleChoice',
      'Foomka “occupation” muxuu rabaa?',
      ['Shaqada', 'Magaalada', 'Telefoonka', 'Da’da'],
      'Shaqada',
      'Occupation waa shaqada qofka.',
    ),
    exercise(
      'a1-u03-q25',
      'multipleChoice',
      'Full name waa…',
      [
        'magaca koowaad oo keliya',
        'magaca dambe oo keliya',
        'magaca oo buuxa',
        'magaca magaalada',
      ],
      'magaca oo buuxa',
      'Full name wuxuu ka kooban yahay magaca qofka oo buuxa.',
    ),
  ];

  final unit = {
    'id': 'a1-u03',
    'levelId': 'A1',
    'unitNumber': 3,
    'titleEnglish': 'Numbers and Personal Information',
    'titleSomali': 'Tirooyinka iyo Macluumaadka Qofka',
    'introductionSomali':
        'Unit-kan wuxuu ku barayaa tirooyinka 0 ilaa 100, da’da, lambarrada telefoonka, cinwaannada, qiimaha, taariikhaha iyo buuxinta foomamka xogta qofka adigoo adeegsanaya xog tusaale ah.',
    'requiredPreviousUnitId': 'a1-u02',
    'lessons': lessons,
    'unitQuiz': quiz,
    'passingScore': 70,
  };
  const encoder = JsonEncoder.withIndent('  ');
  File('assets/content/a1/unit_03.json')
    ..createSync(recursive: true)
    ..writeAsStringSync('${encoder.convert(unit)}\n');
}
