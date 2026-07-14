import 'dart:convert';
import 'dart:io';

import 'generate_a1_unit7.dart' as base;

typedef Json = Map<String, Object?>;
typedef Phrase = ({String en, String so, String label});

Phrase p(String en, String so, {String label = 'neutral phrase'}) =>
    (en: en, so: so, label: label);

Json vocab(Phrase item, String title) => {
  'englishWord': item.en,
  'somaliMeaning': item.so,
  'partOfSpeech': item.label,
  'pronunciation': item.en.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ''),
  'exampleEnglish': '${item.en} This phrase is useful in $title.',
  'exampleSomali':
      '${item.so}. Weedhan waxaa lagu isticmaalaa xaalad maalinle ah.',
  'explanationSomali':
      '${item.en} waa ${item.label}; macnaheedu waa ${item.so}.',
  'commonMistakeSomali': item.en == 'Nice to meet you.'
      ? 'Nice to meet you isticmaal kulanka koowaad; nice to see you qof hore loo yaqaan.'
      : item.en.startsWith('Can ')
      ? 'Can kadib isticmaal base verb.'
      : '',
};

class Seed {
  const Seed(
    this.title,
    this.somali,
    this.description,
    this.phrases,
    this.examples,
    this.dialogues, {
    this.grammar,
    this.review = false,
  });
  final String title;
  final String somali;
  final String description;
  final List<Phrase> phrases;
  final List<(String, String)> examples;
  final List<Json> dialogues;
  final Json? grammar;
  final bool review;
}

List<(String, String)> examples(String a, String b, String c) => [
  (a, 'Tusaalaha koowaad ee wada sheekeysiga.'),
  (b, 'Tusaalaha labaad ee wada sheekeysiga.'),
  (c, 'Tusaalaha saddexaad ee wada sheekeysiga.'),
  ('Can you repeat that, please?', 'Ma ku celin kartaa, fadlan?'),
  ('Thank you for your help.', 'Waad ku mahadsan tahay caawimadaada.'),
  ('It was nice talking to you.', 'Waan ku farxay inaan kula hadlo.'),
];

Json d(String title, List<(String, String, String)> lines) =>
    base.dialogue(title, lines);

List<Json> twoDialogues(String topic, String request) => [
  d('$topic: wada hadal 1', [
    ('A', 'Hello. $request', 'Salaan. ${_translateRequest(request)}'),
    ('B', 'Yes, of course.', 'Haa, dabcan.'),
    ('A', 'Thank you for your help.', 'Waad ku mahadsan tahay caawimadaada.'),
    ('B', 'You’re welcome.', 'Adigaa mudan.'),
  ]),
  d('$topic: wada hadal 2', [
    (
      'A',
      'Excuse me. Can I ask a question?',
      'Iga raalli ahow. Su’aal ma weydiin karaa?',
    ),
    ('B', 'Sure. What is it?', 'Haa. Waa maxay?'),
    ('A', request, _translateRequest(request)),
    ('B', 'One moment, please.', 'Hal daqiiqo, fadlan.'),
  ]),
];

String _translateRequest(String text) {
  if (text.contains('help')) return 'Ma i caawin kartaa?';
  if (text.contains('menu')) return 'Menu-ga ma arki karaa?';
  if (text.contains('hospital')) return 'Isbitaalku xaggee ku yaal?';
  if (text.contains('speak')) return 'Si tartiib ah ma u hadli kartaa?';
  return 'Waxaan jeclaan lahaa inaan ku weydiiyo.';
}

Json grammar(
  String id,
  String title,
  String rule,
  List<(String, String)> positive, {
  List<(String, String)> negative = const [],
  List<(String, String)> questions = const [],
  List<String> mistakes = const [],
}) => base.grammar(
  id,
  title,
  title,
  rule,
  'Conversation phrase + response',
  positive,
  negatives: negative,
  questions: questions,
  mistakes: mistakes,
);

