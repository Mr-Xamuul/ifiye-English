import 'dart:convert';
import 'dart:io';

Map<String, dynamic> vocab(
  String text,
  String meaning,
  String type,
  String pronunciation,
  String exampleEnglish,
  String exampleSomali,
  String explanation, [
  String mistake = '',
]) => {
  'englishWord': text,
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

List<Map<String, dynamic>> practices(
  String id,
  List<Map<String, dynamic>> words,
  List<Map<String, String>> examples, {
  required String fillQuestion,
  required String fillAnswer,
  required String arrangeQuestion,
  required String arrangeAnswer,
  required String situationQuestion,
  required List<String> situationOptions,
  required String situationAnswer,
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
        words[0]['somaliMeaning'] as String,
        words[1]['somaliMeaning'] as String,
        words[2]['somaliMeaning'] as String,
        words[3]['somaliMeaning'] as String,
      ],
      words[0]['somaliMeaning'] as String,
      'Macnaha saxda ahi waa “${words[0]['somaliMeaning']}”. Xulashooyinka kale waxay leeyihiin macnayaal kale.',
    ),
    exercise(
      '$id-p02',
      'fillInTheBlank',
      fillQuestion,
      [
        fillAnswer,
        words[1]['englishWord'] as String,
        words[2]['englishWord'] as String,
        words[3]['englishWord'] as String,
      ],
      fillAnswer,
      '“$fillAnswer” ayaa qaabka jumladda iyo xaaladda ku habboon.',
    ),
    exercise(
      '$id-p03',
      'matchWords',
      'Isku aadi “${words[1]['englishWord']}” iyo macnihiisa.',
      [
        words[2]['somaliMeaning'] as String,
        words[1]['somaliMeaning'] as String,
        words[3]['somaliMeaning'] as String,
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
        examples[1]['somali']!,
        examples[2]['somali']!,
        examples[0]['somali']!,
        examples[3]['somali']!,
      ],
      examples[0]['somali']!,
      'Jawaabta saxda ahi waxay gudbinaysaa macnaha jumladda, mana aha turjumaad eray-eray khaldan.',
    ),
    exercise(
      '$id-p06',
      'somaliToEnglish',
      'U beddel English: ${examples[1]['somali']}',
      [
        examples[2]['english']!,
        examples[0]['english']!,
        examples[3]['english']!,
        examples[1]['english']!,
      ],
      examples[1]['english']!,
      'Qaabka dabiiciga ah waa “${examples[1]['english']}”.',
    ),
    exercise(
      '$id-p07',
      'trueFalse',
      'Magacyada dadka waxaa English-ka lagu bilaabaa capital letter.',
      const ['True', 'False'],
      'True',
      'Magac qof waa proper name, sidaas darteed xarafka koowaad waa capital.',
    ),
    exercise(
      '$id-p08',
      'multipleChoice',
      situationQuestion,
      situationOptions,
      situationAnswer,
      '“$situationAnswer” ayaa ku habboon qofka iyo xaaladda lagu sheegay; xulashooyinka kale waxay noqon karaan waqti ama heer rasmi ah oo aan ku habboonayn.',
    ),
    exercise(
      '$id-p09',
      'speakingPrompt',
      speaking,
      const [],
      'Teacher review',
      'Si tartiib ah oo cad u hadal. Isticmaal weedhaha casharka oo eeg qofka aad la hadlayso.',
    ),
    exercise(
      '$id-p10',
      'shortWriting',
      writing,
      const [],
      'Teacher review',
      'Hubi capital letters-ka magacyada, full stop-ka jumladaha iyo question mark-ka su’aalaha.',
    ),
  ];
  if (review) {
    items.addAll([
      exercise(
        '$id-p11',
        'multipleChoice',
        'Dooro qaabka ugu edeb badan ee magac lagu weydiiyo.',
        ['Who are you?', 'What is your name, please?', 'Name?', 'You are who?'],
        'What is your name, please?',
        'Please wuxuu su’aasha ka dhigaa mid edeb leh; qaababka kale way adkaan karaan ama naxwe ahaan way khaldan yihiin.',
      ),
      exercise(
        '$id-p12',
        'fillInTheBlank',
        'This is Amina. ___ is my teacher.',
        ['I', 'You', 'He', 'She'],
        'She',
        'Amina waa qof dumar ah, sidaas darteed pronoun-ka saxda ahi waa she.',
      ),
      exercise(
        '$id-p13',
        'multipleChoice',
        'Weedhee ayaa si wanaagsan wada sheekeysi u soo gabagabaynaysa?',
        [
          'What is your name?',
          'See you soon.',
          'Good morning.',
          'How are you?',
        ],
        'See you soon.',
        'See you soon waxaa la yiraahdaa marka la kala tagayo.',
      ),
      exercise(
        '$id-p14',
        'somaliToEnglish',
        'U beddel English: “Magacaygu waa Sahra.”',
        [
          'Her name is Sahra.',
          'Your name is Sahra.',
          'My name is Sahra.',
          'His name is Sahra.',
        ],
        'My name is Sahra.',
        'My waxaa loo isticmaalaa wax aniga i leeyahay; halkan waa magacayga.',
      ),
      exercise(
        '$id-p15',
        'englishToSomali',
        'Turjun: “It was nice talking to you.”',
        [
          'Waan daalay.',
          'Waan ku farxay inaan kula hadlo.',
          'Magacaa?',
          'Berri ayaan ku arkaa.',
        ],
        'Waan ku farxay inaan kula hadlo.',
        'Weedhan waxaa si edeb leh loo adeegsadaa dhammaadka wada sheekeysiga.',
      ),
    ]);
  }
  return items;
}

Map<String, dynamic> grammar({
  required String titleEnglish,
  required String titleSomali,
  required String explanation,
  required String rule,
  required String structure,
  required List<Map<String, String>> positive,
  required List<Map<String, String>> negative,
  required List<Map<String, String>> questions,
  required List<String> mistakes,
}) => {
  'titleEnglish': titleEnglish,
  'titleSomali': titleSomali,
  'explanationSomali': explanation,
  'rule': rule,
  'sentenceStructure': structure,
  'positiveExamples': positive,
  'negativeExamples': negative,
  'questionExamples': questions,
  'commonMistakesSomali': mistakes,
  'practiceQuestions': const [],
};

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
  'unitId': 'a1-u02',
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
  'quizQuestions': exercises.take(3).toList(),
};