List<Json> practice(int number, Seed seed) {
  final id = 'a1-u10-l${number.toString().padLeft(2, '0')}';
  final a = seed.phrases[0];
  final b = seed.phrases.length > 1 ? seed.phrases[1] : a;
  final c = seed.phrases.length > 2 ? seed.phrases[2] : b;
  final result = <Json>[
    base.exercise(
      '$id-p01',
      'multipleChoice',
      '“${a.en}” maxay ka dhigan tahay?',
      [a.so, b.so, c.so, 'Jid toos ah'],
      a.so,
      '${a.en} macnihiisu waa ${a.so}.',
    ),
    base.exercise(
      '$id-p02',
      'englishToSomali',
      'U turjun: ${b.en}',
      [b.so, a.so, c.so, 'Waqti dambe'],
      b.so,
      '${b.en} waa ${b.so}.',
    ),
    base.exercise(
      '$id-p03',
      'somaliToEnglish',
      'English ku dooro: ${c.so}',
      [c.en, a.en, b.en, 'Turn left.'],
      c.en,
      '${c.so} waa ${c.en}.',
    ),
    base.exercise(
      '$id-p04',
      'multipleChoice',
      'Dooro jawaabta ugu habboon: How are you?',
      ['I’m fine, thank you.', 'At the bank.', 'Five dollars.', 'Turn right.'],
      'I’m fine, thank you.',
      'How are you waxaa looga jawaabaa xaaladda qofka.',
    ),
    base.exercise(
      '$id-p05',
      'multipleChoice',
      'Dooro codsiga edebta leh.',
      [
        'Could you help me, please?',
        'Help me now.',
        'You help.',
        'Helping me.',
      ],
      'Could you help me, please?',
      'Could you…please waa codsi edeb leh.',
    ),
    base.exercise(
      '$id-p06',
      'fillInTheBlank',
      'Can you ___ that again?',
      ['say', 'says', 'said', 'saying'],
      'say',
      'Can kadib base verb say.',
    ),
    base.exercise(
      '$id-p07',
      'chooseGrammar',
      'She ___ in an office.',
      ['works', 'work', 'working', 'do work'],
      'works',
      'Present Simple: she works.',
    ),
    base.exercise(
      '$id-p08',
      'arrangeSentence',
      'Habee: help / can / you / me',
      [
        'Can you help me?',
        'You help can me?',
        'Help can me you?',
        'Me can you help.',
      ],
      'Can you help me?',
      'Can + subject + base verb.',
    ),
    base.exercise(
      '$id-p09',
      'multipleChoice',
      'Formal mise informal: “Good morning.”',
      ['Formal or neutral', 'Only slang', 'Rude', 'Direction'],
      'Formal or neutral',
      'Good morning waa salaan rasmi ama neutral ah.',
    ),
    base.exercise(
      '$id-p10',
      'trueFalse',
      'Nice to meet you waxaa badanaa la yiraahdaa kulanka ugu horreeya.',
      ['True', 'False'],
      'True',
      'Nice to meet you waa kulanka koowaad.',
    ),
    base.exercise(
      '$id-p11',
      'readingComprehension',
      'A: May I see the menu? B: Yes. Are you ready to order? Xaggee wada hadalku ka dhacayaa?',
      ['Restaurant', 'School', 'Bank', 'Bus station'],
      'Restaurant',
      'Menu iyo order waxay tilmaamayaan makhaayad.',
    ),
    base.exercise(
      '$id-p12',
      'multipleChoice',
      'Wada hadalka si edeb leh u soo gabagabee.',
      ['Have a good day. Goodbye.', 'Stop talk.', 'You leave.', 'No words.'],
      'Have a good day. Goodbye.',
      'Waa dhammaad dabiici ah oo edeb leh.',
    ),
    base.exercise(
      '$id-p13',
      'speakingPrompt',
      'Samee role-play ku saabsan ${seed.somali}.',
      [],
      'Hawl hadal furan',
      'Isticmaal bilow, dhex iyo dhammaad cad.',
    ),
    base.exercise(
      '$id-p14',
      'shortWriting',
      'Qor wada sheekeysi gaaban oo ku saabsan ${seed.somali}.',
      [],
      'Hawl qoraal furan',
      'Qor ugu yaraan afar hadal-isweydaarsi.',
    ),
  ];
  if (seed.review) {
    for (var i = 15; i <= 35; i++) {
      final polite = i.isEven;
      result.add(
        base.exercise(
          '$id-p${i.toString().padLeft(2, '0')}',
          'multipleChoice',
          polite
              ? 'Dooro codsiga edebta leh.'
              : 'Dooro jawaabta ugu dabiicisan: Thank you.',
          polite
              ? [
                  'Can you repeat that, please?',
                  'Repeat now.',
                  'You repeat.',
                  'Again speak.',
                ]
              : ['You’re welcome.', 'Turn left.', 'At five.', 'A student.'],
          polite ? 'Can you repeat that, please?' : 'You’re welcome.',
          polite
              ? 'Can you…please waa codsi edeb leh.'
              : 'Thank you waxaa looga jawaabaa You’re welcome.',
        ),
      );
    }
  }
  return result;
}

Json lesson(int number, Seed seed) {
  final id = 'a1-u10-l${number.toString().padLeft(2, '0')}';
  final exercises = practice(number, seed);
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-u10',
    'lessonNumber': number,
    'titleEnglish': seed.title,
    'titleSomali': seed.somali,
    'shortDescriptionSomali': seed.description,
    'learningObjectives': [
      'Bar phrases-ka muhiimka ah ee ${seed.somali}.',
      'Samee wada sheekeysi A1 leh bilow, dhex iyo dhammaad.',
      'Ku tababar hadal, qoraal iyo faham.',
    ],
    'lessonType': seed.review
        ? 'review'
        : seed.grammar == null
        ? 'speaking'
        : 'grammar',
    'estimatedMinutes': seed.review ? 35 : 22,
    'difficulty': 'A1',
    'isLocked': number != 1,
    'requiredPreviousLessonId': number == 1
        ? null
        : 'a1-u10-l${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': [for (final item in seed.phrases) vocab(item, seed.title)],
    'grammar': seed.grammar,
    'examples': [
      for (final item in seed.examples) base.example(item.$1, item.$2),
    ],
    'dialogues': seed.dialogues,
    'practiceExercises': exercises,
    'speakingPractice':
        'Samee role-play 30 ilaa 60 ilbiriqsi ah oo ku saabsan ${seed.somali}.',
    'writingPractice':
        'Qor wada sheekeysi A1 ah oo leh bilow, su’aalo/jawaabo iyo dhammaad edeb leh.',
    'summarySomali':
        'Waxaad ku tababartay ${seed.somali} iyo sida phrases-ka si dabiici ah loogu xiro.',
    'quizQuestions': [
      for (var i = 0; i < 3; i++)
        {...exercises[i], 'id': '$id-q${(i + 1).toString().padLeft(2, '0')}'},
    ],
  };
}

List<Phrase> ps(
  List<(String, String)> values, {
  String label = 'neutral phrase',
}) => [for (final value in values) p(value.$1, value.$2, label: label)];