void main() {
  final lesson1Words = [
    vocab(
      'Hello',
      'Salaan',
      'greeting',
      'he-low',
      'Hello, Amina.',
      'Salaan, Aamina.',
      'Hello waa salaam guud oo rasmi iyo caadi labadaba ku habboon.',
    ),
    vocab(
      'Hi',
      'Salaan aan rasmi badnayn',
      'greeting',
      'haay',
      'Hi, Ali!',
      'Salaan, Cali!',
      'Hi waxaa badanaa lala isticmaalaa saaxiib ama qof aad taqaan.',
    ),
    vocab(
      'Good morning',
      'Subax wanaagsan',
      'greeting',
      'guud moor-ning',
      'Good morning, teacher.',
      'Subax wanaagsan, macallin.',
      'Waxaa la isticmaalaa subaxdii.',
    ),
    vocab(
      'Good afternoon',
      'Galab wanaagsan',
      'greeting',
      'guud aaf-ter-nuun',
      'Good afternoon, Mr Ahmed.',
      'Galab wanaagsan, Mudane Axmed.',
      'Waxaa la isticmaalaa duhurka kadib ilaa fiidkii.',
    ),
    vocab(
      'Good evening',
      'Fiid wanaagsan',
      'greeting',
      'guud iiv-ning',
      'Good evening, everyone.',
      'Fiid wanaagsan, dhammaantiin.',
      'Waxaa lagu salaamaa qof fiidkii marka la kulmayo.',
      'Ha u isticmaalin markaad seexanaysid; markaas Good night ayaa sax ah.',
    ),
    vocab(
      'Good night',
      'Habeen wanaagsan',
      'farewell',
      'guud naayt',
      'Good night, Mum.',
      'Habeen wanaagsan, Hooyo.',
      'Waxaa la yiraahdaa marka la kala tagayo habeenkii ama la seexanayo.',
      'Good night ma aha salaanta bilowga fiidka.',
    ),
    vocab(
      'Goodbye',
      'Nabadgelyo',
      'farewell',
      'guud-baay',
      'Goodbye. Have a good day.',
      'Nabadgelyo. Maalin wanaagsan.',
      'Goodbye waa qaab cad oo lagu soo gabagabeeyo kulanka.',
    ),
    vocab(
      'See you later',
      'Goor dambe ayaan is arki doonnaa',
      'farewell phrase',
      'sii yuu ley-ter',
      'See you later at school.',
      'Goor dambe ayaan iskuulka isku arki doonnaa.',
      'Waxaa la yiraahdaa marka la filayo in mar kale la kulmo.',
    ),
  ];
  final lesson1Examples = [
    ex('Hello, how are you?', 'Salaan, sidee tahay?'),
    ex('Good morning, teacher.', 'Subax wanaagsan, macallin.'),
    ex('Good afternoon, Mr Ali.', 'Galab wanaagsan, Mudane Cali.'),
    ex('Good evening, everyone.', 'Fiid wanaagsan, dhammaantiin.'),
    ex(
      'Good night. See you tomorrow.',
      'Habeen wanaagsan. Berri ayaan is arki doonnaa.',
    ),
  ];
  final lesson1Speaking =
      'Salaan saaxiib, macallin iyo qof aad fiidkii la kulantay. Kadib ku dhammee “Goodbye” ama “See you later.”';
  final lesson1Writing =
      'Qor salaanta ku habboon subax, galab iyo fiid, kadib qor laba weedhood oo lagu kala tagayo.';
  final lesson1Exercises = practices(
    'a1-u02-l01',
    lesson1Words,
    lesson1Examples,
    fillQuestion: '___ morning, teacher.',
    fillAnswer: 'Good',
    arrangeQuestion: 'Kala hagaaji: you / See / tomorrow',
    arrangeAnswer: 'See you tomorrow.',
    situationQuestion:
        'Waxaad macallinkaaga la kulantay 8:00 subaxnimo. Maxaad oranaysaa?',
    situationOptions: const [
      'Good night',
      'Good morning',
      'Bye',
      'Good evening',
    ],
    situationAnswer: 'Good morning',
    speaking: lesson1Speaking,
    writing: lesson1Writing,
  );

  final lesson2Words = [
    vocab(
      'My name is…',
      'Magacaygu waa…',
      'introduction phrase',
      'maay neym iz',
      'My name is Hodan.',
      'Magacaygu waa Hodan.',
      'Qaab cad oo magacaaga lagu sheego.',
    ),
    vocab(
      'I am…',
      'Waxaan ahay…',
      'introduction phrase',
      'aay am',
      'I am Bashir.',
      'Waxaan ahay Bashiir.',
      'I am waxaa lagu sheegaa magaca ama xaaladda qofka.',
    ),
    vocab(
      'I’m…',
      'Waxaan ahay…',
      'contraction',
      'aaym',
      'I’m a student.',
      'Waxaan ahay arday.',
      'I’m waa qaabka gaaban ee I am.',
      'Ha qorin Im adigoon apostrophe isticmaalin.',
    ),
    vocab(
      'I am from…',
      'Waxaan ka imid…',
      'phrase',
      'aay am from',
      'I am from Somalia.',
      'Waxaan ka imid Soomaaliya.',
      'Waxaa lagu sheegaa dalka ama meesha aad asal ahaan ka timid.',
    ),
    vocab(
      'I live in…',
      'Waxaan degganahay…',
      'phrase',
      'aay liv in',
      'I live in Nairobi.',
      'Waxaan degganahay Nairobi.',
      'Waxaa lagu sheegaa meesha aad hadda degan tahay.',
    ),
    vocab(
      'Student',
      'Arday',
      'noun',
      'stuu-dent',
      'I am a university student.',
      'Waxaan ahay arday jaamacadeed.',
      'Student waa qof wax barta.',
    ),
    vocab(
      'Nice to meet you',
      'Waan ku faraxsanahay inaan kula kulmo',
      'polite phrase',
      'naays tu miit yuu',
      'Nice to meet you, Asha.',
      'Waan ku faraxsanahay inaan kula kulmo, Caasha.',
      'Waxaa la yiraahdaa marka qof markii ugu horreysay la kulmo.',
    ),
    vocab(
      'Pleased to meet you',
      'Aad ayaan ugu faraxsanahay inaan kula kulmo',
      'formal phrase',
      'pliizd tu miit yuu',
      'Pleased to meet you, sir.',
      'Aad ayaan ugu faraxsanahay inaan kula kulmo, mudane.',
      'Waa qaab ka rasmi badan Nice to meet you.',
    ),
  ];
  final lesson2Examples = [
    ex('My name is Fadumo.', 'Magacaygu waa Faadumo.'),
    ex('I’m a student.', 'Waxaan ahay arday.'),
    ex('I am from Somalia.', 'Waxaan ka imid Soomaaliya.'),
    ex('I live in Hargeisa.', 'Waxaan degganahay Hargeysa.'),
    ex('Nice to meet you.', 'Waan ku faraxsanahay inaan kula kulmo.'),
  ];
  final lesson2Speaking =
      'Isku bar 3 ilaa 5 jumladood: magacaaga, meesha aad ka timid, meesha aad degan tahay iyo shaqadaada ama waxbarashadaada.';
  final lesson2Writing =
      'Qor isbarasho shan jumladood ah oo ku bilaabma “My name is…”.';
  final lesson2Exercises = practices(
    'a1-u02-l02',
    lesson2Words,
    lesson2Examples,
    fillQuestion: 'My name ___ Amina.',
    fillAnswer: 'is',
    arrangeQuestion: 'Kala hagaaji: from / am / Somalia / I',
    arrangeAnswer: 'I am from Somalia.',
    situationQuestion: 'Markaad qof cusub la kulanto, weedhee ku habboon?',
    situationOptions: const [
      'Good night',
      'Nice to meet you',
      'Who are you?',
      'See you yesterday',
    ],
    situationAnswer: 'Nice to meet you',
    speaking: lesson2Speaking,
    writing: lesson2Writing,
  );

  final lesson3Words = [
    vocab(
      'What is your name?',
      'Magacaa?',
      'question',
      'wot iz yor neym',
      'What is your name, please?',
      'Magacaa, fadlan?',
      'Waa su’aasha caadiga ah ee magaca qof lagu weydiiyo.',
    ),
    vocab(
      'What’s your name?',
      'Magacaa?',
      'contraction question',
      'wots yor neym',
      'Hi. What’s your name?',
      'Salaan. Magacaa?',
      'What’s waa qaabka gaaban ee What is.',
    ),
    vocab(
      'May I know your name?',
      'Ma ogaan karaa magacaaga?',
      'formal question',
      'mey aay no yor neym',
      'May I know your name, please?',
      'Ma ogaan karaa magacaaga, fadlan?',
      'Waa qaab rasmi ah oo edeb leh.',
    ),
    vocab(
      'Who are you?',
      'Kumaad tahay?',
      'direct question',
      'huu aar yuu',
      'Who are you?',
      'Kumaad tahay?',
      'Su’aashani mararka qaar way adkaan kartaa; qof cusub si edeb leh magaca u weydii.',
      'Ha u adeegsan xaalad rasmi ah marka What is your name? ka dabacsan yahay.',
    ),
    vocab(
      'Spell',
      'Higgaadi',
      'verb',
      'spel',
      'How do you spell your name?',
      'Sidee baad u higgaadisaa magacaaga?',
      'Spell waa in magaca xaraf-xaraf loo sheego.',
    ),
    vocab(
      'Repeat',
      'Ku celi',
      'verb',
      'ri-piit',
      'Can you repeat your name?',
      'Ma ku celin kartaa magacaaga?',
      'Waxaa la isticmaalaa marka magaca aan si fiican loo maqal.',
    ),
    vocab(
      'Please',
      'Fadlan',
      'polite word',
      'pliiz',
      'Repeat your name, please.',
      'Ku celi magacaaga, fadlan.',
      'Please wuxuu hadalka ka dhigaa mid edeb leh.',
    ),
    vocab(
      'Question mark',
      'Calaamadda su’aasha',
      'punctuation',
      'kwes-jan maark',
      'Put a question mark here.',
      'Halkan dhig calaamadda su’aasha.',
      'Su’aal toos ah waxay ku dhammaataa ?.',
    ),
  ];
  final lesson3Examples = [
    ex('What is your name?', 'Magacaa?'),
    ex('My name is Omar.', 'Magacaygu waa Cumar.'),
    ex('How do you spell Omar?', 'Sidee loo higgaadiyaa Cumar?'),
    ex('O-M-A-R.', 'O-M-A-R.'),
    ex('Can you repeat that, please?', 'Ma ku celin kartaa taas, fadlan?'),
  ];
  final lesson3Speaking =
      'Qof weydii magaciisa si edeb leh, weydii sida loo higgaadiyo, kadib ka codso inuu hal mar ku celiyo.';
  final lesson3Writing =
      'Qor wada sheekeysi afar sadar ah oo laba qof magacyadooda isku weydiinayaan.';
  final lesson3Exercises = practices(
    'a1-u02-l03',
    lesson3Words,
    lesson3Examples,
    fillQuestion: 'What ___ your name?',
    fillAnswer: 'is',
    arrangeQuestion: 'Kala hagaaji: your / spell / do / name / How / you',
    arrangeAnswer: 'How do you spell your name?',
    situationQuestion:
        'Maamulaha ayaad si edeb leh magaciisa u weydiinaysaa. Kee ugu habboon?',
    situationOptions: const [
      'Who are you?',
      'May I know your name, please?',
      'Name?',
      'Tell name.',
    ],
    situationAnswer: 'May I know your name, please?',
    speaking: lesson3Speaking,
    writing: lesson3Writing,
  );

  final lesson4Words = [
    vocab(
      'How are you?',
      'Sidee tahay?',
      'question',
      'haw aar yuu',
      'Hello. How are you?',
      'Salaan. Sidee tahay?',
      'Su’aal guud oo xaaladda qof lagu weydiiyo.',
    ),
    vocab(
      'How are you doing?',
      'Sidee wax kuu yihiin?',
      'friendly question',
      'haw aar yuu duu-ing',
      'Hi, how are you doing?',
      'Salaan, sidee wax kuu yihiin?',
      'Waa qaab saaxiibtinimo.',
    ),
    vocab(
      'How is everything?',
      'Sidee wax walba yihiin?',
      'friendly question',
      'haw iz ev-ri-thing',
      'How is everything at work?',
      'Sidee wax walba uga yihiin shaqada?',
      'Waxaa lagu weydiiyaa xaaladda guud.',
    ),
    vocab(
      'Are you okay?',
      'Ma fiican tahay?',
      'question',
      'aar yuu o-key',
      'You look tired. Are you okay?',
      'Waxaad u muuqataa daallan. Ma fiican tahay?',
      'Waxaa la weydiiyaa marka qof laga walaaco.',
    ),
    vocab(
      'I am fine',
      'Waan fiicanahay',
      'formal response',
      'aay am faayn',
      'I am fine, thank you.',
      'Waan fiicanahay, mahadsanid.',
      'Waa jawaab caadi ah oo rasmi iyo guud ah.',
    ),
    vocab(
      'Not bad',
      'Ma xuma',
      'informal response',
      'not bad',
      'Not bad, thanks.',
      'Ma xuma, mahadsanid.',
      'Waa jawaab saaxiibtinimo oo aan rasmi badnayn.',
    ),
    vocab(
      'I am tired',
      'Waan daalay',
      'response',
      'aay am taayrd',
      'I am tired after work.',
      'Waan daalay shaqada kadib.',
      'Waxaa lagu sheegaa daal.',
    ),
    vocab(
      'I am not feeling well',
      'Caafimaadkaygu ma fiicna',
      'response',
      'aay am not fii-ling wel',
      'I am not feeling well today.',
      'Maanta caafimaadkaygu ma fiicna.',
      'Waxaa lagu sheegaa in qofku xanuunsan yahay ama aanu fiicnayn.',
    ),
  ];
  final lesson4Examples = [
    ex('How are you today?', 'Sidee tahay maanta?'),
    ex('I am very well, thank you.', 'Aad ayaan u fiicanahay, mahadsanid.'),
    ex('How is everything?', 'Sidee wax walba yihiin?'),
    ex('Not bad. And you?', 'Ma xuma. Adiguna?'),
    ex('I am tired today.', 'Maanta waan daalay.'),
  ];
  final lesson4Speaking =
      'Salaan qof, weydii xaaladdiisa, kadib ku jawaab saddex qaab: fine, not bad iyo tired.';
  final lesson4Writing =
      'Qor wada sheekeysi gaaban oo qof xaaladdiisa la weydiinayo, kana jawaabayo.';
  final lesson4Exercises = practices(
    'a1-u02-l04',
    lesson4Words,
    lesson4Examples,
    fillQuestion: 'How ___ you?',
    fillAnswer: 'are',
    arrangeQuestion: 'Kala hagaaji: fine / am / I / thank you',
    arrangeAnswer: 'I am fine, thank you.',
    situationQuestion:
        'Saaxiibkaa wuxuu u muuqdaa daallan. Maxaad weydiinaysaa?',
    situationOptions: const [
      'What is your name?',
      'Are you okay?',
      'Good night?',
      'Who are you?',
    ],
    situationAnswer: 'Are you okay?',
    speaking: lesson4Speaking,
    writing: lesson4Writing,
  );

  final lesson5Words = [
    vocab(
      'This is my friend',
      'Kani waa saaxiibkay',
      'introduction phrase',
      'dhis iz maay frend',
      'This is my friend, Ali.',
      'Kani waa saaxiibkay, Cali.',
      'This is waxaa lagu bilaabaa marka qof la barayo.',
    ),
    vocab(
      'Meet my teacher',
      'La kulan macallinkayga',
      'introduction phrase',
      'miit maay tii-jar',
      'Meet my teacher, Ms Asha.',
      'La kulan macallinkayga, Marwo Caasha.',
      'Meet waxaa halkan loo isticmaalaa isbarasho.',
    ),
    vocab(
      'Let me introduce you to…',
      'Aan ku baro…',
      'formal phrase',
      'let mii in-tro-dyuus yuu tu',
      'Let me introduce you to Ahmed.',
      'Aan ku baro Axmed.',
      'Waa qaab edeb leh oo laba qof la isku baro.',
    ),
    vocab(
      'He is…',
      'Isagu waa…',
      'pronoun phrase',
      'hii iz',
      'He is my brother.',
      'Isagu waa walaalkay.',
      'He waxaa loo isticmaalaa qof lab ah.',
    ),
    vocab(
      'She is…',
      'Iyadu waa…',
      'pronoun phrase',
      'shii iz',
      'She is my teacher.',
      'Iyadu waa macallinkayga.',
      'She waxaa loo isticmaalaa qof dumar ah.',
    ),
    vocab(
      'His name is…',
      'Magaciisu waa…',
      'possessive phrase',
      'hiz neym iz',
      'His name is Hassan.',
      'Magaciisu waa Xasan.',
      'His wuxuu tilmaamayaa wax uu leeyahay qof lab ah.',
    ),
    vocab(
      'Her name is…',
      'Magaceedu waa…',
      'possessive phrase',
      'her neym iz',
      'Her name is Maryan.',
      'Magaceedu waa Maryan.',
      'Her wuxuu tilmaamayaa wax ay leedahay qof dumar ah.',
    ),
    vocab(
      'Your',
      'Kaaga/taada',
      'possessive adjective',
      'yor',
      'What is your name?',
      'Magacaa?',
      'Your waxaa lala isticmaalaa qofka lala hadlayo.',
    ),
  ];
  final lesson5Examples = [
    ex('This is my friend, Abdi.', 'Kani waa saaxiibkay, Cabdi.'),
    ex('He is a student.', 'Isagu waa arday.'),
    ex('She is my teacher.', 'Iyadu waa macallinkayga.'),
    ex('His name is Yusuf.', 'Magaciisu waa Yuusuf.'),
    ex('Her name is Hani.', 'Magaceedu waa Hani.'),
  ];
  final lesson5Speaking =
      'Qof kale saaxiibkaa bar. Isticmaal This is…, He/She is… iyo His/Her name is….';
  final lesson5Writing =
      'Qor shan jumladood oo aad ku barayso laba qof: hal nin iyo hal haweeney.';
  final lesson5Exercises = practices(
    'a1-u02-l05',
    lesson5Words,
    lesson5Examples,
    fillQuestion: 'Amina is my teacher. ___ is kind.',
    fillAnswer: 'She',
    arrangeQuestion: 'Kala hagaaji: friend / is / my / This',
    arrangeAnswer: 'This is my friend.',
    situationQuestion: 'Waxaad baraysaa walaalkaa Xasan. Weedhee sax ah?',
    situationOptions: const [
      'She is Hassan.',
      'This is my brother, Hassan.',
      'Her name is Hassan.',
      'I am Hassan brother.',
    ],
    situationAnswer: 'This is my brother, Hassan.',
    speaking: lesson5Speaking,
    writing: lesson5Writing,
  );

  final lesson6Words = [
    vocab(
      'Formal',
      'Rasmi',
      'adjective',
      'for-mal',
      'Good morning is a formal greeting.',
      'Good morning waa salaam rasmi ah.',
      'Formal language waxaa lala isticmaalaa xaalad shaqo ama qof aan si dhow loo aqoon.',
    ),
    vocab(
      'Informal',
      'Aan rasmi ahayn/caadi',
      'adjective',
      'in-for-mal',
      'Hi is an informal greeting.',
      'Hi waa salaam caadi ah.',
      'Informal language waxaa lala isticmaalaa saaxiib iyo qof aad taqaan.',
    ),
    vocab(
      'Hey',
      'Haye/salaan aad u caadi ah',
      'greeting',
      'hey',
      'Hey, Ahmed!',
      'Haye, Axmed!',
      'Hey aad buu u informal yahay.',
      'Ha kula bilaabin maamule ama macmiil aadan aqoon.',
    ),
    vocab(
      'Sir',
      'Mudane',
      'formal address',
      'ser',
      'Good morning, sir.',
      'Subax wanaagsan, mudane.',
      'Sir waa eray xushmad leh oo nin lala hadlo.',
    ),
    vocab(
      'Madam',
      'Marwo',
      'formal address',
      'ma-dam',
      'Good afternoon, madam.',
      'Galab wanaagsan, marwo.',
      'Madam waa eray rasmi ah oo haweeney lala hadlo.',
    ),
    vocab(
      'Customer',
      'Macmiil',
      'noun',
      'kas-ta-mer',
      'Welcome, dear customer.',
      'Soo dhowow, macmiil qiimo leh.',
      'Customer waa qof wax ka iibsanaya ganacsi.',
    ),
    vocab(
      'Manager',
      'Maamule',
      'noun',
      'ma-ni-jer',
      'Good morning, manager.',
      'Subax wanaagsan, maamule.',
      'Manager waa qof shaqo ama koox maamula.',
    ),
    vocab(
      'Pleased to meet you',
      'Aad ayaan ugu faraxsanahay inaan kula kulmo',
      'formal phrase',
      'pliizd tu miit yuu',
      'Pleased to meet you, Madam.',
      'Aad ayaan ugu faraxsanahay inaan kula kulmo, Marwo.',
      'Waxaa ku habboon kulanka rasmiga ah ee ugu horreeya.',
    ),
  ];
  final lesson6Examples = [
    ex('Hi, my friend!', 'Salaan, saaxiibkay!'),
    ex('Good morning, teacher.', 'Subax wanaagsan, macallin.'),
    ex('Hello, Mr Hassan.', 'Salaan, Mudane Xasan.'),
    ex(
      'Pleased to meet you, Madam.',
      'Aad ayaan ugu faraxsanahay inaan kula kulmo, Marwo.',
    ),
    ex('Hey, Ali!', 'Haye, Cali!'),
  ];
  final lesson6Speaking =
      'Salaan saaxiib si informal ah, kadib salaam macallin, maamule iyo macmiil si formal ah.';
  final lesson6Writing =
      'Samee laba liis: afar salaamood oo formal ah iyo afar salaamood oo informal ah.';
  final lesson6Exercises = practices(
    'a1-u02-l06',
    lesson6Words,
    lesson6Examples,
    fillQuestion: 'Good morning, ___.',
    fillAnswer: 'sir',
    arrangeQuestion: 'Kala hagaaji: meet / Pleased / you / to',
    arrangeAnswer: 'Pleased to meet you.',
    situationQuestion:
        'Waxaad markii ugu horreysay la kulantay maamule. Maxaad oranaysaa?',
    situationOptions: const [
      'Hey!',
      'Pleased to meet you.',
      'Bye, friend!',
      'What’s up?',
    ],
    situationAnswer: 'Pleased to meet you.',
    speaking: lesson6Speaking,
    writing: lesson6Writing,
  );

  final lesson7Words = [
    vocab(
      'Excuse me',
      'Iga raalli ahow',
      'polite opener',
      'ik-skyuus mii',
      'Excuse me, can I talk to you?',
      'Iga raalli ahow, ma kula hadli karaa?',
      'Waxaa lagu bilaabaa hadal marka qof dareenkiisa la doonayo.',
    ),
    vocab(
      'Can I talk to you?',
      'Ma kula hadli karaa?',
      'question',
      'kan aay took tu yuu',
      'Can I talk to you for a minute?',
      'Ma kula hadli karaa hal daqiiqo?',
      'Waa qaab edeb leh oo wada hadal lagu bilaabo.',
    ),
    vocab(
      'How are you today?',
      'Sidee tahay maanta?',
      'question',
      'haw aar yuu tu-dey',
      'Hello. How are you today?',
      'Salaan. Sidee tahay maanta?',
      'Waxaa lagu sii wadaa salaanta kadib.',
    ),
    vocab(
      'It was nice talking to you',
      'Waan ku farxay inaan kula hadlo',
      'closing phrase',
      'it woz naays too-king tu yuu',
      'It was nice talking to you.',
      'Waan ku farxay inaan kula hadlo.',
      'Waxaa lagu soo gabagabeeyaa wada sheekeysi si edeb leh.',
    ),
    vocab(
      'See you soon',
      'Dhowaan ayaan is arki doonnaa',
      'farewell',
      'sii yuu suun',
      'See you soon, Asha.',
      'Dhowaan ayaan is arki doonnaa, Caasha.',
      'Waxaa la yiraahdaa marka kulanka xiga la filayo.',
    ),
    vocab(
      'Have a good day',
      'Maalin wanaagsan',
      'farewell wish',
      'hav a guud dey',
      'Goodbye. Have a good day.',
      'Nabadgelyo. Maalin wanaagsan.',
      'Waa duco gaaban oo lagu kala tago.',
    ),
    vocab(
      'Take care',
      'Is ilaali',
      'farewell',
      'teyk ker',
      'Take care. See you soon.',
      'Is ilaali. Dhowaan ayaan is arki doonnaa.',
      'Waa qaab diirran oo lagu kala tago.',
    ),
    vocab(
      'Goodbye',
      'Nabadgelyo',
      'farewell',
      'guud-baay',
      'Goodbye, everyone.',
      'Nabadgelyo, dhammaantiin.',
      'Waa weedh lagu dhammeeyo kulanka.',
    ),
  ];
  final lesson7Examples = [
    ex(
      'Excuse me, can I talk to you?',
      'Iga raalli ahow, ma kula hadli karaa?',
    ),
    ex('Hello. How are you today?', 'Salaan. Sidee tahay maanta?'),
    ex('It was nice talking to you.', 'Waan ku farxay inaan kula hadlo.'),
    ex('Have a good day.', 'Maalin wanaagsan.'),
    ex('Take care. Goodbye.', 'Is ilaali. Nabadgelyo.'),
  ];
  final lesson7Speaking =
      'Bilow wada sheekeysi adigoo leh Excuse me, weydii xaaladda qofka, kadib si edeb leh u soo gabagabee.';
  final lesson7Writing =
      'Qor wada sheekeysi lix sadar ah oo leh bilow, salaam, su’aal iyo dhammaad.';
  final lesson7Exercises = practices(
    'a1-u02-l07',
    lesson7Words,
    lesson7Examples,
    fillQuestion: 'Have a good ___.',
    fillAnswer: 'day',
    arrangeQuestion: 'Kala hagaaji: nice / talking / was / you / It / to',
    arrangeAnswer: 'It was nice talking to you.',
    situationQuestion:
        'Waxaad rabtaa inaad si edeb leh hadal u bilowdo. Kee sax ah?',
    situationOptions: const [
      'Goodbye.',
      'Excuse me.',
      'Take care.',
      'Good night.',
    ],
    situationAnswer: 'Excuse me.',
    speaking: lesson7Speaking,
    writing: lesson7Writing,
  );

  final lesson8Words = [
    vocab(
      'Greeting',
      'Salaan',
      'noun',
      'grii-ting',
      'Choose the right greeting.',
      'Dooro salaanta saxda ah.',
      'Greeting waa weedh lagu bilaabo kulan.',
    ),
    vocab(
      'Introduction',
      'Isbarasho',
      'noun',
      'in-tro-dak-shan',
      'Give a short introduction.',
      'Samee isbarasho gaaban.',
      'Introduction waa marka aad sheegto qofka aad tahay ama qof kale barato.',
    ),
    vocab(
      'Formal',
      'Rasmi',
      'adjective',
      'for-mal',
      'Use formal English with a customer.',
      'Macmiil kula hadal English rasmi ah.',
      'Formal waa hadal xushmad iyo nidaam leh.',
    ),
    vocab(
      'Informal',
      'Caadi/aan rasmi ahayn',
      'adjective',
      'in-for-mal',
      'Hi is informal.',
      'Hi waa salaam caadi ah.',
      'Informal waxaa lala isticmaalaa dad aad taqaan.',
    ),
    vocab(
      'Introduce',
      'Isbar ama qof kale bar',
      'verb',
      'in-tro-dyuus',
      'Let me introduce my friend.',
      'Aan kuu baro saaxiibkay.',
      'Introduce waa isbarid ama laba qof isku barid.',
    ),
    vocab(
      'Pronoun',
      'Magac-u-yaal',
      'noun',
      'pro-nawn',
      'He is a subject pronoun.',
      'He waa magac-u-yaal subject ah.',
      'I, you, he iyo she waxay beddelaan magaca qofka.',
    ),
    vocab(
      'Possessive',
      'Lahaansho muujinaya',
      'adjective',
      'po-ze-siv',
      'My shows possession.',
      'My wuxuu muujinayaa lahaansho.',
      'My, your, his iyo her waxay sheegaan cidda wax leh.',
    ),
    vocab(
      'Conversation',
      'Wada sheekeysi',
      'noun',
      'kon-ver-sey-shan',
      'End the conversation politely.',
      'Wada sheekeysiga si edeb leh u dhammee.',
      'Conversation waa hadal ay laba qof ama ka badan wadaagaan.',
    ),
  ];
  final lesson8Examples = [
    ex('Good morning. My name is Ali.', 'Subax wanaagsan. Magacaygu waa Cali.'),
    ex('What is your name, please?', 'Magacaa, fadlan?'),
    ex('I am fine, thank you.', 'Waan fiicanahay, mahadsanid.'),
    ex(
      'This is my friend. Her name is Hawa.',
      'Tani waa saaxiibadday. Magaceedu waa Xaawo.',
    ),
    ex(
      'It was nice talking to you. Goodbye.',
      'Waan ku farxay inaan kula hadlo. Nabadgelyo.',
    ),
  ];
  final lesson8Speaking =
      'Samee wada sheekeysi dhammeystiran: salaam, isbaro, magaca weydii, xaaladda weydii, qof kale bar, kadib soo gabagabee.';
  final lesson8Writing =
      'Qor wada sheekeysi siddeed sadar ah oo laba qof markii ugu horreysay kulmayaan.';
  final lesson8Exercises = practices(
    'a1-u02-l08',
    lesson8Words,
    lesson8Examples,
    fillQuestion: 'Her name ___ Hawa.',
    fillAnswer: 'is',
    arrangeQuestion: 'Kala hagaaji: name / your / is / What',
    arrangeAnswer: 'What is your name?',
    situationQuestion:
        'Macmiil cusub ayaad subaxdii la kulantay. Kee ku habboon?',
    situationOptions: const [
      'Hey!',
      'Good morning. Pleased to meet you.',
      'Good night.',
      'Bye!',
    ],
    situationAnswer: 'Good morning. Pleased to meet you.',
    speaking: lesson8Speaking,
    writing: lesson8Writing,
    review: true,
  );

  final commonDialogues = <String, List<Map<String, dynamic>>>{
    'l01': [
      dialogue('Laba arday oo subaxdii kulmaya', [
        line('Amina', 'Good morning, Ali.', 'Subax wanaagsan, Cali.'),
        line(
          'Ali',
          'Good morning, Amina. How are you?',
          'Subax wanaagsan, Aamina. Sidee tahay?',
        ),
        line('Amina', 'I am fine, thank you.', 'Waan fiicanahay, mahadsanid.'),
        line('Ali', 'See you later.', 'Goor dambe ayaan is arki doonnaa.'),
      ]),
      dialogue('Shaqaale fiidkii kala tagaya', [
        line('Hassan', 'Good evening, Maryan.', 'Fiid wanaagsan, Maryan.'),
        line('Maryan', 'Good evening, Hassan.', 'Fiid wanaagsan, Xasan.'),
        line(
          'Hassan',
          'Good night. See you tomorrow.',
          'Habeen wanaagsan. Berri ayaan is arki doonnaa.',
        ),
        line('Maryan', 'Good night.', 'Habeen wanaagsan.'),
      ]),
    ],
    'l02': [
      dialogue('Laba qof oo isbaranaya', [
        line(
          'Sahra',
          'Hello. My name is Sahra.',
          'Salaan. Magacaygu waa Sahra.',
        ),
        line(
          'Omar',
          'Hi, Sahra. I’m Omar.',
          'Salaan, Sahra. Waxaan ahay Cumar.',
        ),
        line(
          'Sahra',
          'Nice to meet you.',
          'Waan ku faraxsanahay inaan kula kulmo.',
        ),
        line(
          'Omar',
          'Nice to meet you too.',
          'Aniguna waan ku faraxsanahay inaan kula kulmo.',
        ),
      ]),
      dialogue('Laba shaqaale oo cusub', [
        line(
          'Abdi',
          'I am Abdi. I work as a driver.',
          'Waxaan ahay Cabdi. Waxaan u shaqeeyaa darawal.',
        ),
        line(
          'Hodan',
          'I’m Hodan. I work in the office.',
          'Waxaan ahay Hodan. Waxaan ka shaqeeyaa xafiiska.',
        ),
        line(
          'Abdi',
          'Pleased to meet you.',
          'Aad ayaan ugu faraxsanahay inaan kula kulmo.',
        ),
        line(
          'Hodan',
          'Pleased to meet you too.',
          'Aniguna aad ayaan ugu faraxsanahay inaan kula kulmo.',
        ),
      ]),
    ],
    'l03': [
      dialogue('Magaca ardayga', [
        line('Teacher', 'What is your name, please?', 'Magacaa, fadlan?'),
        line('Student', 'My name is Ilyas.', 'Magacaygu waa Ilyaas.'),
        line(
          'Teacher',
          'How do you spell Ilyas?',
          'Sidee loo higgaadiyaa Ilyaas?',
        ),
        line('Student', 'I-L-Y-A-S.', 'I-L-Y-A-S.'),
      ]),
      dialogue('Telefoonka', [
        line('Caller', 'May I know your name?', 'Ma ogaan karaa magacaaga?'),
        line('Asha', 'My name is Asha.', 'Magacaygu waa Caasha.'),
        line(
          'Caller',
          'Can you repeat your name, please?',
          'Ma ku celin kartaa magacaaga, fadlan?',
        ),
        line('Asha', 'Asha. A-S-H-A.', 'Caasha. A-S-H-A.'),
      ]),
    ],
    'l04': [
      dialogue('Laba saaxiib', [
        line('Ali', 'Hi, how are you doing?', 'Salaan, sidee wax kuu yihiin?'),
        line('Yusuf', 'Not bad. And you?', 'Ma xuma. Adiguna?'),
        line('Ali', 'I am good, thanks.', 'Waan fiicanahay, mahadsanid.'),
        line('Yusuf', 'That is good.', 'Taasi waa fiican tahay.'),
      ]),
      dialogue('Arday iyo macallin', [
        line('Teacher', 'How are you today?', 'Sidee tahay maanta?'),
        line('Student', 'I am not feeling well.', 'Caafimaadkaygu ma fiicna.'),
        line('Teacher', 'Are you okay?', 'Ma fiican tahay?'),
        line('Student', 'I am tired.', 'Waan daalay.'),
      ]),
    ],
    'l05': [
      dialogue('Saaxiib la barayo', [
        line(
          'Amina',
          'Ali, this is my friend Hawa.',
          'Cali, tani waa saaxiibadday Xaawo.',
        ),
        line('Ali', 'Hello, Hawa.', 'Salaan, Xaawo.'),
        line(
          'Hawa',
          'Hello. Nice to meet you.',
          'Salaan. Waan ku faraxsanahay inaan kula kulmo.',
        ),
        line(
          'Ali',
          'Nice to meet you too.',
          'Aniguna waan ku faraxsanahay inaan kula kulmo.',
        ),
      ]),
      dialogue('Macallin la barayo', [
        line(
          'Omar',
          'Let me introduce you to my teacher.',
          'Aan ku baro macallinkayga.',
        ),
        line('Omar', 'Her name is Ms Maryan.', 'Magaceedu waa Marwo Maryan.'),
        line(
          'Asha',
          'Pleased to meet you, Ms Maryan.',
          'Aad ayaan ugu faraxsanahay inaan kula kulmo, Marwo Maryan.',
        ),
        line(
          'Teacher',
          'Pleased to meet you too.',
          'Aniguna aad ayaan ugu faraxsanahay inaan kula kulmo.',
        ),
      ]),
    ],
    'l06': [
      dialogue('Macmiil iyo shaqaale', [
        line('Employee', 'Good morning, sir.', 'Subax wanaagsan, mudane.'),
        line('Customer', 'Good morning.', 'Subax wanaagsan.'),
        line('Employee', 'How can I help you?', 'Sideen kuu caawin karaa?'),
        line('Customer', 'Thank you.', 'Mahadsanid.'),
      ]),
      dialogue('Laba saaxiib', [
        line('Ali', 'Hey, Yusuf!', 'Haye, Yuusuf!'),
        line('Yusuf', 'Hi, Ali!', 'Salaan, Cali!'),
        line('Ali', 'How are you?', 'Sidee tahay?'),
        line('Yusuf', 'I’m good.', 'Waan fiicanahay.'),
      ]),
    ],
    'l07': [
      dialogue('Wada hadal shaqo', [
        line(
          'Asha',
          'Excuse me. Can I talk to you?',
          'Iga raalli ahow. Ma kula hadli karaa?',
        ),
        line('Manager', 'Yes, of course.', 'Haa, dabcan.'),
        line('Asha', 'Thank you.', 'Mahadsanid.'),
        line('Manager', 'You are welcome.', 'Adigaa mudan.'),
      ]),
      dialogue('Wada sheekeysi la dhammeeyo', [
        line(
          'Abdi',
          'It was nice talking to you.',
          'Waan ku farxay inaan kula hadlo.',
        ),
        line(
          'Hodan',
          'It was nice talking to you too.',
          'Aniguna waan ku farxay inaan kula hadlo.',
        ),
        line('Abdi', 'Have a good day.', 'Maalin wanaagsan.'),
        line('Hodan', 'Take care. Goodbye.', 'Is ilaali. Nabadgelyo.'),
      ]),
    ],
    'l08': [
      dialogue('Dib-u-eegis: laba arday', [
        line(
          'Ali',
          'Good morning. My name is Ali.',
          'Subax wanaagsan. Magacaygu waa Cali.',
        ),
        line(
          'Hawa',
          'I’m Hawa. Nice to meet you.',
          'Waxaan ahay Xaawo. Waan ku faraxsanahay inaan kula kulmo.',
        ),
        line('Ali', 'How are you today?', 'Sidee tahay maanta?'),
        line('Hawa', 'I am fine, thank you.', 'Waan fiicanahay, mahadsanid.'),
      ]),
      dialogue('Dib-u-eegis: kala tagid', [
        line(
          'Hawa',
          'This is my friend, Amina.',
          'Tani waa saaxiibadday, Aamina.',
        ),
        line(
          'Amina',
          'Hello. Pleased to meet you.',
          'Salaan. Aad ayaan ugu faraxsanahay inaan kula kulmo.',
        ),
        line(
          'Ali',
          'Pleased to meet you too.',
          'Aniguna aad ayaan ugu faraxsanahay inaan kula kulmo.',
        ),
        line(
          'Amina',
          'See you soon. Goodbye.',
          'Dhowaan ayaan is arki doonnaa. Nabadgelyo.',
        ),
      ]),
    ],
  };

  final lessons = [
    lesson(
      id: 'a1-u02-l01',
      number: 1,
      titleEnglish: 'Basic Greetings',
      titleSomali: 'Salaamaha aasaasiga ah',
      description:
          'Bar salaamaha lagu bilaabo laguna dhammeeyo kulan, iyo farqiga Good evening iyo Good night.',
      objectives: const [
        'Isticmaal ugu yaraan shan salaamood oo sax ah.',
        'Kala saar Good evening iyo Good night.',
        'Dooro salaanta ku habboon waqtiga maalinta.',
      ],
      type: 'vocabulary',
      minutes: 18,
      previous: null,
      vocabulary: lesson1Words,
      examples: lesson1Examples,
      dialogues: commonDialogues['l01']!,
      exercises: lesson1Exercises,
      speaking: lesson1Speaking,
      writing: lesson1Writing,
      summary:
          'Waxaad baratay salaamaha subax, galab iyo fiid. Good evening waxaa lagu bilaabaa kulan fiidkii; Good night waxaa lagu kala tagaa ama la yiraahdaa marka la seexanayo.',
    ),
    lesson(
      id: 'a1-u02-l02',
      number: 2,
      titleEnglish: 'Introducing Yourself',
      titleSomali: 'Sida aad isu barayso',
      description:
          'Bar sida magacaaga, meesha aad ka timid, meesha aad degan tahay iyo shaqadaada si fudud loo sheego.',
      objectives: const [
        'Isku bar ugu yaraan afar jumladood.',
        'Isticmaal I am iyo I’m si sax ah.',
        'Ku dhammee isbarashada Nice to meet you.',
      ],
      type: 'grammar',
      minutes: 20,
      previous: 'a1-u02-l01',
      vocabulary: lesson2Words,
      grammarTopic: grammar(
        titleEnglish: 'I am and I’m',
        titleSomali: 'I am iyo qaabka gaaban I’m',
        explanation:
            'I am waxaa loo isticmaalaa marka aad naftaada ka hadlayso. I’m waa isla macnahaas oo la soo gaabiyay.',
        rule: 'I + am; I am = I’m',
        structure: 'I am/I’m + name, job, or description',
        positive: lesson2Examples,
        negative: [
          ex('I am not a teacher.', 'Macallin ma ihi.'),
          ex('I’m not from Kenya.', 'Kama imanin Kenya.'),
        ],
        questions: [
          ex('Are you a student?', 'Ma arday baad tahay?'),
          ex('Are you from Somalia?', 'Ma Soomaaliya ayaad ka timid?'),
        ],
        mistakes: const [
          'Ha oran I is; waxaa sax ah I am.',
          'I’m waxaa ku jira apostrophe.',
        ],
      ),
      examples: lesson2Examples,
      dialogues: commonDialogues['l02']!,
      exercises: lesson2Exercises,
      speaking: lesson2Speaking,
      writing: lesson2Writing,
      summary:
          'Waxaad hadda magacaaga iyo xog kooban ku sheegi kartaa My name is…, I am… ama I’m…. Nice to meet you waxaa lagu yiraahdaa qof cusub.',
    ),
    lesson(
      id: 'a1-u02-l03',
      number: 3,
      titleEnglish: 'Asking Someone’s Name',
      titleSomali: 'Sida magaca qof loo weydiiyo',
      description:
          'Bar su’aalaha magaca, higgaadinta iyo ku celinta, adigoo isticmaalaya qaab edeb leh.',
      objectives: const [
        'Magaca qof si edeb leh u weydii.',
        'Weydii sida magaca loo higgaadiyo.',
        'Isticmaal question mark dhammaadka su’aasha.',
      ],
      type: 'grammar',
      minutes: 20,
      previous: 'a1-u02-l02',
      vocabulary: lesson3Words,
      grammarTopic: grammar(
        titleEnglish: 'Basic name questions',
        titleSomali: 'Qaabka su’aalaha magaca',
        explanation:
            'Su’aasha magaca badanaa waxay ku bilaabataa What ama How, waxayna ku dhammaataa question mark.',
        rule: 'Question word + is/do/can + subject + …?',
        structure: 'What + is + your name?',
        positive: lesson3Examples,
        negative: [
          ex('Your name what.', 'Qaabkani waa khalad.'),
          ex('What your name.', 'Is ayaa ka maqan.'),
        ],
        questions: lesson3Examples,
        mistakes: const [
          'Ha ka tagin is: What is your name?',
          'Who are you? mararka qaar waxay u muuqan kartaa mid adag.',
        ],
      ),
      examples: lesson3Examples,
      dialogues: commonDialogues['l03']!,
      exercises: lesson3Exercises,
      speaking: lesson3Speaking,
      writing: lesson3Writing,
      summary:
          'What is your name? waa su’aasha ugu caansan. May I know your name? waa rasmi. Who are you? si taxaddar leh u isticmaal.',
    ),
    lesson(
      id: 'a1-u02-l04',
      number: 4,
      titleEnglish: 'Asking How Someone Is',
      titleSomali: 'Sida xaaladda qof loo weydiiyo',
      description:
          'Bar sida xaaladda qof loo weydiiyo iyo jawaabaha rasmi ah ama saaxiibtinimo.',
      objectives: const [
        'Isticmaal saddex su’aalood oo xaalad lagu weydiiyo.',
        'Bixi ugu yaraan afar jawaabood oo kala duwan.',
        'Kala saar jawaab rasmi ah iyo mid saaxiibtinimo.',
      ],
      type: 'speaking',
      minutes: 19,
      previous: 'a1-u02-l03',
      vocabulary: lesson4Words,
      grammarTopic: grammar(
        titleEnglish: 'Am, is, and are',
        titleSomali: 'Am, is iyo are',
        explanation:
            'Am waxaa lala isticmaalaa I; is waxaa lala isticmaalaa he, she ama it; are waxaa lala isticmaalaa you.',
        rule: 'I am; he/she is; you are',
        structure: 'How + are + you?',
        positive: lesson4Examples,
        negative: [
          ex('I am not well.', 'Ma fiicni.'),
          ex('She is not okay.', 'Iyadu ma fiicna.'),
        ],
        questions: [
          ex('How are you?', 'Sidee tahay?'),
          ex('Is she okay?', 'Iyadu ma fiican tahay?'),
        ],
        mistakes: const [
          'Ha oran How is you; waxaa sax ah How are you?',
          'Ha oran I is fine; waxaa sax ah I am fine.',
        ],
      ),
      examples: lesson4Examples,
      dialogues: commonDialogues['l04']!,
      exercises: lesson4Exercises,
      speaking: lesson4Speaking,
      writing: lesson4Writing,
      summary:
          'How are you? waa su’aal guud. I am fine waa jawaab caadi ah; Not bad waa informal; I am not feeling well waxay sheegaysaa caafimaad xumo.',
    ),
    lesson(
      id: 'a1-u02-l05',
      number: 5,
      titleEnglish: 'Introducing Other People',
      titleSomali: 'Sida dad kale la isu baro',
      description:
          'Bar sida saaxiib, qaraabo ama macallin qof kale loogu baro adigoo isticmaalaya I, you, he, she, my, your, his iyo her.',
      objectives: const [
        'Qof kale ku bar This is….',
        'He iyo she si sax ah u kala isticmaal.',
        'My, your, his iyo her ku muuji lahaansho.',
      ],
      type: 'grammar',
      minutes: 22,
      previous: 'a1-u02-l04',
      vocabulary: lesson5Words,
      grammarTopic: grammar(
        titleEnglish: 'Subject pronouns and possessive adjectives',
        titleSomali: 'Magac-u-yaallada iyo lahaanshaha',
        explanation:
            'I iyo you waxay tilmaamaan qofka hadlaya iyo qofka lala hadlayo. He waa nin, she waa haweeney. My, your, his iyo her waxay muujiyaan cidda wax leh.',
        rule: 'I→my; you→your; he→his; she→her',
        structure: 'Subject + am/is/are + description',
        positive: lesson5Examples,
        negative: [
          ex('He is not my brother.', 'Isagu ma aha walaalkay.'),
          ex('She is not my teacher.', 'Iyadu ma aha macallinkayga.'),
        ],
        questions: [
          ex('Is he your friend?', 'Isagu ma saaxiibkaa baa?'),
          ex('What is her name?', 'Magaceedu waa maxay?'),
        ],
        mistakes: const [
          'Ha u isticmaalin he qof dumar ah.',
          'His waa lahaanshaha nin; her waa lahaanshaha haweeney.',
        ],
      ),
      examples: lesson5Examples,
      dialogues: commonDialogues['l05']!,
      exercises: lesson5Exercises,
      speaking: lesson5Speaking,
      writing: lesson5Writing,
      summary:
          'This is… waxaa lagu baraa qof. He/his waxaa loo isticmaalaa nin; she/her waxaa loo isticmaalaa haweeney. My iyo your waxay muujiyaan lahaansho.',
    ),
    lesson(
      id: 'a1-u02-l06',
      number: 6,
      titleEnglish: 'Formal and Informal Greetings',
      titleSomali: 'Salaamaha rasmiga ah iyo kuwa caadiga ah',
      description:
          'Bar salaanta ku habboon saaxiib, macallin, maamule, macmiil, shaqaale iyo qof kaa weyn.',
      objectives: const [
        'Kala saar formal iyo informal greetings.',
        'Si rasmi ah u salaam macallin ama macmiil.',
        'Ka fogow Hey xaalad rasmi ah.',
      ],
      type: 'vocabulary',
      minutes: 18,
      previous: 'a1-u02-l05',
      vocabulary: lesson6Words,
      examples: lesson6Examples,
      dialogues: commonDialogues['l06']!,
      exercises: lesson6Exercises,
      speaking: lesson6Speaking,
      writing: lesson6Writing,
      summary:
          'Hi iyo Hey waa informal. Hello waa guud. Good morning iyo Pleased to meet you waxay ku habboon yihiin xaalad rasmi ah iyo qof markii ugu horreysay la kulmayo.',
    ),
    lesson(
      id: 'a1-u02-l07',
      number: 7,
      titleEnglish: 'Starting and Ending Conversations',
      titleSomali: 'Bilaabidda iyo soo gabagabeynta wada sheekeysiga',
      description:
          'Bar sida hadal si edeb leh loo bilaabo, loo sii wado, kadibna si dabiici ah loo soo gabagabeeyo.',
      objectives: const [
        'Wada sheekeysi ku bilow Excuse me.',
        'Weydii qof xaaladdiisa.',
        'Isticmaal ugu yaraan saddex weedhood oo lagu kala tago.',
      ],
      type: 'speaking',
      minutes: 20,
      previous: 'a1-u02-l06',
      vocabulary: lesson7Words,
      examples: lesson7Examples,
      dialogues: commonDialogues['l07']!,
      exercises: lesson7Exercises,
      speaking: lesson7Speaking,
      writing: lesson7Writing,
      summary:
          'Excuse me ayaa si edeb leh hadal u bilaaba. It was nice talking to you, Have a good day, Take care iyo Goodbye ayaa si dabiici ah u soo gabagabeeya.',
    ),
    lesson(
      id: 'a1-u02-l08',
      number: 8,
      titleEnglish: 'Unit Review',
      titleSomali: 'Dib-u-eegista Unit 2',
      description:
          'Dib u eeg salaamaha, isbarashada, su’aalaha magaca, xaaladda qofka, baridda dad kale iyo bilaabidda ama dhammeystirka wada sheekeysiga.',
      objectives: const [
        'Samee wada sheekeysi A1 oo dhammeystiran.',
        'Sax u isticmaal am, is, are, he, she, my, his iyo her.',
        'Kala saar formal iyo informal language.',
      ],
      type: 'review',
      minutes: 28,
      previous: 'a1-u02-l07',
      vocabulary: lesson8Words,
      examples: lesson8Examples,
      dialogues: commonDialogues['l08']!,
      exercises: lesson8Exercises,
      speaking: lesson8Speaking,
      writing: lesson8Writing,
      summary:
          'Waxaad dib u eegtay dhammaan Unit 2. Hadda waxaad salaami kartaa qof, isbari kartaa, magac iyo xaalad weydiin kartaa, qof kale bari kartaa, wada sheekeysina si edeb leh u bilaabi oo u dhammeystiri kartaa.',
    ),
  ];

  final quiz = <Map<String, dynamic>>[
    exercise(
      'a1-u02-q01',
      'multipleChoice',
      'Salaantee ku habboon 8:00 subaxnimo?',
      ['Good evening', 'Good morning', 'Good night', 'Bye'],
      'Good morning',
      'Good morning waxaa la isticmaalaa subaxdii.',
    ),
    exercise(
      'a1-u02-q02',
      'multipleChoice',
      'Kee ayaa lagu yiraahdaa marka la seexanayo?',
      ['Good afternoon', 'Hello', 'Good night', 'Good morning'],
      'Good night',
      'Good night waxaa la yiraahdaa marka la kala tagayo habeenkii ama la seexanayo.',
    ),
    exercise(
      'a1-u02-q03',
      'multipleChoice',
      '“See you later” maxay ka dhigan tahay?',
      [
        'Subax wanaagsan',
        'Goor dambe ayaan is arki doonnaa',
        'Magacaa?',
        'Waan daalay',
      ],
      'Goor dambe ayaan is arki doonnaa',
      'Weedhu waxay muujinaysaa in mar kale la kulmi doono.',
    ),
    exercise(
      'a1-u02-q04',
      'multipleChoice',
      'Kee ayaa formal ah?',
      ['Hey!', 'Pleased to meet you.', 'Hi, friend!', 'Bye!'],
      'Pleased to meet you.',
      'Pleased to meet you waa qaab rasmi ah oo xushmad leh.',
    ),
    exercise(
      'a1-u02-q05',
      'multipleChoice',
      '“Take care” waxaa la yiraahdaa marka…',
      [
        'la isbarayo',
        'la kala tagayo',
        'magac la weydiinayo',
        'subax la salaamayo',
      ],
      'la kala tagayo',
      'Take care waa weedh diirran oo lagu soo gabagabeeyo kulanka.',
    ),
    exercise(
      'a1-u02-q06',
      'fillInTheBlank',
      'I ___ a student.',
      ['is', 'are', 'am', 'be'],
      'am',
      'I waxaa la socda am.',
    ),
    exercise(
      'a1-u02-q07',
      'fillInTheBlank',
      'What ___ your name?',
      ['am', 'is', 'are', 'do'],
      'is',
      'Qaabka saxda ahi waa What is your name?',
    ),
    exercise(
      'a1-u02-q08',
      'fillInTheBlank',
      'She ___ my teacher.',
      ['am', 'are', 'is', 'be'],
      'is',
      'She waxaa la socda is.',
    ),
    exercise(
      'a1-u02-q09',
      'multipleChoice',
      'Amina waa haweeney. ___ name is Amina.',
      ['His', 'Her', 'My', 'Your'],
      'Her',
      'Her waxaa loo isticmaalaa lahaanshaha qof dumar ah.',
    ),
    exercise(
      'a1-u02-q10',
      'multipleChoice',
      'Kee ayaa contraction sax ah?',
      ['Im', 'I,m', 'I’m', 'Iam'],
      'I’m',
      'I’m waa qaabka saxda ah ee I am oo apostrophe leh.',
    ),
    exercise(
      'a1-u02-q11',
      'multipleChoice',
      'A: Good morning. B: ___',
      ['Good night.', 'Good morning.', 'Take care yesterday.', 'Who are you?'],
      'Good morning.',
      'Salaanta waxaa si dabiici ah loogu jawaabaa isla salaanta ku habboon waqtiga.',
    ),
    exercise(
      'a1-u02-q12',
      'multipleChoice',
      'A: What is your name? B: ___',
      ['I am fine.', 'My name is Hawa.', 'Good night.', 'He is tired.'],
      'My name is Hawa.',
      'Su’aashu magac ayay weydiinaysaa, sidaas darteed magaca ayaa lagu jawaabaa.',
    ),
    exercise(
      'a1-u02-q13',
      'multipleChoice',
      'A: How are you? B: ___',
      [
        'I am fine, thank you.',
        'My name is Ali.',
        'Good evening yesterday.',
        'Her name is Asha.',
      ],
      'I am fine, thank you.',
      'How are you? waxaa looga jawaabaa xaaladda qofka.',
    ),
    exercise(
      'a1-u02-q14',
      'multipleChoice',
      'A: It was nice talking to you. B: ___',
      [
        'What is your name?',
        'Nice talking to you too. Goodbye.',
        'Good morning.',
        'I am from Somalia.',
      ],
      'Nice talking to you too. Goodbye.',
      'Tani waa jawaab ku habboon dhammaadka wada sheekeysiga.',
    ),
    exercise(
      'a1-u02-q15',
      'englishToSomali',
      'Turjun: “Nice to meet you.”',
      [
        'Waan ku faraxsanahay inaan kula kulmo.',
        'Sidee tahay?',
        'Habeen wanaagsan.',
        'Magacaa?',
      ],
      'Waan ku faraxsanahay inaan kula kulmo.',
      'Weedhan waxaa la yiraahdaa marka qof cusub lala kulmo.',
    ),
    exercise(
      'a1-u02-q16',
      'englishToSomali',
      'Turjun: “Are you okay?”',
      [
        'Ma arday baad tahay?',
        'Ma fiican tahay?',
        'Xaggee degan tahay?',
        'Magacaa?',
      ],
      'Ma fiican tahay?',
      'Are you okay? waxay weydiinaysaa xaaladda qofka.',
    ),
    exercise(
      'a1-u02-q17',
      'englishToSomali',
      'Turjun: “This is my friend.”',
      [
        'Kani waa saaxiibkay.',
        'Isagu waa macallin.',
        'Magaceedu waa Hawa.',
        'Waxaan ahay arday.',
      ],
      'Kani waa saaxiibkay.',
      'This is my friend waxaa lagu baraa saaxiib.',
    ),
    exercise(
      'a1-u02-q18',
      'somaliToEnglish',
      'U beddel English: “Magacaygu waa Sahra.”',
      [
        'Her name is Sahra.',
        'My name is Sahra.',
        'Your name is Sahra.',
        'His name is Sahra.',
      ],
      'My name is Sahra.',
      'My name is… ayaa lagu sheegaa magacaaga.',
    ),
    exercise(
      'a1-u02-q19',
      'somaliToEnglish',
      'U beddel English: “Sidee tahay?”',
      ['Who are you?', 'How are you?', 'What is your name?', 'Where are you?'],
      'How are you?',
      'How are you? waa su’aasha xaaladda qofka.',
    ),
    exercise(
      'a1-u02-q20',
      'somaliToEnglish',
      'U beddel English: “Maalin wanaagsan.”',
      [
        'Good night.',
        'Have a good day.',
        'Good morning?',
        'See you yesterday.',
      ],
      'Have a good day.',
      'Have a good day waxaa loo adeegsadaa duco ahaan marka la kala tagayo.',
    ),
  ];

  final unit = {
    'id': 'a1-u02',
    'levelId': 'A1',
    'unitNumber': 2,
    'titleEnglish': 'Greetings and Introductions',
    'titleSomali': 'Salaanta iyo Isbarashada',
    'introductionSomali':
        'Unit-kan wuxuu ku barayaa sida qof loo salaamo, la isu baro, magaca iyo xaaladda loo weydiiyo, qof kale loo baro, iyo wada sheekeysi fudud si edeb leh loo bilaabo loona dhammeeyo.',
    'requiredPreviousUnitId': 'a1-u01',
    'lessons': lessons,
    'unitQuiz': quiz,
    'passingScore': 70,
  };

  const encoder = JsonEncoder.withIndent('  ');
  File('assets/content/a1/unit_02.json')
    ..createSync(recursive: true)
    ..writeAsStringSync('${encoder.convert(unit)}\n');
}