void main() {
  final politeGrammar = grammar(
    'a1-u10-polite',
    'Polite Requests',
    'Codsiyada edebta leh waxay isticmaalaan Can/Could/May + subject + base verb iyo please.',
    [
      ('Can you help me?', 'Ma i caawin kartaa?'),
      ('Could you help me, please?', 'Ma i caawin kartaa, fadlan?'),
      ('May I ask a question?', 'Su’aal ma weydiin karaa?'),
      ('Can I have some water?', 'Biyo ma heli karaa?'),
      ('May I see the menu?', 'Menu-ga ma arki karaa?'),
      ('Can you repeat that?', 'Ma ku celin kartaa?'),
    ],
    negative: [('I cannot hear you.', 'Kuma maqli karo.')],
    questions: [('Can you speak slowly?', 'Si tartiib ah ma u hadli kartaa?')],
    mistakes: ['Can you helps waa khalad; Can you help ayaa sax ah.'],
  );
  final conversationGrammar = grammar(
    'a1-u10-review-grammar',
    'Conversation Grammar Review',
    'Unit-kan grammar cusub badan ma gelinayo; wuxuu isku xirayaa be, Present Simple, can, would like, there is/are iyo question words.',
    [
      ('I am a student.', 'Waxaan ahay arday.'),
      ('She works in a shop.', 'Waxay ka shaqaysaa dukaan.'),
      ('I have two brothers.', 'Waxaan leeyahay laba walaalo ah.'),
      ('I would like tea.', 'Waxaan jeclaan lahaa shaah.'),
      ('There is a bank nearby.', 'Bangi ayaa ag dhow.'),
      ('You can walk there.', 'Halkaas waad u lugayn kartaa.'),
    ],
    negative: [
      ('I don’t understand.', 'Ma fahmin.'),
      ('He cannot come today.', 'Maanta ma iman karo.'),
    ],
    questions: [
      ('Where do you live?', 'Xaggee ku nooshahay?'),
      ('What time does it start?', 'Goormay bilaabataa?'),
    ],
    mistakes: [
      'Does she works waa khalad; Does she work ayaa sax ah.',
      'Can kadib base verb isticmaal.',
    ],
  );

  final seeds = <Seed>[
    Seed(
      'Starting a Conversation',
      'Bilaabidda wada sheekeysiga',
      'Kala saar salaan rasmi, caadi, kulanka koowaad iyo qof hore loo yaqaan.',
      ps([
        ('Hello.', 'Salaan.'),
        ('Hi.', 'Haye/salaan.'),
        ('Good morning.', 'Subax wanaagsan.'),
        ('Excuse me.', 'Iga raalli ahow.'),
        ('How are you?', 'Sidee tahay?'),
        ('How are you doing?', 'Sidee tahay?'),
        ('Can I talk to you?', 'Ma kula hadli karaa?'),
        ('May I ask you a question?', 'Su’aal ma ku weydiin karaa?'),
        ('Is this seat free?', 'Kursigan ma bannaan yahay?'),
        ('Are you new here?', 'Ma ku cusub tahay halkan?'),
        ('Nice to meet you.', 'Waan ku faraxsanahay inaan kula kulmo.'),
        ('It is nice to see you.', 'Waa wax fiican inaan ku arko.'),
      ]),
      examples(
        'Good morning. How are you?',
        'Excuse me. May I ask a question?',
        'Nice to meet you.',
      ),
      twoDialogues('Bilaabidda wada sheekeysiga', 'Can I talk to you?'),
      grammar: politeGrammar,
    ),
    Seed(
      'Personal Information Conversation',
      'Wada sheekeysiga macluumaadka qofka',
      'Isticmaal xog tusaale ah si aad qof isu barato.',
      ps([
        ('What is your name?', 'Magacaa?'),
        ('My name is…', 'Magacaygu waa…'),
        ('Where are you from?', 'Xaggee baad ka timid?'),
        ('I am from Somalia.', 'Waxaan ka imid Soomaaliya.'),
        ('Where do you live?', 'Xaggee ku nooshahay?'),
        ('How old are you?', 'Immisa jir baad tahay?'),
        ('What do you do?', 'Maxaad qabataa?'),
        ('I am a student.', 'Waxaan ahay arday.'),
        ('What languages do you speak?', 'Luqadahee ku hadashaa?'),
        ('Can you repeat that, please?', 'Ma ku celin kartaa, fadlan?'),
      ]),
      examples(
        'My name is Amal.',
        'I live in a city.',
        'I speak Somali and some English.',
      ),
      twoDialogues('Macluumaadka qofka', 'Can you repeat that, please?'),
    ),
    Seed(
      'At School or University',
      'Iskuulka ama jaamacadda',
      'Ku hadal fasalka, jadwalka iyo caawimada waxbarashada.',
      ps([
        ('Which class are you in?', 'Fasalkee baad ku jirtaa?'),
        ('What subject do you study?', 'Maaddadee barataa?'),
        ('I study English.', 'Waxaan bartaa English.'),
        ('What time does the lesson start?', 'Goormuu casharku bilaabmaa?'),
        ('Where is the classroom?', 'Aaway fasalku?'),
        ('I don’t understand.', 'Ma fahmin.'),
        ('Can you explain it again?', 'Mar kale ma sharxi kartaa?'),
        ('How do you spell this word?', 'Sidee eraygan loo higgaadiyaa?'),
        ('May I borrow your pen?', 'Qalinkaaga ma amaahan karaa?'),
        ('When is the exam?', 'Goormuu imtixaanku yahay?'),
      ]),
      examples(
        'The lesson starts at eight.',
        'The classroom is next to the library.',
        'The exam is on Monday.',
      ),
      twoDialogues('Iskuulka', 'Can you help me?'),
      grammar: politeGrammar,
    ),
    Seed(
      'At Work',
      'Goobta shaqada',
      'Ku hadal shaqada, jadwalka iyo codsiyada fudud.',
      ps([
        ('Where do you work?', 'Xaggee ka shaqaysaa?'),
        ('I work in an office.', 'Waxaan ka shaqeeyaa xafiis.'),
        ('What time do you start work?', 'Goormaad shaqada bilowdaa?'),
        ('I help customers.', 'Waxaan caawiyaa macaamiisha.'),
        ('Are you busy?', 'Ma mashquulsan tahay?'),
        ('Can you send this message?', 'Fariintan ma diri kartaa?'),
        ('The meeting is at two.', 'Kulanku waa labada.'),
        ('Where is the manager?', 'Aaway maamuluhu?'),
        ('I finish work at five.', 'Shaqada waxaan dhammeeyaa shanta.'),
        ('Computer', 'kombiyuutar'),
      ]),
      examples(
        'I start work at eight.',
        'The manager is in the office.',
        'Can you help this customer?',
      ),
      twoDialogues('Goobta shaqada', 'Can you help me?'),
    ),
    Seed(
      'At a Shop or Market',
      'Dukaanka ama suuqa',
      'Ku tababar iibsashada, qiimaha iyo quantities.',
      ps([
        ('Can I help you?', 'Ma ku caawin karaa?'),
        ('I am looking for…', 'Waxaan raadinayaa…'),
        ('Do you have any water?', 'Biyo ma haysaan?'),
        ('How much is this?', 'Kani waa immisa?'),
        ('How much are these?', 'Kuwani waa immisa?'),
        ('That is too expensive.', 'Kaasi aad buu qaali u yahay.'),
        ('Do you have a cheaper one?', 'Mid ka jaban ma haysaan?'),
        ('I would like two, please.', 'Laba ayaan jeclaan lahaa, fadlan.'),
        ('Anything else?', 'Wax kale?'),
        ('Can I have a receipt?', 'Rasiid ma heli karaa?'),
      ]),
      examples(
        'It is five dollars.',
        'They are ten dollars.',
        'That’s all, thank you.',
      ),
      twoDialogues('Dukaanka', 'Can you help me?'),
    ),
    Seed(
      'At a Restaurant or Café',
      'Makhaayadda ama kafateeriyada',
      'Dalbo cunto, sax dalab khaldan oo codso biilka.',
      ps([
        ('May I see the menu, please?', 'Menu-ga ma arki karaa, fadlan?'),
        ('Are you ready to order?', 'Diyaar ma u tahay dalabka?'),
        (
          'I would like rice and chicken.',
          'Waxaan jeclaan lahaa bariis iyo digaag.',
        ),
        ('What would you like to drink?', 'Maxaad cabbi lahayd?'),
        ('Can I have some water?', 'Biyo ma heli karaa?'),
        ('Can I have the bill, please?', 'Biilka ma heli karaa, fadlan?'),
        ('How much is the total?', 'Wadartu waa immisa?'),
        (
          'Sorry, I ordered tea, not coffee.',
          'Raalli ahow, shaah ayaan dalbaday, bun ma aha.',
        ),
        ('This is not my order.', 'Kani ma aha dalabkayga.'),
        ('Can you change it, please?', 'Ma beddeli kartaa, fadlan?'),
      ]),
      examples(
        'The food is very good.',
        'No, thank you.',
        'Thank you for the service.',
      ),
      twoDialogues('Makhaayadda', 'May I see the menu, please?'),
      grammar: politeGrammar,
    ),
    Seed(
      'Asking for Help',
      'Caawimo weydiisashada',
      'Kala saar amar toos ah iyo codsi edeb leh.',
      ps([
        ('Can you help me?', 'Ma i caawin kartaa?'),
        ('Could you help me, please?', 'Ma i caawin kartaa, fadlan?'),
        ('I need help.', 'Caawimo ayaan u baahanahay.'),
        ('I don’t understand.', 'Ma fahmin.'),
        ('Can you say that again?', 'Mar kale ma oran kartaa?'),
        ('Can you speak slowly, please?', 'Si tartiib ah ma u hadli kartaa?'),
        ('What does this word mean?', 'Eraygani muxuu ka dhigan yahay?'),
        ('How do you spell it?', 'Sidee loo higgaadiyaa?'),
        ('Can you show me?', 'Ma i tusi kartaa?'),
        ('No problem.', 'Dhib ma leh.'),
      ]),
      examples(
        'How do you say this in English?',
        'Thank you for your help.',
        'You’re welcome.',
      ),
      twoDialogues('Caawimo', 'Can you help me?'),
      grammar: politeGrammar,
    ),
    Seed(
      'On the Phone',
      'Wada sheekeysiga telefoonka',
      'Bilow wicitaan, codso qof, reeb fariin oo ka jawaab connection problem.',
      ps([
        ('Hello, this is Ahmed.', 'Salaan, kani waa Axmed.'),
        ('May I speak to Amina?', 'Aamina ma la hadli karaa?'),
        ('Who is calling?', 'Yaa soo wacaya?'),
        ('One moment, please.', 'Hal daqiiqo, fadlan.'),
        ('Please hold.', 'Fadlan sug.'),
        ('She is busy right now.', 'Hadda way mashquulsan tahay.'),
        ('Can I leave a message?', 'Fariin ma reebi karaa?'),
        ('Please ask her to call me.', 'Fadlan u sheeg inay i soo wacdo.'),
        ('I cannot hear you.', 'Kuma maqli karo.'),
        ('The connection is bad.', 'Xiriirku wuu xun yahay.'),
        ('Goodbye.', 'Nabadgelyo.'),
      ]),
      examples(
        'This is Ali.',
        'Can you call me later?',
        'Can you repeat that?',
      ),
      twoDialogues('Telefoonka', 'Can you help me?'),
    ),
    Seed(
      'Making Simple Plans',
      'Samaynta qorshe fudud',
      'Qorshee kulan adigoon gelin future grammar qoto dheer.',
      ps([
        ('Are you free tomorrow?', 'Berri ma bannaan tahay?'),
        ('Are you free on Friday?', 'Jimcaha ma bannaan tahay?'),
        ('Would you like to meet?', 'Ma jeclaan lahayd inaan kulanno?'),
        ('Let’s meet at ten.', 'Aan kulanno tobanka.'),
        ('Where shall we meet?', 'Xaggee ku kulannaa?'),
        ('What time is good for you?', 'Waqtigee kuu fiican?'),
        ('Is three o’clock okay?', 'Saddexda ma hagaagtaa?'),
        (
          'Sorry, I am busy then.',
          'Raalli ahow, waqtigaas waan mashquulsanahay.',
        ),
        ('Can we meet later?', 'Mar dambe ma kulmi karnaa?'),
        ('See you tomorrow.', 'Berri ayaan is aragnaa.'),
      ]),
      examples('Let’s meet at the café.', 'See you at ten.', 'Yes, I am free.'),
      twoDialogues('Qorshe samayn', 'Can we meet later?'),
    ),
    Seed(
      'Asking for and Giving Directions',
      'Jid weydiinta iyo tilmaamidda',
      'Ku dabaq Unit 9 wada sheekeysi kooban.',
      ps([
        ('Where is the hospital?', 'Aaway isbitaalku?'),
        ('Is it far from here?', 'Halkan ma ka fog tahay?'),
        ('Can I walk there?', 'Ma u lugayn karaa?'),
        ('Go straight.', 'Toos u soco.'),
        ('Turn left at the bank.', 'Bangiga bidix uga leexo.'),
        ('It is next to the pharmacy.', 'Farmashiyaha ayay ku xigtaa.'),
        ('How long does it take?', 'Intee ayay qaadataa?'),
        ('It takes ten minutes.', 'Waxay qaadataa toban daqiiqo.'),
        ('Thank you for your help.', 'Waad ku mahadsan tahay caawimada.'),
        ('You’re welcome.', 'Adigaa mudan.'),
      ]),
      examples(
        'Excuse me, where is the bank?',
        'Go straight and turn right.',
        'It is about five minutes away.',
      ),
      twoDialogues('Jid weydiinta', 'Where is the hospital?'),
    ),
    Seed(
      'Visiting Someone',
      'Booqashada qof',
      'Soo dhowee marti, soo bandhig qof oo soo gabagabee booqasho.',
      ps([
        ('Welcome.', 'Soo dhowow.'),
        ('Please come in.', 'Fadlan soo gal.'),
        ('Please sit down.', 'Fadlan fadhiiso.'),
        ('How is your family?', 'Qoyskaagu sidee yahay?'),
        ('They are well, thank you.', 'Way fiican yihiin, mahadsanid.'),
        ('Would you like some tea?', 'Shaah ma jeclaan lahayd?'),
        ('This is my brother.', 'Kani waa walaalkay.'),
        ('Your home is beautiful.', 'Gurigaagu waa qurux badan yahay.'),
        ('Thank you for visiting.', 'Waad ku mahadsan tahay booqashada.'),
        ('See you again.', 'Mar kale ayaan is aragnaa.'),
      ]),
      examples(
        'Nice to meet you.',
        'No, thank you.',
        'It was nice seeing you.',
      ),
      twoDialogues('Booqasho', 'Would you like some tea?'),
    ),
    Seed(
      'Talking About Daily Life',
      'Ka hadalka nolol maalmeedka',
      'Isku dar routine, family, work, study, food iyo free time.',
      ps([
        ('What do you do every day?', 'Maxaad maalin kasta samaysaa?'),
        ('What time do you wake up?', 'Goormaad toostaa?'),
        ('Do you work or study?', 'Ma shaqaysaa mise wax baad barataa?'),
        ('What do you do in the evening?', 'Maxaad fiidkii samaysaa?'),
        ('What food do you like?', 'Cunto noocee ah baad jeceshahay?'),
        ('Do you play football?', 'Kubad ma ciyaartaa?'),
        ('What do you do on Friday?', 'Maxaad Jimcaha samaysaa?'),
        ('Who do you live with?', 'Yaad la nooshahay?'),
      ]),
      examples(
        'I wake up at six and study in the morning.',
        'I work in a shop.',
        'In the evening, I talk to my family.',
      ),
      twoDialogues('Nolol maalmeedka', 'Can I ask you a question?'),
      grammar: conversationGrammar,
    ),
    Seed(
      'Understanding Common Responses',
      'Fahamka jawaabaha caadiga ah',
      'Faham jawaabaha, raalligelinta iyo codsiga ku celinta.',
      ps([
        ('Yes, of course.', 'Haa, dabcan.'),
        ('Sure.', 'Hubaal/haye.'),
        ('Okay.', 'Hagaag.'),
        ('All right.', 'Waa hagaag.'),
        ('Maybe.', 'Laga yaabee.'),
        ('I don’t know.', 'Ma aqaan.'),
        ('I’m not sure.', 'Ma hubo.'),
        ('I understand.', 'Waan fahmay.'),
        ('Please wait.', 'Fadlan sug.'),
        ('That’s fine.', 'Waa hagaag.'),
        ('No problem.', 'Dhib ma leh.'),
        ('Sorry.', 'Waan ka xumahay.'),
        ('Excuse me.', 'Iga raalli ahow.'),
        ('Pardon?', 'Ma ku celin kartaa?'),
        ('You’re welcome.', 'Adigaa mudan.'),
      ]),
      examples('One moment, please.', 'That’s okay.', 'Thank you.'),
      twoDialogues('Jawaabaha caadiga ah', 'Can you help me?'),
    ),
    Seed(
      'Ending a Conversation',
      'Soo gabagabeynta wada sheekeysiga',
      'Dooro dhammaadka ku habboon waqtiga iyo xaaladda.',
      ps([
        ('It was nice talking to you.', 'Waan ku farxay inaan kula hadlo.'),
        ('I have to go now.', 'Hadda waa inaan tagaa.'),
        ('See you later.', 'Mar dambe ayaan is aragnaa.'),
        ('See you tomorrow.', 'Berri ayaan is aragnaa.'),
        ('See you soon.', 'Dhawaan ayaan is aragnaa.'),
        ('Have a good day.', 'Maalin wanaagsan.'),
        ('Have a nice evening.', 'Fiid wanaagsan.'),
        ('Take care.', 'Is ilaali.'),
        ('Goodbye.', 'Nabadgelyo.'),
        ('Bye.', 'Nabadgelyo.'),
        ('Good night.', 'Habeen wanaagsan.'),
        ('Thank you for your time.', 'Waad ku mahadsan tahay waqtigaaga.'),
      ]),
      examples(
        'I have to go now. Goodbye.',
        'Have a good day.',
        'Take care. See you soon.',
      ),
      twoDialogues('Soo gabagabeyn', 'I have to go now.'),
    ),
    Seed(
      'Complete Everyday Conversations',
      'Wada sheekeysiyo maalinle ah oo dhammaystiran',
      'Siddeed xaaladood oo leh bilow, dhex iyo dhammaad.',
      ps([
        ('First meeting', 'kulanka koowaad'),
        ('Teacher help', 'caawimada macallinka'),
        ('Shopping', 'wax iibsasho'),
        ('Ordering food', 'cunto dalbasho'),
        ('Directions', 'jid weydiin'),
        ('Phone call', 'wicitaan telefoon'),
        ('Making plans', 'qorshe samayn'),
        ('Home visit', 'booqasho guri'),
      ]),
      examples(
        'Hello, my name is Ali. Nice to meet you.',
        'Can you explain this again, please?',
        'Goodbye. Have a good day.',
      ),
      [
        ...twoDialogues('Kulanka koowaad', 'Nice to meet you.'),
        ...twoDialogues('Arday iyo macallin', 'Can you help me?'),
        ...twoDialogues('Dukaan', 'Can you help me?'),
        ...twoDialogues('Makhaayad', 'May I see the menu, please?'),
      ],
    ),
    Seed(
      'Conversation Strategies for Beginners',
      'Hababka bilowgu wada sheekeysiga u sii wadi karo',
      'Codso ku celin, waqti fikir iyo su’aal celin.',
      ps([
        ('Can you repeat that, please?', 'Ma ku celin kartaa, fadlan?'),
        ('Can you speak slowly?', 'Si tartiib ah ma u hadli kartaa?'),
        ('What does that mean?', 'Taasi maxay ka dhigan tahay?'),
        ('How do you spell it?', 'Sidee loo higgaadiyaa?'),
        ('I understand a little.', 'Wax yar ayaan fahmay.'),
        ('Let me think.', 'Aan ka fikiro.'),
        ('Do you mean…?', 'Ma waxaad ula jeeddaa…?'),
        ('Is this correct?', 'Kani ma sax baa?'),
        ('Really?', 'Runtii?'),
        ('And you?', 'Adiguna?'),
        ('What about you?', 'Adiguna ka warran?'),
        ('That is interesting.', 'Taasi waa xiiso.'),
        ('Me too.', 'Anigana sidoo kale.'),
        ('I see.', 'Waan fahmay.'),
      ]),
      examples(
        'One moment, please.',
        'I don’t know the word in English.',
        'Okay. What about you?',
      ),
      twoDialogues('Hababka bilowga', 'Can you speak slowly?'),
      grammar: politeGrammar,
    ),
    Seed(
      'Unit Review',
      'Dib-u-eegista Unit 10',
      'Dib u eeg dhammaan xaaladaha wada sheekeysiga iyo grammar correction.',
      ps([
        ('Start a conversation', 'bilow wada sheekeysi'),
        ('Ask a question', 'su’aal weydii'),
        ('Polite request', 'codsi edeb leh'),
        ('Best response', 'jawaabta ugu habboon'),
        ('Formal', 'rasmi'),
        ('Informal', 'caadi/aan rasmi ahayn'),
        ('Complete a dialogue', 'dhammaystir wada hadal'),
        ('Role-play', 'door-jilid'),
        ('End a conversation', 'soo gabagabee wada hadal'),
        ('Common mistake', 'khalad caadi ah'),
      ]),
      examples(
        'Excuse me. Can you help me?',
        'Yes, of course.',
        'Thank you. Have a good day.',
      ),
      twoDialogues('Dib-u-eegista Unit 10', 'Can you help me?'),
      grammar: conversationGrammar,
      review: true,
    ),
  ];
  final unit = {
    'id': 'a1-u10',
    'levelId': 'A1',
    'unitNumber': 10,
    'titleEnglish': 'Basic Conversations',
    'titleSomali': 'Wada Sheekeysiyada Aasaasiga ah',
    'introductionSomali':
        'Unit-kan wuxuu isku xirayaa aqoontii Unit 1 ilaa Unit 9 si loogu isticmaalo wada sheekeysiyada nolol maalmeedka.',
    'requiredPreviousUnitId': 'a1-u09',
    'lessons': [for (var i = 0; i < seeds.length; i++) lesson(i + 1, seeds[i])],
    'unitQuiz': unitQuiz(),
    'passingScore': 70,
  };
  File(
    'assets/content/a1/unit_10.json',
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
      'a1-u10-q${(q.length + 1).toString().padLeft(2, '0')}',
      type,
      text,
      options,
      answer,
      why,
    ),
  );
  // 6 starting/ending.
  add(
    'multipleChoice',
    'Kulanka koowaad maxaad tiraahdaa?',
    [
      'Nice to meet you.',
      'Nice to see you again.',
      'Turn left.',
      'Five dollars.',
    ],
    'Nice to meet you.',
    'Kulanka koowaad: Nice to meet you.',
  );
  add(
    'multipleChoice',
    'Qof hore loo yaqaan?',
    [
      'Nice to see you.',
      'Nice to meet you first.',
      'Who calling road?',
      'At the bank.',
    ],
    'Nice to see you.',
    'Qof hore loo yaqaan: Nice to see you.',
  );
  add(
    'multipleChoice',
    'Salaan rasmi/neutral subaxdii?',
    ['Good morning.', 'Bye now.', 'How much?', 'Go straight.'],
    'Good morning.',
    'Good morning waa salaan subaxeed.',
  );
  add(
    'multipleChoice',
    'Dhammaad edeb leh?',
    ['Have a good day. Goodbye.', 'Stop.', 'You go.', 'No talk.'],
    'Have a good day. Goodbye.',
    'Waa dhammaad dabiici ah.',
  );
  add(
    'multipleChoice',
    'Good night goormaa?',
    [
      'Marka habeenkii la kala tagayo ama la seexanayo.',
      'Marka la isbaranayo.',
      'Marka qiime la weydiinayo.',
      'Marka jid la tilmaamayo.',
    ],
    'Marka habeenkii la kala tagayo ama la seexanayo.',
    'Good night waa dhammaad habeenkii.',
  );
  add(
    'multipleChoice',
    'Take care macnihiisu?',
    ['Is ilaali.', 'Bidix u leexo.', 'Laba koob.', 'Ma fahmin.'],
    'Is ilaali.',
    'Take care waa sagootin.',
  );
  // 5 personal information.
  add(
    'multipleChoice',
    'What is your name? Jawaab?',
    ['My name is Asha.', 'At eight.', 'Rice and tea.', 'Turn right.'],
    'My name is Asha.',
    'Su’aashu magac ayay weydiinaysaa.',
  );
  add(
    'multipleChoice',
    'Where are you from?',
    [
      'I am from Somalia.',
      'I am twenty.',
      'I am a teacher at eight.',
      'It is five.',
    ],
    'I am from Somalia.',
    'Su’aashu dalka/meesha laga yimid ayay weydiinaysaa.',
  );
  add(
    'multipleChoice',
    'How old are you?',
    [
      'I am twenty years old.',
      'I live in a city.',
      'I speak Somali.',
      'I work at five.',
    ],
    'I am twenty years old.',
    'Su’aashu da’da ayay weydiinaysaa.',
  );
  add(
    'multipleChoice',
    'What do you do?',
    ['I am a student.', 'I am from Somalia.', 'At the market.', 'On Monday.'],
    'I am a student.',
    'Su’aashu shaqo/xaalad ayay weydiinaysaa.',
  );
  add(
    'multipleChoice',
    'Xog aanad rabin inaad dhab u bixiso?',
    [
      'Isticmaal xog tusaale ah.',
      'Waa khasab xogta dhabta ah.',
      'Qor password.',
      'Qor cinwaan qof kale.',
    ],
    'Isticmaal xog tusaale ah.',
    'App-ku xog dhab ah kuma qasbayo.',
  );
  // 5 school/work.
  add(
    'multipleChoice',
    'Casharka ma fahmin?',
    ['Can you explain it again?', 'Give bill.', 'Turn right.', 'I order tea.'],
    'Can you explain it again?',
    'Waa codsi sharaxaad.',
  );
  add(
    'chooseGrammar',
    'What time ___ the lesson start?',
    ['does', 'do', 'is', 'are'],
    'does',
    'Lesson singular: does.',
  );
  add(
    'chooseGrammar',
    'She ___ in an office.',
    ['works', 'work', 'working', 'does works'],
    'works',
    'She + works.',
  );
  add(
    'multipleChoice',
    'Kulanku labada ayuu yahay.',
    [
      'The meeting is at two.',
      'Meeting on two.',
      'The meeting are two.',
      'At meeting two.',
    ],
    'The meeting is at two.',
    'At waxaa lala isticmaalaa saacad.',
  );
  add(
    'multipleChoice',
    'May I borrow your pen?',
    ['Yes, of course.', 'At Monday.', 'Five dollars.', 'Turn left.'],
    'Yes, of course.',
    'Waa jawaab codsi.',
  );
  // 5 shopping/restaurant.
  add(
    'multipleChoice',
    'Qiime singular?',
    [
      'How much is this?',
      'How much are this?',
      'How many is?',
      'What this cost are?',
    ],
    'How much is this?',
    'This singular waxaa la socda is.',
  );
  add(
    'multipleChoice',
    'Qiime plural?',
    [
      'How much are these?',
      'How much is these?',
      'How many this?',
      'Are much these?',
    ],
    'How much are these?',
    'These plural waxaa la socda are.',
  );
  add(
    'fillInTheBlank',
    'Do you have ___ water?',
    ['any', 'a', 'many', 'an'],
    'any',
    'Su’aalaha any ayaa caadi ah.',
  );
  add(
    'multipleChoice',
    'Makhaayad dalab edeb leh?',
    ['I would like rice, please.', 'Give rice.', 'Rice now.', 'I is rice.'],
    'I would like rice, please.',
    'Would like waa edeb leh.',
  );
  add(
    'multipleChoice',
    'Dalab khaldan?',
    [
      'Sorry, I ordered tea, not coffee.',
      'Coffee wrong you.',
      'No order is.',
      'Change now.',
    ],
    'Sorry, I ordered tea, not coffee.',
    'Waa sixid edeb leh.',
  );
  // 4 help.
  add(
    'multipleChoice',
    'Codsiga ugu edeb badan?',
    ['Could you help me, please?', 'Help me.', 'You help now.', 'Helping.'],
    'Could you help me, please?',
    'Could…please waa edeb badan.',
  );
  add(
    'fillInTheBlank',
    'Can you ___ slowly?',
    ['speak', 'speaks', 'spoke', 'speaking'],
    'speak',
    'Can kadib base verb.',
  );
  add(
    'multipleChoice',
    'Erayga ma fahmin?',
    [
      'What does this word mean?',
      'Where word road?',
      'How much word?',
      'Word at five?',
    ],
    'What does this word mean?',
    'Su’aashu macnaha ayay weydiinaysaa.',
  );
  add(
    'multipleChoice',
    'Thank you for your help.',
    ['You’re welcome.', 'At school.', 'No road.', 'Ten dollars.'],
    'You’re welcome.',
    'Waa jawaabta mahadcelinta.',
  );
  // 4 telephone.
  add(
    'multipleChoice',
    'Telefoon qof ku codso?',
    [
      'May I speak to Amina?',
      'Amina road?',
      'Speak Amina now.',
      'Where Amina cost?',
    ],
    'May I speak to Amina?',
    'Waa codsi telefoon edeb leh.',
  );
  add(
    'multipleChoice',
    'Who is calling?',
    ['This is Ali.', 'At ten.', 'In a shop.', 'Turn left.'],
    'This is Ali.',
    'Qofka soo wacaya ayaa is sheegaya.',
  );
  add(
    'multipleChoice',
    'Connection xun?',
    [
      'The connection is bad.',
      'The menu is bad.',
      'Road connection left.',
      'I am bill.',
    ],
    'The connection is bad.',
    'Waxay tilmaamaysaa xiriirka telefoonka.',
  );
  add(
    'multipleChoice',
    'Fariin reebid?',
    [
      'Can I leave a message?',
      'Can I leave a road?',
      'Message how much?',
      'I message is.',
    ],
    'Can I leave a message?',
    'Waa codsi fariin reebid.',
  );
  // 3 plans.
  add(
    'multipleChoice',
    'Qof kulan u soo jeedi?',
    [
      'Would you like to meet?',
      'Where is the bank?',
      'How much is it?',
      'Can you spell tea?',
    ],
    'Would you like to meet?',
    'Waa soo jeedin kulan.',
  );
  add(
    'multipleChoice',
    'Waqti ku heshiin?',
    [
      'Let’s meet at ten.',
      'Meet in ten dollars.',
      'Ten road meet.',
      'At meet is ten.',
    ],
    'Let’s meet at ten.',
    'At ten waa waqti kulan.',
  );
  add(
    'multipleChoice',
    'Waqtigaas mashquul?',
    [
      'Sorry, I am busy then.',
      'I busy road.',
      'No time bank.',
      'Then is busy me.',
    ],
    'Sorry, I am busy then.',
    'Waa diidmo edeb leh.',
  );
  // 3 directions.
  add(
    'multipleChoice',
    'Hospital raadis?',
    [
      'Excuse me, where is the hospital?',
      'Hospital how much?',
      'I order hospital.',
      'Call hospital tea.',
    ],
    'Excuse me, where is the hospital?',
    'Waa jid weydiin edeb leh.',
  );
  add(
    'multipleChoice',
    'Toos u soco kadib bidix?',
    [
      'Go straight, then turn left.',
      'Straight is left.',
      'Go left straight are.',
      'Then road.',
    ],
    'Go straight, then turn left.',
    'Sequence-ku waa sax.',
  );
  add(
    'multipleChoice',
    'How long does it take?',
    ['It takes ten minutes.', 'It is a bank.', 'I am a student.', 'Two teas.'],
    'It takes ten minutes.',
    'Su’aashu muddada ayay weydiinaysaa.',
  );
  // 3 best responses.
  add(
    'multipleChoice',
    'Can you repeat that?',
    [
      'Yes, of course.',
      'Five dollars.',
      'At the station.',
      'Rice and chicken.',
    ],
    'Yes, of course.',
    'Waa jawaab codsi.',
  );
  add(
    'multipleChoice',
    'Would you like some tea?',
    ['Yes, please.', 'Turn right.', 'I am twenty.', 'On Monday.'],
    'Yes, please.',
    'Waa jawaab offer.',
  );
  add(
    'multipleChoice',
    'I don’t understand.',
    [
      'I can explain it again.',
      'The bill is five.',
      'Good night morning.',
      'Take the road food.',
    ],
    'I can explain it again.',
    'Waa jawaab caawimo leh.',
  );
  // 2 dialogue comprehension.
  add(
    'readingComprehension',
    'A: Are you free Friday? B: Yes. Let’s meet at three at the café. Goormay kulmayaan?',
    ['Friday at three', 'Monday at ten', 'Friday at five', 'Tomorrow morning'],
    'Friday at three',
    'Dialogue-gu wuxuu sheegay Friday at three.',
  );
  add(
    'readingComprehension',
    'Customer: I ordered tea, not coffee. Waiter: Sorry. I can change it. Maxaa khaldan?',
    [
      'Coffee ayaa yimid halkii tea.',
      'Biil ma jiro.',
      'Jidku wuu lumay.',
      'Telefoonku wuu xun yahay.',
    ],
    'Coffee ayaa yimid halkii tea.',
    'Customer-ku tea ayuu dalbaday, coffee ayaa yimid.',
  );
  return q;
}
