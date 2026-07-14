import 'dart:convert';
import 'dart:io';

typedef Json = Map<String, dynamic>;

Json vocab(
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

Map<String, String> example(String english, String somali) => {
  'english': english,
  'somali': somali,
};

Json line(String speaker, String english, String somali) => {
  'speaker': speaker,
  'english': english,
  'somali': somali,
};

Json dialogue(String title, List<Json> lines) => {
  'titleSomali': title,
  'lines': lines,
};

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

Json grammar({
  required String titleEnglish,
  required String titleSomali,
  required String explanationSomali,
  required String rule,
  required String structure,
  required List<Map<String, String>> examples,
  required List<String> mistakes,
  List<Map<String, String>> negative = const [],
  List<Map<String, String>> questions = const [],
}) => {
  'titleEnglish': titleEnglish,
  'titleSomali': titleSomali,
  'explanationSomali': explanationSomali,
  'rule': rule,
  'sentenceStructure': structure,
  'positiveExamples': examples,
  'negativeExamples': negative,
  'questionExamples': questions,
  'commonMistakesSomali': mistakes,
  'practiceQuestions': const [],
};

List<Json> practices(
  String id,
  List<Json> words,
  List<Map<String, String>> examples, {
  required String fillQuestion,
  required List<String> fillOptions,
  required String fillAnswer,
  required String grammarQuestion,
  required List<String> grammarOptions,
  required String grammarAnswer,
  required String arrangeQuestion,
  required String arrangeAnswer,
  required String speaking,
  required String writing,
  bool review = false,
}) {
  final items = <Json>[
    exercise(
      '$id-p01',
      'multipleChoice',
      '“${words[0]['englishWord']}” maxay ka dhigan tahay?',
      [
        words[2]['somaliMeaning'] as String,
        words[0]['somaliMeaning'] as String,
        words[3]['somaliMeaning'] as String,
        words[1]['somaliMeaning'] as String,
      ],
      words[0]['somaliMeaning'] as String,
      '${words[0]['englishWord']} waxaa loola jeedaa ${words[0]['somaliMeaning']}.',
    ),
    exercise(
      '$id-p02',
      'fillInTheBlank',
      fillQuestion,
      fillOptions,
      fillAnswer,
      '“$fillAnswer” ayaa jumladda ka dhigaya mid sax ah.',
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
      '${words[1]['englishWord']} macnihiisu waa ${words[1]['somaliMeaning']}.',
    ),
    exercise(
      '$id-p04',
      'chooseGrammar',
      grammarQuestion,
      grammarOptions,
      grammarAnswer,
      'Qaabka saxda ahi waa “$grammarAnswer”. Xulashooyinka kale kuma waafaqsana subject-ka ama tirada.',
    ),
    exercise(
      '$id-p05',
      'arrangeSentence',
      arrangeQuestion,
      const [],
      arrangeAnswer,
      'Kala horreynta saxda ahi waa “$arrangeAnswer”.',
    ),
    exercise(
      '$id-p06',
      'englishToSomali',
      'Turjun: ${examples[0]['english']}',
      [
        examples[2]['somali']!,
        examples[4]['somali']!,
        examples[0]['somali']!,
        examples[1]['somali']!,
      ],
      examples[0]['somali']!,
      'Turjumaadda saxda ahi waxay gudbinaysaa macnaha jumladda oo dhan.',
    ),
    exercise(
      '$id-p07',
      'somaliToEnglish',
      'U beddel English: ${examples[1]['somali']}',
      [
        examples[3]['english']!,
        examples[1]['english']!,
        examples[0]['english']!,
        examples[4]['english']!,
      ],
      examples[1]['english']!,
      'Qaabka dabiiciga ah waa “${examples[1]['english']}”.',
    ),
    exercise(
      '$id-p08',
      'trueFalse',
      'Layliga qoyska iyo dadka waxaa lagu samayn karaa qof ama qoys male-awaal ah.',
      const ['True', 'False'],
      'True',
      'Xog dhab ah looma baahna; tusaale male-awaal ah ayaa ku filan.',
    ),
    exercise(
      '$id-p09',
      'speakingPrompt',
      speaking,
      const [],
      'Teacher review',
      'Si tartiib ah u hadal, isticmaal jumlado gaaban oo ixtiraam leh.',
    ),
    exercise(
      '$id-p10',
      'shortWriting',
      writing,
      const [],
      'Teacher review',
      'Hubi subject-ka, verb-ka iyo calaamadda dhammaadka jumlad kasta.',
    ),
  ];
  if (review) {
    items.addAll(reviewExercises(id));
  }
  return items;
}

List<Json> reviewExercises(String id) => [
  exercise(
    '$id-p11',
    'multipleChoice',
    'Children waa plural-ka eraygee?',
    ['Parent', 'Child', 'Cousin', 'Family'],
    'Child',
    'Hal waa child; wax ka badan hal waa children.',
  ),
  exercise(
    '$id-p12',
    'chooseGrammar',
    'She ___ two brothers.',
    ['have', 'has', 'having', 'do have'],
    'has',
    'She waxaa la socda has.',
  ),
  exercise(
    '$id-p13',
    'chooseGrammar',
    'Does he ___ a sister?',
    ['has', 'have', 'having', 'had'],
    'have',
    'Does ka dib waxaa yimaada have, ma aha has.',
  ),
  exercise(
    '$id-p14',
    'fillInTheBlank',
    'Amina is a student. ___ mother is a nurse.',
    ['His', 'Her', 'Their', 'Our'],
    'Her',
    'Amina waa she; possessive adjective-keedu waa her.',
  ),
  exercise(
    '$id-p15',
    'multipleChoice',
    'Kee ayaa tilmaamaya dabeecad?',
    ['Tall', 'Long hair', 'Kind', 'Brown eyes'],
    'Kind',
    'Kind waa dabeecad; kuwa kale waa muuqaal.',
  ),
  exercise(
    '$id-p16',
    'fillInTheBlank',
    '___ are my cousins over there.',
    ['This', 'That', 'These', 'Those'],
    'Those',
    'Dad badan oo fog waxaa lagu tilmaamaa those.',
  ),
  exercise(
    '$id-p17',
    'multipleChoice',
    'Su’aashee ayaa weydiinaysa muuqaalka?',
    [
      'What is he like?',
      'What does he look like?',
      'Who is he?',
      'Where is he?',
    ],
    'What does he look like?',
    'What does ... look like? wuxuu weydiiyaa muuqaalka.',
  ),
  exercise(
    '$id-p18',
    'somaliToEnglish',
    'U beddel: “Kani waa walaalkay.”',
    [
      'These are my brothers.',
      'This is my brother.',
      'That is my father.',
      'He have a brother.',
    ],
    'This is my brother.',
    'Qof keliya oo dhow: This is my brother.',
  ),
  exercise(
    '$id-p19',
    'englishToSomali',
    'Turjun: “Our teacher is patient.”',
    [
      'Macallinkoodu waa qosol badan yahay.',
      'Macallinkayagu waa dulqaad badan yahay.',
      'Macallinkaygu waa dheer yahay.',
      'Macallinkiinnu waa xishood badan yahay.',
    ],
    'Macallinkayagu waa dulqaad badan yahay.',
    'Our waa “-kayaga/-keenna”, patient-na waa dulqaad badan.',
  ),
  exercise(
    '$id-p20',
    'shortWriting',
    'Qor 5–7 jumladood oo qof male-awaal ah ku soo bandhigaya: xiriirka, da’da tusaalaha ah, shaqada, muuqaalka iyo dabeecadda.',
    const [],
    'Teacher review',
    'Isticmaal this is, he/she is, has iyo possessive adjective ku habboon.',
  ),
];

Json lesson({
  required int number,
  required String titleEnglish,
  required String titleSomali,
  required String description,
  required List<String> objectives,
  required String type,
  required int minutes,
  required List<Json> vocabulary,
  Json? grammarTopic,
  required List<Map<String, String>> examples,
  required List<Json> dialogues,
  required List<Json> exercises,
  required String speaking,
  required String writing,
  required String summary,
}) {
  final id = 'a1-u04-l${number.toString().padLeft(2, '0')}';
  return {
    'id': id,
    'levelId': 'A1',
    'unitId': 'a1-u04',
    'lessonNumber': number,
    'titleEnglish': titleEnglish,
    'titleSomali': titleSomali,
    'shortDescriptionSomali': description,
    'learningObjectives': objectives,
    'lessonType': type,
    'estimatedMinutes': minutes,
    'difficulty': 'beginner',
    'isLocked': number != 1,
    'requiredPreviousLessonId': number == 1
        ? null
        : 'a1-u04-l${(number - 1).toString().padLeft(2, '0')}',
    'vocabulary': vocabulary,
    'grammar': grammarTopic,
    'examples': examples,
    'dialogues': dialogues,
    'practiceExercises': exercises,
    'speakingPractice': speaking,
    'writingPractice': writing,
    'summarySomali': summary,
    'quizQuestions': exercises
        .take(3)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => {
            ...entry.value,
            'id': '$id-q${(entry.key + 1).toString().padLeft(2, '0')}',
          },
        )
        .toList(),
  };
}

List<Json> familyVocabulary() => [
  vocab(
    'Family',
    'Qoys',
    'noun',
    'fa-ma-li',
    'My family lives in Somalia.',
    'Qoyskaygu wuxuu ku nool yahay Soomaaliya.',
    'Family waa dadka qoys ahaan isku xiran.',
  ),
  vocab(
    'Father',
    'Aabbe',
    'noun',
    'faa-dhar',
    'My father is a teacher.',
    'Aabbahay waa macallin.',
    'Father waa waalidka labka ah.',
  ),
  vocab(
    'Mother',
    'Hooyo',
    'noun',
    'ma-dhar',
    'My mother is kind.',
    'Hooyaday waa naxariis badan tahay.',
    'Mother waa waalidka dheddigga ah.',
  ),
  vocab(
    'Parents',
    'Waalid',
    'plural noun',
    'pe-rants',
    'My parents live together.',
    'Waalidkay waxay wada nool yihiin.',
    'Parents waa father iyo mother ama dadka ku koriya.',
    'Parent waa hal waalid; parents waa laba ama ka badan.',
  ),
  vocab(
    'Son',
    'Wiil uu qof dhalay',
    'noun',
    'san',
    'Their son is a student.',
    'Wiilkoodu waa arday.',
    'Son waa wiilka uu qof waalid u yahay.',
  ),
  vocab(
    'Daughter',
    'Gabar uu qof dhalay',
    'noun',
    'doo-tar',
    'Their daughter is young.',
    'Gabadhoodu waa yar tahay.',
    'Daughter waa gabadha uu qof waalid u yahay.',
  ),
  vocab(
    'Brother',
    'Walaal lab',
    'noun',
    'bra-dhar',
    'I have one brother.',
    'Waxaan leeyahay hal walaal oo lab ah.',
    'Brother waa walaal lab.',
  ),
  vocab(
    'Sister',
    'Walaal dhedig',
    'noun',
    'sis-tar',
    'She has two sisters.',
    'Waxay leedahay laba walaalo oo dhedig ah.',
    'Sister waa walaal dhedig.',
  ),
  vocab(
    'Husband',
    'Sayg',
    'noun',
    'has-band',
    'Her husband is friendly.',
    'Saygeedu waa saaxiibtinimo badan yahay.',
    'Husband waa ninka xaas leh.',
  ),
  vocab(
    'Wife',
    'Xaas',
    'noun',
    'waayf',
    'His wife is helpful.',
    'Xaaskiisu waa caawimo badan tahay.',
    'Wife waa haweeneyda xaas ah.',
  ),
  vocab(
    'Child',
    'Ilmo',
    'noun',
    'chaayld',
    'The child is happy.',
    'Ilmuhu waa faraxsan yahay.',
    'Child waa hal ilmo.',
    'Plural-ka child waa children, ma aha childs.',
  ),
  vocab(
    'Children',
    'Carruur',
    'plural noun',
    'chil-dran',
    'The children are at school.',
    'Carruurtu waxay joogaan iskuulka.',
    'Children waa wax ka badan hal child.',
  ),
  vocab(
    'Grandfather',
    'Awoowe',
    'noun',
    'gran-faa-dhar',
    'My grandfather is patient.',
    'Awoowahay waa dulqaad badan yahay.',
    'Grandfather waa aabbaha aabbaha ama hooyada.',
  ),
  vocab(
    'Grandmother',
    'Ayeeyo',
    'noun',
    'gran-ma-dhar',
    'My grandmother is kind.',
    'Ayeeyaday waa naxariis badan tahay.',
    'Grandmother waa hooyada aabbaha ama hooyada.',
  ),
  vocab(
    'Grandparents',
    'Awoowe iyo ayeeyo',
    'plural noun',
    'gran-pe-rants',
    'Our grandparents live nearby.',
    'Awoowahayaga iyo ayeeyadayadu meel dhow ayay deggan yihiin.',
    'Grandparents waa awoowe iyo ayeeyo.',
  ),
  vocab(
    'Uncle',
    'Adeer ama abti',
    'noun',
    'an-kal',
    'My uncle works in a shop.',
    'Adeerkay ama abtigey wuxuu ka shaqeeyaa dukaan.',
    'Uncle wuxuu noqon karaa walaalka aabbaha ama hooyada.',
  ),
  vocab(
    'Aunt',
    'Eeddo ama habaryar',
    'noun',
    'aant',
    'My aunt is a nurse.',
    'Eeddaday ama habaryartay waa kalkaaliso.',
    'Aunt waxay noqon kartaa walaasha aabbaha ama hooyada.',
  ),
  vocab(
    'Cousin',
    'Ina-adeer/ina-abti/ina-eeddo/ina-habaryar',
    'noun',
    'ka-zan',
    'My cousin is my friend.',
    'Qaraabadayda cousin-ka ahi waa saaxiibkay.',
    'Cousin waa ilmaha uncle ama aunt.',
  ),
  vocab(
    'Nephew',
    'Wiilka walaalka ama walaasha',
    'noun',
    'ne-fyuu',
    'My nephew is five.',
    'Wiilka walaalkay ama walaashay waa shan jir.',
    'Nephew waa wiilka uu dhalay walaalka ama walaasha.',
  ),
  vocab(
    'Niece',
    'Gabadha walaalka ama walaasha',
    'noun',
    'niis',
    'My niece is a student.',
    'Gabadha walaalkay ama walaashay waa ardayad.',
    'Niece waa gabadha uu dhalay walaalka ama walaasha.',
  ),
];

List<Json> talkingVocabulary() => [
  vocab(
    'Small family',
    'Qoys yar',
    'noun phrase',
    'smool fa-ma-li',
    'I have a small family.',
    'Waxaan leeyahay qoys yar.',
    'Small family waa qoys xubnihiisu tiro yar yihiin.',
  ),
  vocab(
    'Large family',
    'Qoys weyn',
    'noun phrase',
    'laarj fa-ma-li',
    'They have a large family.',
    'Waxay leeyihiin qoys weyn.',
    'Large family waa qoys xubno badan leh.',
  ),
  vocab(
    'Together',
    'Wadajir',
    'adverb',
    'ta-ge-dhar',
    'We live together.',
    'Waxaan u wada nool nahay si wadajir ah.',
    'Together wuxuu muujinayaa in dadku meel ama hawl wadaagaan.',
  ),
  vocab(
    'Live with',
    'La noolow',
    'verb phrase',
    'liv with',
    'I live with my parents.',
    'Waxaan la noolahay waalidkay.',
    'Live with waxaa lagu sheegaa qofka aad la nooshahay.',
  ),
  vocab(
    'People',
    'Dad',
    'plural noun',
    'pii-pal',
    'There are five people in the family.',
    'Qoyska waxaa ku jira shan qof.',
    'People waa plural-ka caadiga ah ee person.',
  ),
  vocab(
    'Teacher',
    'Macallin',
    'noun',
    'tii-char',
    'My father is a teacher.',
    'Aabbahay waa macallin.',
    'Teacher waa qof wax bara.',
  ),
  vocab(
    'Hospital',
    'Isbitaal',
    'noun',
    'hos-pi-tal',
    'My mother works at a hospital.',
    'Hooyaday waxay ka shaqaysaa isbitaal.',
    'Hospital waa goob caafimaad.',
  ),
  vocab(
    'Who do you live with?',
    'Yaad la nooshahay?',
    'question phrase',
    'huu duu yuu liv with',
    'Who do you live with?',
    'Yaad la nooshahay?',
    'Su’aashan waxay weydiinaysaa dadka kula nool.',
  ),
];

List<Json> haveVocabulary() => [
  vocab(
    'Have',
    'Lahow/hayso',
    'verb',
    'hav',
    'I have a brother.',
    'Waxaan leeyahay walaal lab.',
    'Have waxaa lala isticmaalaa I, you, we iyo they.',
  ),
  vocab(
    'Has',
    'Leeyahay/leedahay',
    'verb',
    'haz',
    'She has one sister.',
    'Waxay leedahay hal walaal dhedig.',
    'Has waxaa lala isticmaalaa he, she iyo it.',
  ),
  vocab(
    'Do',
    'Kaaliyaha su’aasha',
    'auxiliary verb',
    'duu',
    'Do you have children?',
    'Carruur ma leedahay?',
    'Do wuxuu su’aal la sameeyaa I/you/we/they.',
  ),
  vocab(
    'Does',
    'Kaaliyaha su’aasha',
    'auxiliary verb',
    'daz',
    'Does he have a brother?',
    'Walaal lab ma leeyahay?',
    'Does wuxuu su’aal la sameeyaa he/she/it.',
  ),
  vocab(
    "Don't",
    'Ma lihi/ma laha',
    'negative auxiliary',
    'doont',
    "I don't have a sister.",
    'Ma lihi walaal dhedig.',
    "Don't waa do not oo la soo gaabiyey.",
  ),
  vocab(
    "Doesn't",
    'Ma leh',
    'negative auxiliary',
    'da-zant',
    "He doesn't have a brother.",
    'Ma laha walaal lab.',
    "Doesn't waa does not oo la soo gaabiyey.",
  ),
  vocab(
    'One',
    'Hal',
    'number',
    'wan',
    'He has one sister.',
    'Wuxuu leeyahay hal walaal dhedig.',
    'One waxaa lala isticmaalaa magac singular ah.',
  ),
  vocab(
    'Any',
    'Wax/kuwo',
    'determiner',
    'e-ni',
    'Do you have any cousins?',
    'Ma leedahay cousins?',
    'Any wuxuu inta badan yimaadaa su’aal ama negative.',
  ),
];

List<Json> possessiveVocabulary() => [
  vocab(
    'My',
    'Kayga/tayda',
    'possessive adjective',
    'maay',
    'My father is kind.',
    'Aabbahay waa naxariis badan yahay.',
    'My wuxuu muujinayaa wax aniga iga tirsan.',
  ),
  vocab(
    'Your',
    'Kaaga/taada',
    'possessive adjective',
    'yoor',
    'Your sister is a student.',
    'Walaashaa waa ardayad.',
    'Your wuxuu muujinayaa wax adiga kaa tirsan.',
  ),
  vocab(
    'His',
    'Kiisa/tiisa (lab)',
    'possessive adjective',
    'hiz',
    'His brother is tall.',
    'Walaalkiis waa dheer yahay.',
    'His waxaa lala xiriiriyaa he.',
  ),
  vocab(
    'Her',
    'Keeda/teeda (dhedig)',
    'possessive adjective',
    'har',
    'Her mother is friendly.',
    'Hooyadeed waa saaxiibtinimo badan tahay.',
    'Her waxaa lala xiriiriyaa she.',
  ),
  vocab(
    'Its',
    'Kiisa/teeda (shay ama xayawaan)',
    'possessive adjective',
    'its',
    'The cat is with its family.',
    'Bisaddu waxay la joogtaa qoyskeeda.',
    'Its waxaa loo adeegsadaa shay ama xayawaan.',
    "Ha ku darin apostrophe; it's waxay ka dhigan tahay it is.",
  ),
  vocab(
    'Our',
    'Kayaga/keenna',
    'possessive adjective',
    'aawar',
    'Our family is small.',
    'Qoyskayagu waa yar yahay.',
    'Our waxaa lala xiriiriyaa we.',
  ),
  vocab(
    'Their',
    'Kooda/tooda',
    'possessive adjective',
    'dheer',
    'Their children are happy.',
    'Carruurtoodu waa faraxsan yihiin.',
    'Their waxaa lala xiriiriyaa they.',
  ),
];

List<Json> appearanceVocabulary() => [
  vocab(
    'Tall',
    'Dheer',
    'adjective',
    'tool',
    'He is tall.',
    'Wuu dheer yahay.',
    'Tall wuxuu tilmaamaa dhererka qofka.',
  ),
  vocab(
    'Short',
    'Gaaban',
    'adjective',
    'shoort',
    'She is short.',
    'Way gaaban tahay.',
    'Short halkan wuxuu tilmaamayaa dherer gaaban.',
  ),
  vocab(
    'Young',
    'Da’ yar',
    'adjective',
    'yang',
    'My brother is young.',
    'Walaalkay waa da’ yar yahay.',
    'Young wuxuu tilmaamaa qof da’ yar.',
  ),
  vocab(
    'Old',
    'Da’ weyn',
    'adjective',
    'oold',
    'My grandfather is old.',
    'Awoowahay waa da’ weyn yahay.',
    'Old halkan wuxuu si xushmad leh u tilmaamaa da’ weyn.',
  ),
  vocab(
    'Thin',
    'Jir dhuuban',
    'adjective',
    'thin',
    'The man is thin.',
    'Ninku waa jir dhuuban yahay.',
    'Thin waa sharaxaad muuqaal; si ixtiraam leh u isticmaal.',
  ),
  vocab(
    'Strong',
    'Xoog badan',
    'adjective',
    'strong',
    'She is strong.',
    'Way xoog badan tahay.',
    'Strong wuxuu tilmaamaa xoog.',
  ),
  vocab(
    'Beautiful',
    'Qurux badan',
    'adjective',
    'byuu-ti-fal',
    'She is beautiful.',
    'Way qurux badan tahay.',
    'Beautiful waa sharaxaad wanaagsan.',
  ),
  vocab(
    'Handsome',
    'Muuqaal wanaagsan',
    'adjective',
    'han-sam',
    'He is handsome.',
    'Muuqaalkiisu waa wanaagsan yahay.',
    'Handsome badanaa waxaa lagu tilmaamaa nin ama wiil.',
  ),
  vocab(
    'Long hair',
    'Timo dheer',
    'noun phrase',
    'long heer',
    'She has long hair.',
    'Waxay leedahay timo dheer.',
    'Hair waxaa lala isticmaalaa has marka la sheegayo waxa qof leeyahay.',
  ),
  vocab(
    'Short hair',
    'Timo gaaban',
    'noun phrase',
    'shoort heer',
    'He has short hair.',
    'Wuxuu leeyahay timo gaaban.',
    'Short hair waa timo aan dheerayn.',
  ),
  vocab(
    'Black hair',
    'Timo madow',
    'noun phrase',
    'blak heer',
    'He has black hair.',
    'Wuxuu leeyahay timo madow.',
    'Midabka hair wuxuu yimaadaa hair ka hor.',
  ),
  vocab(
    'Brown eyes',
    'Indho bunni ah',
    'noun phrase',
    'braawn aayz',
    'She has brown eyes.',
    'Waxay leedahay indho bunni ah.',
    'Eyes waa plural, laakiin lahaanshaha waxaa xukuma subject-ka: she has.',
  ),
  vocab(
    'Big',
    'Weyn',
    'adjective',
    'big',
    'He has big eyes.',
    'Wuxuu leeyahay indho waaweyn.',
    'Big wuxuu tilmaamaa cabbir weyn.',
  ),
  vocab(
    'Small',
    'Yar',
    'adjective',
    'smool',
    'She has small hands.',
    'Waxay leedahay gacmo yaryar.',
    'Small wuxuu tilmaamaa cabbir yar.',
  ),
];

List<Json> personalityVocabulary() => [
  vocab(
    'Kind',
    'Naxariis badan',
    'adjective',
    'kaaynd',
    'My mother is kind.',
    'Hooyaday waa naxariis badan tahay.',
    'Kind wuxuu tilmaamaa qof dadka si wanaagsan ula dhaqma.',
  ),
  vocab(
    'Friendly',
    'Saaxiibtinimo badan',
    'adjective',
    'frend-li',
    'She is very friendly.',
    'Aad bay saaxiibtinimo badan u tahay.',
    'Friendly waa qof si wanaagsan dadka ula macaamila.',
  ),
  vocab(
    'Helpful',
    'Caawimo badan',
    'adjective',
    'help-fal',
    'My friend is helpful.',
    'Saaxiibkay waa caawimo badan yahay.',
    'Helpful waa qof dadka caawiya.',
  ),
  vocab(
    'Happy',
    'Faraxsan',
    'adjective',
    'ha-pi',
    'The child is happy.',
    'Ilmuhu waa faraxsan yahay.',
    'Happy wuxuu tilmaamaa dareen farxad.',
  ),
  vocab(
    'Quiet',
    'Hadal yar/deggan',
    'adjective',
    'kwaa-yat',
    'He is quiet.',
    'Waa hadal yar yahay.',
    'Quiet waa qof ama meel aan buuq badnayn.',
  ),
  vocab(
    'Funny',
    'Qosol badan',
    'adjective',
    'fa-ni',
    'My cousin is funny.',
    'Cousinkaygu waa qosol badan yahay.',
    'Funny waa qof dadka ka qosliya.',
  ),
  vocab(
    'Polite',
    'Edeb badan',
    'adjective',
    'pa-laayt',
    'The student is polite.',
    'Ardaygu waa edeb badan yahay.',
    'Polite wuxuu tilmaamaa edeb iyo ixtiraam.',
  ),
  vocab(
    'Honest',
    'Daacad ah',
    'adjective',
    'o-nist',
    'Her sister is honest.',
    'Walaasheed waa daacad.',
    'Honest waa qof run iyo daacadnimo leh.',
  ),
  vocab(
    'Hard-working',
    'Hawl-kar ah',
    'adjective',
    'haard-wer-king',
    'Our father is hard-working.',
    'Aabbahayagu waa hawl-kar.',
    'Hard-working wuxuu tilmaamaa qof dadaal badan.',
  ),
  vocab(
    'Shy',
    'Xishood badan',
    'adjective',
    'shaay',
    'The new student is shy.',
    'Ardayga cusub waa xishood badan yahay.',
    'Shy waa qof ka xishooda la hadalka dadka qaarkood.',
  ),
  vocab(
    'Clever',
    'Fahmo badan',
    'adjective',
    'kle-var',
    'She is clever.',
    'Way fahmo badan tahay.',
    'Clever wuxuu tilmaamaa qof si fiican wax u fahma.',
  ),
  vocab(
    'Patient',
    'Dulqaad badan',
    'adjective',
    'pey-shant',
    'Our teacher is patient.',
    'Macallinkayagu waa dulqaad badan yahay.',
    'Patient halkan waa adjective micnihiisuna yahay dulqaad badan.',
  ),
];

List<Json> demonstrativeVocabulary() => [
  vocab(
    'This',
    'Kani/tani (dhow, hal)',
    'demonstrative',
    'dhis',
    'This is my brother.',
    'Kani waa walaalkay.',
    'This waxaa loo adeegsadaa hal qof ama shay oo dhow.',
  ),
  vocab(
    'That',
    'Kaas/taasi (fog, hal)',
    'demonstrative',
    'dhat',
    'That is my teacher.',
    'Kaas waa macallinkay.',
    'That waxaa loo adeegsadaa hal qof ama shay oo fog.',
  ),
  vocab(
    'These',
    'Kuwani (dhow, badan)',
    'demonstrative',
    'dhiiz',
    'These are my friends.',
    'Kuwani waa saaxiibbaday.',
    'These waxaa loo adeegsadaa dad ama waxyaabo badan oo dhow.',
  ),
  vocab(
    'Those',
    'Kuwaas (fog, badan)',
    'demonstrative',
    'dhooz',
    'Those are my cousins.',
    'Kuwaas waa cousins-kayga.',
    'Those waxaa loo adeegsadaa dad ama waxyaabo badan oo fog.',
  ),
  vocab(
    'Near',
    'Dhow',
    'adjective',
    'niir',
    'These people are near.',
    'Dadkani way dhow yihiin.',
    'Near wuxuu tilmaamaa meel dhow.',
  ),
  vocab(
    'Far',
    'Fog',
    'adjective',
    'faar',
    'Those people are far away.',
    'Dadkaas way fog yihiin.',
    'Far wuxuu tilmaamaa meel fog.',
  ),
  vocab(
    'Who is this?',
    'Kani/tani waa kuma?',
    'question phrase',
    'huu iz dhis',
    'Who is this?',
    'Kani waa kuma?',
    'Su’aashan waxaa la weydiiyaa qof keliya oo dhow.',
  ),
  vocab(
    'Who are those people?',
    'Dadkaas waa ayo?',
    'question phrase',
    'huu aar dhooz pii-pal',
    'Who are those people?',
    'Dadkaas waa ayo?',
    'Are waxaa lala isticmaalaa those iyo people.',
  ),
];

List<Json> askingVocabulary() => [
  vocab(
    'Who is he?',
    'Isagu waa kuma?',
    'question phrase',
    'huu iz hii',
    'Who is he?',
    'Isagu waa kuma?',
    'Who wuxuu weydiinayaa aqoonsiga qofka.',
  ),
  vocab(
    'Who is she?',
    'Iyadu waa kuma?',
    'question phrase',
    'huu iz shii',
    'Who is she?',
    'Iyadu waa kuma?',
    'She waa qof dhedig ah.',
  ),
  vocab(
    'Who are they?',
    'Iyagu waa ayo?',
    'question phrase',
    'huu aar dhey',
    'Who are they?',
    'Iyagu waa ayo?',
    'They waa dad badan.',
  ),
  vocab(
    'Is he your brother?',
    'Ma walaalkaa baa?',
    'yes/no question',
    'iz hii yoor bra-dhar',
    'Is he your brother?',
    'Ma walaalkaa baa?',
    'Is + he wuxuu sameeyaa su’aal yes/no ah.',
  ),
  vocab(
    'Are they your friends?',
    'Ma saaxiibbadaa baa?',
    'yes/no question',
    'aar dhey yoor frendz',
    'Are they your friends?',
    'Ma saaxiibbadaa baa?',
    'Are waxaa lala isticmaalaa they.',
  ),
  vocab(
    'What is he like?',
    'Dabeecaddiisu waa sidee?',
    'question phrase',
    'wot iz hii laayk',
    'What is he like?',
    'Dabeecaddiisu waa sidee?',
    'Su’aashani badanaa waxay weydiinaysaa dabeecadda.',
  ),
  vocab(
    'What does she look like?',
    'Muuqaalkeedu waa sidee?',
    'question phrase',
    'wot daz shii luk laayk',
    'What does she look like?',
    'Muuqaalkeedu waa sidee?',
    'Su’aashani waxay weydiinaysaa muuqaalka.',
  ),
  vocab(
    'How old is he?',
    'Immisa jir buu yahay?',
    'question phrase',
    'haw oold iz hii',
    'How old is he?',
    'Immisa jir buu yahay?',
    'How old wuxuu weydiinayaa da’da.',
  ),
  vocab(
    'Where does she live?',
    'Xaggee ayay degan tahay?',
    'question phrase',
    'weer daz shii liv',
    'Where does she live?',
    'Xaggee ayay degan tahay?',
    'Where wuxuu weydiinayaa meel.',
  ),
  vocab(
    'People',
    'Dad',
    'plural noun',
    'pii-pal',
    'Those people are friendly.',
    'Dadkaas waa saaxiibtinimo badan yihiin.',
    'People waxaa lala isticmaalaa are.',
  ),
];

List<Json> introducingVocabulary() => [
  vocab(
    'This is…',
    'Kani/tani waa…',
    'introduction phrase',
    'dhis iz',
    'This is my sister, Amina.',
    'Tani waa walaashay, Amina.',
    'This is waxaa lagu bilaabaa soo bandhigid qof dhow.',
  ),
  vocab(
    'Meet',
    'La kulan/baro',
    'verb',
    'miit',
    'Meet my friend, Omar.',
    'La kulan saaxiibkay, Omar.',
    'Meet waxaa lagu casuumaa qof inuu qof kale barto.',
  ),
  vocab(
    'Student',
    'Arday',
    'noun',
    'stuu-dant',
    'She is a student.',
    'Waa ardayad.',
    'Student waa qof wax barta.',
  ),
  vocab(
    'Friend',
    'Saaxiib',
    'noun',
    'frend',
    'He is my friend.',
    'Waa saaxiibkay.',
    'Friend waa qof aad saaxiib tihiin.',
  ),
  vocab(
    'Teacher',
    'Macallin',
    'noun',
    'tii-char',
    'This is our teacher.',
    'Kani waa macallinkayaga.',
    'Teacher waa qof wax bara.',
  ),
  vocab(
    'Coworker',
    'Qof aad wada shaqaysaan',
    'noun',
    'koo-wer-kar',
    'She is my coworker.',
    'Waa qof aan wada shaqayno.',
    'Coworker waa qof isku goob ama shaqo ka wada shaqaysaan.',
  ),
  vocab(
    'Lives',
    'Wuxuu/waxay deggan yahay/tahay',
    'verb',
    'livz',
    'She lives in Mogadishu.',
    'Waxay deggan tahay Muqdisho.',
    'Lives waxaa lala isticmaalaa he ama she.',
  ),
  vocab(
    'Works',
    'Wuxuu/waxay shaqeeyaa/shaqaysaa',
    'verb',
    'werks',
    'He works at a school.',
    'Wuxuu ka shaqeeyaa iskuul.',
    'Works waxaa lala isticmaalaa he ama she.',
  ),
];

List<Json> reviewVocabulary() => [
  vocab(
    'Family member',
    'Xubin qoys',
    'noun phrase',
    'fa-ma-li mem-bar',
    'Describe a family member.',
    'Sharax xubin qoys.',
    'Family member waa qof qoyska ka tirsan.',
  ),
  vocab(
    'Have or has',
    'Lahow: have ama has',
    'grammar phrase',
    'hav oor haz',
    'Choose have or has.',
    'Dooro have ama has.',
    'Doorashadu waxay ku xiran tahay subject-ka.',
  ),
  vocab(
    'Possessive adjective',
    'Eray lahaansho',
    'grammar term',
    'pa-ze-siv ajek-tiv',
    'My is a possessive adjective.',
    'My waa eray lahaansho.',
    'Wuxuu yimaadaa magaca ka hor.',
  ),
  vocab(
    'Appearance',
    'Muuqaal',
    'noun',
    'a-pii-rans',
    'Describe her appearance.',
    'Sharax muuqaalkeeda.',
    'Appearance waa sida qofku u muuqdo.',
  ),
  vocab(
    'Personality',
    'Dabeecad',
    'noun',
    'per-sa-na-li-ti',
    'Describe his personality.',
    'Sharax dabeecaddiisa.',
    'Personality waa sida qofku dabeecad ahaan yahay.',
  ),
  vocab(
    'Near',
    'Dhow',
    'adjective',
    'niir',
    'This person is near.',
    'Qofkani waa dhow yahay.',
    'Near wuxuu la xiriiraa this iyo these.',
  ),
  vocab(
    'Far',
    'Fog',
    'adjective',
    'faar',
    'Those people are far.',
    'Dadkaas waa fog yihiin.',
    'Far wuxuu la xiriiraa that iyo those.',
  ),
  vocab(
    'Introduce',
    'Soo bandhig',
    'verb',
    'in-tra-dyuus',
    'Introduce your example friend.',
    'Soo bandhig saaxiib tusaale ah.',
    'Introduce waa qof kale barid.',
  ),
  vocab(
    'Describe',
    'Sharax',
    'verb',
    'dis-kraayb',
    'Describe a fictional person.',
    'Sharax qof male-awaal ah.',
    'Describe waa bixinta faahfaahin.',
  ),
];

List<Json> twoDialogues(int lessonNumber) {
  switch (lessonNumber) {
    case 1:
      return [
        dialogue('Sawir qoys', [
          line('Asha', 'Who is this?', 'Kani waa kuma?'),
          line('Omar', 'This is my mother.', 'Tani waa hooyaday.'),
          line('Asha', 'And those people?', 'Dadkaasna?'),
          line(
            'Omar',
            'They are my grandparents.',
            'Waa awoowahay iyo ayeeyaday.',
          ),
        ]),
        dialogue('Family tree tusaale ah', [
          line(
            'Teacher',
            'Yusuf and Maryan are the parents.',
            'Yusuf iyo Maryan waa waalidka.',
          ),
          line('Student', 'Who are their children?', 'Carruurtoodu waa ayo?'),
          line(
            'Teacher',
            'Ali is their son and Amina is their daughter.',
            'Ali waa wiilkooda, Amina-na waa gabadhooda.',
          ),
          line('Student', 'I understand.', 'Waan fahmay.'),
        ]),
      ];
    case 2:
      return [
        dialogue('Laba arday oo qoys tusaale ah ka hadlaya', [
          line(
            'Hodan',
            'How many people are in your example family?',
            'Immisa qof ayaa ku jira qoyskaaga tusaalaha ah?',
          ),
          line('Samir', 'There are five people.', 'Waxaa ku jira shan qof.'),
          line(
            'Hodan',
            'Do you have any brothers?',
            'Ma leedahay walaalo lab?',
          ),
          line(
            'Samir',
            'Yes, I have two brothers.',
            'Haa, waxaan leeyahay laba walaalo lab.',
          ),
        ]),
        dialogue('Qofka lala nool yahay', [
          line(
            'Teacher',
            'Who do you live with in this example?',
            'Tusaalahan yaad la nooshahay?',
          ),
          line(
            'Student',
            'I live with my parents.',
            'Waxaan la noolahay waalidkay.',
          ),
          line(
            'Teacher',
            'What does your mother do?',
            'Hooyadaa maxay qabataa?',
          ),
          line(
            'Student',
            'She works at a hospital.',
            'Waxay ka shaqaysaa isbitaal.',
          ),
        ]),
      ];
    case 3:
      return [
        dialogue('Have iyo has', [
          line('A', 'Do you have a sister?', 'Ma leedahay walaal dhedig?'),
          line(
            'B',
            'Yes, I have one sister.',
            'Haa, waxaan leeyahay hal walaal dhedig.',
          ),
          line('A', 'Does she have children?', 'Carruur ma leedahay?'),
          line('B', 'No, she does not have children.', 'Maya, carruur ma leh.'),
        ]),
        dialogue('Saxidda khalad', [
          line('Student', 'Does he has a brother?', 'Ma leeyahay walaal lab?'),
          line(
            'Teacher',
            'Say: Does he have a brother?',
            'Dheh: Does he have a brother?',
          ),
          line('Student', 'Does he have a brother?', 'Ma leeyahay walaal lab?'),
          line('Teacher', 'Correct.', 'Waa sax.'),
        ]),
      ];
    case 4:
      return [
        dialogue('Sawirka qoyska', [
          line('A', 'Who is she?', 'Iyadu waa kuma?'),
          line(
            'B',
            'She is Amina. Her mother is a nurse.',
            'Waa Amina. Hooyadeed waa kalkaaliso.',
          ),
          line('A', 'Who is he?', 'Isagu waa kuma?'),
          line(
            'B',
            'He is Ali. His father is a teacher.',
            'Waa Ali. Aabbihiis waa macallin.',
          ),
        ]),
        dialogue('Qoysas', [
          line('A', 'Our family is small.', 'Qoyskayagu waa yar yahay.'),
          line('B', 'Their family is large.', 'Qoyskoodu waa weyn yahay.'),
          line(
            'A',
            'Are their children students?',
            'Carruurtoodu ma arday baa?',
          ),
          line('B', 'Yes, they are.', 'Haa, waa arday.'),
        ]),
      ];
    case 5:
      return [
        dialogue('Muuqaalka qof', [
          line('A', 'What does he look like?', 'Muuqaalkiisu waa sidee?'),
          line(
            'B',
            'He is tall and he has short hair.',
            'Wuu dheer yahay, wuxuuna leeyahay timo gaaban.',
          ),
          line(
            'A',
            'What color is his hair?',
            'Midabkee ayay timihiisu yihiin?',
          ),
          line('B', 'He has black hair.', 'Wuxuu leeyahay timo madow.'),
        ]),
        dialogue('Sharaxaad ixtiraam leh', [
          line(
            'A',
            'Describe the woman in the example.',
            'Sharax haweeneyda tusaalaha ah.',
          ),
          line(
            'B',
            'She has long hair and brown eyes.',
            'Waxay leedahay timo dheer iyo indho bunni ah.',
          ),
          line('A', 'Is she young?', 'Ma da’ yar tahay?'),
          line('B', 'Yes, she is young.', 'Haa, waa da’ yar tahay.'),
        ]),
      ];
    case 6:
      return [
        dialogue('Dabeecadda saaxiib', [
          line(
            'A',
            'What is your example friend like?',
            'Saaxiibkaaga tusaalaha ahi dabeecad ahaan waa sidee?',
          ),
          line(
            'B',
            'She is friendly and helpful.',
            'Waa saaxiibtinimo iyo caawimo badan tahay.',
          ),
          line('A', 'Is she funny?', 'Ma qosol badan tahay?'),
          line('B', 'Yes, she is.', 'Haa, waa sidaas.'),
        ]),
        dialogue('Macallin dulqaad badan', [
          line(
            'Student',
            'Our teacher is patient.',
            'Macallinkayagu waa dulqaad badan yahay.',
          ),
          line('Worker', 'Is he quiet?', 'Ma hadal yar yahay?'),
          line(
            'Student',
            'Yes, and he is polite.',
            'Haa, sidoo kale waa edeb badan yahay.',
          ),
          line(
            'Worker',
            'He sounds kind.',
            'Wuxuu u muuqdaa qof naxariis badan.',
          ),
        ]),
      ];
    case 7:
      return [
        dialogue('Dad dhow iyo fog', [
          line('A', 'Who is this?', 'Kani waa kuma?'),
          line('B', 'This is my brother.', 'Kani waa walaalkay.'),
          line('A', 'Who are those people?', 'Dadkaas waa ayo?'),
          line('B', 'Those are my cousins.', 'Kuwaas waa cousins-kayga.'),
        ]),
        dialogue('Saaxiibbada sawirka', [
          line('A', 'Are these your friends?', 'Kuwani ma saaxiibbadaa baa?'),
          line(
            'B',
            'Yes, these are my friends.',
            'Haa, kuwani waa saaxiibbaday.',
          ),
          line('A', 'Is that your teacher?', 'Kaas ma macallinkaaga baa?'),
          line(
            'B',
            'No, that is my uncle.',
            'Maya, kaas waa adeerkay/abtigey.',
          ),
        ]),
      ];
    case 8:
      return [
        dialogue('Qofka sawirka ku jira', [
          line('A', 'Who is she?', 'Iyadu waa kuma?'),
          line('B', 'She is my teacher.', 'Waa macallimaddayda.'),
          line('A', 'What is she like?', 'Dabeecaddeedu waa sidee?'),
          line(
            'B',
            'She is kind and patient.',
            'Waa naxariis iyo dulqaad badan tahay.',
          ),
        ]),
        dialogue('Qof cusub', [
          line('Worker', 'Who is he?', 'Isagu waa kuma?'),
          line(
            'Colleague',
            'He is our new coworker.',
            'Waa qofka cusub ee nala shaqeeya.',
          ),
          line('Worker', 'What does he look like?', 'Muuqaalkiisu waa sidee?'),
          line(
            'Colleague',
            'He is tall and has short hair.',
            'Wuu dheer yahay, timo gaabanna wuu leeyahay.',
          ),
        ]),
      ];
    case 9:
      return [
        dialogue('Soo bandhigid saaxiib', [
          line(
            'Amina',
            'This is my friend, Hani.',
            'Tani waa saaxiibadday Hani.',
          ),
          line(
            'Hani',
            'Nice to meet you.',
            'Waan ku faraxsanahay inaan kula kulmo.',
          ),
          line('Omar', 'What is she like?', 'Dabeecaddeedu waa sidee?'),
          line(
            'Amina',
            'She is friendly and helpful.',
            'Waa saaxiibtinimo iyo caawimo badan tahay.',
          ),
        ]),
        dialogue('Soo bandhigid coworker', [
          line(
            'Worker',
            'Meet our coworker, Ali.',
            'La kulan qofka nala shaqeeya, Ali.',
          ),
          line('Ali', 'Hello.', 'Salaan.'),
          line(
            'Worker',
            'He works in the office and he is very polite.',
            'Wuxuu ka shaqeeyaa xafiiska, waana edeb badan yahay.',
          ),
          line(
            'Guest',
            'Nice to meet you, Ali.',
            'Waan ku faraxsanahay inaan kula kulmo, Ali.',
          ),
        ]),
      ];
    default:
      return [
        dialogue('Dib-u-eegis qoys', [
          line('A', 'Do you have a large family?', 'Ma leedahay qoys weyn?'),
          line(
            'B',
            'No, I have a small family.',
            'Maya, waxaan leeyahay qoys yar.',
          ),
          line('A', 'Who is this?', 'Kani waa kuma?'),
          line(
            'B',
            'This is my example brother.',
            'Kani waa walaalkayga tusaalaha ah.',
          ),
        ]),
        dialogue('Dib-u-eegis qof', [
          line('A', 'What is she like?', 'Dabeecaddeedu waa sidee?'),
          line('B', 'She is kind and honest.', 'Waa naxariis iyo daacad.'),
          line('A', 'What does she look like?', 'Muuqaalkeedu waa sidee?'),
          line(
            'B',
            'She has long black hair.',
            'Waxay leedahay timo madow oo dheer.',
          ),
        ]),
      ];
  }
}

void main() {
  final lessonData = <Json>[];

  void addLesson({
    required int number,
    required String titleEnglish,
    required String titleSomali,
    required String description,
    required List<String> objectives,
    required String type,
    required int minutes,
    required List<Json> words,
    Json? grammarTopic,
    required List<Map<String, String>> examples,
    required String fillQuestion,
    required List<String> fillOptions,
    required String fillAnswer,
    required String grammarQuestion,
    required List<String> grammarOptions,
    required String grammarAnswer,
    required String arrangeQuestion,
    required String arrangeAnswer,
    required String speaking,
    required String writing,
    required String summary,
    bool review = false,
  }) {
    final id = 'a1-u04-l${number.toString().padLeft(2, '0')}';
    lessonData.add(
      lesson(
        number: number,
        titleEnglish: titleEnglish,
        titleSomali: titleSomali,
        description: description,
        objectives: objectives,
        type: type,
        minutes: minutes,
        vocabulary: words,
        grammarTopic: grammarTopic,
        examples: examples,
        dialogues: twoDialogues(number),
        exercises: practices(
          id,
          words,
          examples,
          fillQuestion: fillQuestion,
          fillOptions: fillOptions,
          fillAnswer: fillAnswer,
          grammarQuestion: grammarQuestion,
          grammarOptions: grammarOptions,
          grammarAnswer: grammarAnswer,
          arrangeQuestion: arrangeQuestion,
          arrangeAnswer: arrangeAnswer,
          speaking: speaking,
          writing: writing,
          review: review,
        ),
        speaking: speaking,
        writing: writing,
        summary: summary,
      ),
    );
  }

  final l1e = [
    example('My father is a teacher.', 'Aabbahay waa macallin.'),
    example('I have one sister.', 'Waxaan leeyahay hal walaal dhedig.'),
    example('Their children are students.', 'Carruurtoodu waa arday.'),
    example(
      'My grandparents live nearby.',
      'Awoowahay iyo ayeeyaday meel dhow ayay deggan yihiin.',
    ),
    example('Ali is their son.', 'Ali waa wiilkooda.'),
  ];
  addLesson(
    number: 1,
    titleEnglish: 'Family Members',
    titleSomali: 'Xubnaha qoyska',
    description:
        'Bar magacyada xubnaha qoyska iyo xiriirka qof kasta, adigoo xusuusanaya in qoysasku qaabab kala duwan yeelan karaan.',
    objectives: [
      'Magacow 20 xubnood oo qoys.',
      'Kala saar parent/parents iyo child/children.',
      'Akhri family tree tusaale ah.',
    ],
    type: 'vocabulary',
    minutes: 28,
    words: familyVocabulary(),
    examples: l1e,
    fillQuestion: 'My mother and father are my ___.',
    fillOptions: ['children', 'parents', 'cousins', 'siblings'],
    fillAnswer: 'parents',
    grammarQuestion: 'Hal ilmo waxaa la yiraahdaa…',
    grammarOptions: ['children', 'child', 'childs', 'parents'],
    grammarAnswer: 'child',
    arrangeQuestion: 'Kala hagaaji: sister / is / my / This',
    arrangeAnswer: 'This is my sister.',
    speaking:
        'Magacow ugu yaraan toban xubnood oo qoys, kadib sharax family tree male-awaal ah.',
    writing:
        'Samee family tree fudud oo Yusuf iyo Maryan waalid yihiin; ku dar son, daughter iyo grandparents.',
    summary:
        'Waxaad baratay xubnaha qoyska. Parent waa hal waalid, parents waa badan; child waa hal ilmo, children-na waa carruur.',
  );

  final l2e = [
    example('I have a small family.', 'Waxaan leeyahay qoys yar.'),
    example('I have two brothers.', 'Waxaan leeyahay laba walaalo lab.'),
    example(
      'My mother works at a hospital.',
      'Hooyaday waxay ka shaqaysaa isbitaal.',
    ),
    example(
      'There are five people in my family.',
      'Qoyskayga waxaa ku jira shan qof.',
    ),
    example('I live with my parents.', 'Waxaan la noolahay waalidkay.'),
  ];
  addLesson(
    number: 2,
    titleEnglish: 'Talking About Your Family',
    titleSomali: 'Ka hadalka qoyskaaga',
    description:
        'Bar sida qoys tusaale ah looga hadlo adigoon bixin xogtaada gaarka ah.',
    objectives: [
      'Sheeg tirada dadka qoys tusaale ah.',
      'Weydii brothers, sisters iyo qofka lala nool yahay.',
      'Sheeg shaqo fudud oo waalid tusaale ahi qabto.',
    ],
    type: 'speaking',
    minutes: 24,
    words: talkingVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Family questions',
      titleSomali: 'Su’aalaha qoyska',
      explanationSomali:
          'How many wuxuu weydiiyaa tiro. Who wuxuu weydiiyaa qof. What does ... do? wuxuu weydiiyaa shaqo.',
      rule: 'How many + plural noun; Who + do/does; What + does + person + do?',
      structure: 'Question word + helper + subject + verb?',
      examples: l2e,
      questions: [
        example(
          'How many people are in your family?',
          'Immisa qof ayaa qoyskaaga ku jira?',
        ),
        example(
          'Do you have any brothers or sisters?',
          'Ma leedahay walaalo lab ama dhedig?',
        ),
        example('Who do you live with?', 'Yaad la nooshahay?'),
        example('What does your father do?', 'Aabbahaa muxuu shaqeeyaa?'),
        example('What does your mother do?', 'Hooyadaa maxay shaqaysaa?'),
      ],
      mistakes: [
        'How many waxaa la socda people, ma aha person marka tiro badan la weydiinayo.',
        'Xog male-awaal ah ayaad isticmaali kartaa.',
      ],
    ),
    examples: l2e,
    fillQuestion: 'There are five ___ in my family.',
    fillOptions: ['person', 'people', 'family', 'parent'],
    fillAnswer: 'people',
    grammarQuestion: 'Su’aashee ayaa qofka aad la nooshahay weydiinaysa?',
    grammarOptions: [
      'How old are you?',
      'Who do you live with?',
      'How much is it?',
      'Where is the shop?',
    ],
    grammarAnswer: 'Who do you live with?',
    arrangeQuestion: 'Kala hagaaji: with / parents / live / my / I',
    arrangeAnswer: 'I live with my parents.',
    speaking:
        'Ka hadal qoys male-awaal ah: tirada dadka, brothers/sisters, shaqooyinka iyo cidda wada nool.',
    writing:
        'Qor shan jumladood oo qoys tusaale ah ku saabsan. Ha isticmaalin xog xasaasi ah.',
    summary:
        'Waxaad baratay inaad qoys tusaale ah ku sharaxdo I have…, There are… iyo I live with….',
  );

  final l3e = [
    example('I have a brother.', 'Waxaan leeyahay walaal lab.'),
    example('You have a large family.', 'Waxaad leedahay qoys weyn.'),
    example('We have two children.', 'Waxaan leenahay laba carruur ah.'),
    example('He has one sister.', 'Wuxuu leeyahay hal walaal dhedig.'),
    example('She has three brothers.', 'Waxay leedahay saddex walaalo lab.'),
  ];
  addLesson(
    number: 3,
    titleEnglish: 'Have and Has',
    titleSomali: 'Isticmaalka Have iyo Has',
    description:
        'Bar have/has, negative forms iyo do/does questions ee lahaanshaha.',
    objectives: [
      'Have iyo has ku waafaji subject-ka.',
      'Samee don’t/doesn’t negative.',
      'Do/does question sax ah samee.',
    ],
    type: 'grammar',
    minutes: 28,
    words: haveVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Have and has',
      titleSomali: 'Have iyo has',
      explanationSomali:
          'Have waxaa lala isticmaalaa I, you, we, they. Has waxaa lala isticmaalaa he, she, it. Marka does ama doesn’t jiro, falka wuxuu noqdaa have.',
      rule: 'I/you/we/they have; he/she/it has; do/does + subject + have',
      structure: 'Subject + have/has + object',
      examples: l3e,
      negative: [
        example("I don't have a sister.", 'Ma lihi walaal dhedig.'),
        example("He doesn't have a brother.", 'Ma laha walaal lab.'),
      ],
      questions: [
        example('Do you have a brother?', 'Ma leedahay walaal lab?'),
        example('Does she have children?', 'Carruur ma leedahay?'),
        example(
          'How many sisters does he have?',
          'Immisa walaalo dhedig ah ayuu leeyahay?',
        ),
      ],
      mistakes: [
        'Ha oran Does she has…; qaabka saxda ahi waa Does she have….',
        'He have waa khalad; he has ayaa sax ah.',
      ],
    ),
    examples: l3e,
    fillQuestion: 'She ___ three brothers.',
    fillOptions: ['have', 'has', 'do', 'are'],
    fillAnswer: 'has',
    grammarQuestion: 'Kee ayaa sax ah?',
    grammarOptions: [
      'Does she has a sister?',
      'Does she have a sister?',
      'Do she have a sister?',
      'She have a sister?',
    ],
    grammarAnswer: 'Does she have a sister?',
    arrangeQuestion: 'Kala hagaaji: have / children / They / two',
    arrangeAnswer: 'They have two children.',
    speaking:
        'Samee lix jumladood: I/you/we/they have iyo he/she has; kadib laba su’aalood oo do/does ah.',
    writing:
        'Qor lix jumladood oo have/has leh, laba negative iyo laba question.',
    summary:
        'Have: I/you/we/they. Has: he/she/it. Does iyo doesn’t ka dib mar walba have ayaa yimaada.',
  );

  final l4e = [
    example('My father is kind.', 'Aabbahay waa naxariis badan yahay.'),
    example('Your sister is a student.', 'Walaashaa waa ardayad.'),
    example('His brother is tall.', 'Walaalkiis waa dheer yahay.'),
    example(
      'Her mother is friendly.',
      'Hooyadeed waa saaxiibtinimo badan tahay.',
    ),
    example('Their children are happy.', 'Carruurtoodu waa faraxsan yihiin.'),
  ];
  addLesson(
    number: 4,
    titleEnglish: 'Possessive Adjectives',
    titleSomali: 'Erayada muujinaya lahaanshaha',
    description:
        'Bar my, your, his, her, its, our iyo their iyo pronoun-ka ay la xiriiraan.',
    objectives: [
      'Pronoun kasta la xiriiri possessive adjective-kiisa.',
      'Lahaansho ku muuji magaca ka hor.',
      'Kala saar he/his, she/her, we/our iyo they/their.',
    ],
    type: 'grammar',
    minutes: 25,
    words: possessiveVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Possessive adjectives',
      titleSomali: 'Erayada lahaanshaha',
      explanationSomali:
          'Possessive adjective wuxuu yimaadaa magaca ka hor: my father, her mother. Jadwalku waa I→my, you→your, he→his, she→her, it→its, we→our, they→their.',
      rule: 'Pronoun → possessive adjective + noun',
      structure: 'my/your/his/her/its/our/their + noun',
      examples: l4e,
      mistakes: [
        'He father waa khalad; his father ayaa sax ah.',
        'She mother waa khalad; her mother ayaa sax ah.',
        "Its waa lahaansho; it's waa it is.",
      ],
    ),
    examples: l4e,
    fillQuestion: 'Amina is a student. ___ mother is a nurse.',
    fillOptions: ['His', 'Her', 'Our', 'Their'],
    fillAnswer: 'Her',
    grammarQuestion: 'We → kee?',
    grammarOptions: ['my', 'his', 'our', 'their'],
    grammarAnswer: 'our',
    arrangeQuestion: 'Kala hagaaji: family / Our / small / is',
    arrangeAnswer: 'Our family is small.',
    speaking:
        'Ku sheeg tusaalooyin my, your, his, her, its, our iyo their; qof iyo qoys male-awaal ah isticmaal.',
    writing:
        'Qor toddoba jumladood, mid kasta oo isticmaala possessive adjective kala duwan.',
    summary:
        'I→my, you→your, he→his, she→her, it→its, we→our, they→their. Eraygu magaca ayuu ka horreeyaa.',
  );

  final l5e = [
    example('He is tall.', 'Wuu dheer yahay.'),
    example('She is short.', 'Way gaaban tahay.'),
    example('He has short hair.', 'Wuxuu leeyahay timo gaaban.'),
    example('She has brown eyes.', 'Waxay leedahay indho bunni ah.'),
    example('My grandfather is old.', 'Awoowahay waa da’ weyn yahay.'),
  ];
  addLesson(
    number: 5,
    titleEnglish: 'Describing Physical Appearance',
    titleSomali: 'Sharaxaadda muuqaalka qofka',
    description: 'Bar sharaxaad muuqaal oo fudud, sax ah oo ixtiraam leh.',
    objectives: [
      'Isticmaal be + adjective.',
      'Isticmaal have/has + hair/eyes.',
      'Qof si ixtiraam leh u sharax.',
    ],
    type: 'vocabulary',
    minutes: 26,
    words: appearanceVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Be or have for appearance',
      titleSomali: 'Is/are ama have/has ee muuqaalka',
      explanationSomali:
          'Dherer, da’ iyo sifo guud waxaa lagu sheegaa be: He is tall. Hair iyo eyes waxaa lagu sheegaa have/has: She has brown eyes.',
      rule: 'Subject + be + adjective; subject + have/has + feature',
      structure: 'He/She + is + adjective OR has + noun phrase',
      examples: l5e,
      mistakes: [
        'Ha oran He has tall; dheh He is tall.',
        'Ha oran She is brown eyes; dheh She has brown eyes.',
        'Sharaxaadda qofka si ixtiraam leh u isticmaal.',
      ],
    ),
    examples: l5e,
    fillQuestion: 'She ___ brown eyes.',
    fillOptions: ['is', 'has', 'are', 'have'],
    fillAnswer: 'has',
    grammarQuestion: 'Kee ayaa sax ah?',
    grammarOptions: [
      'He has tall.',
      'He is tall.',
      'He tall is.',
      'He have tall.',
    ],
    grammarAnswer: 'He is tall.',
    arrangeQuestion: 'Kala hagaaji: hair / has / black / She',
    arrangeAnswer: 'She has black hair.',
    speaking:
        'Sharax qof male-awaal ah adigoo isticmaalaya tall/short, young/old, hair iyo eyes.',
    writing:
        'Qor shan jumladood oo muuqaal qof tusaale ah si ixtiraam leh u sharaxaya.',
    summary:
        'Isticmaal is + adjective: He is tall. Isticmaal has + feature: He has black hair.',
  );

  final l6e = [
    example('My mother is kind.', 'Hooyaday waa naxariis badan tahay.'),
    example('My friend is helpful.', 'Saaxiibkay waa caawimo badan yahay.'),
    example('He is quiet.', 'Waa hadal yar yahay.'),
    example('She is very friendly.', 'Aad bay saaxiibtinimo badan u tahay.'),
    example(
      'Our teacher is patient.',
      'Macallinkayagu waa dulqaad badan yahay.',
    ),
  ];
  addLesson(
    number: 6,
    titleEnglish: 'Describing Personality',
    titleSomali: 'Sharaxaadda dabeecadda qofka',
    description:
        'Bar sifooyin wanaagsan oo dabeecadda qofka lagu tilmaamo, kana sooc muuqaalka.',
    objectives: [
      'Magacow 12 personality adjectives.',
      'Subject + be + adjective samee.',
      'Kala saar muuqaal iyo dabeecad.',
    ],
    type: 'vocabulary',
    minutes: 24,
    words: personalityVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Basic adjectives',
      titleSomali: 'Sifooyinka aasaasiga ah',
      explanationSomali:
          'Adjective wuxuu iman karaa be ka dib: She is friendly; ama magaca ka hor: a friendly teacher. Tall waa muuqaal; kind waa dabeecad.',
      rule: 'Subject + be + adjective; adjective + noun',
      structure: 'Person + am/is/are + adjective',
      examples: l6e,
      mistakes: [
        'Ha ku darin -s adjective-ka marka subject-ku he/she yahay.',
        'Muuqaal iyo dabeecad ha isku khaldin.',
      ],
    ),
    examples: l6e,
    fillQuestion: 'Our teacher is very ___. She waits calmly.',
    fillOptions: ['patient', 'tall', 'black hair', 'short'],
    fillAnswer: 'patient',
    grammarQuestion: 'Kee ayaa dabeecad tilmaamaya?',
    grammarOptions: ['brown eyes', 'long hair', 'friendly', 'tall'],
    grammarAnswer: 'friendly',
    arrangeQuestion: 'Kala hagaaji: helpful / friend / is / My',
    arrangeAnswer: 'My friend is helpful.',
    speaking:
        'Sharax dabeecadda saaxiib, macallin ama qof male-awaal ah adigoo isticmaalaya afar adjective.',
    writing:
        'Qor lix jumladood oo personality adjectives leh; laba ka mid ah adjective + noun ha noqdaan.',
    summary:
        'Personality waa dabeecad; appearance waa muuqaal. Qaabka fudud waa Subject + be + adjective.',
  );

  final l7e = [
    example('This is my brother.', 'Kani waa walaalkay.'),
    example('That is my teacher.', 'Kaas waa macallinkay.'),
    example('These are my friends.', 'Kuwani waa saaxiibbaday.'),
    example('Those are my cousins.', 'Kuwaas waa cousins-kayga.'),
    example('Who are those people?', 'Dadkaas waa ayo?'),
  ];
  addLesson(
    number: 7,
    titleEnglish: 'This, That, These and Those',
    titleSomali: 'Isticmaalka This, That, These iyo Those',
    description:
        'Bar tilmaamidda qof ama dad dhow iyo fog, singular iyo plural.',
    objectives: [
      'This/that u isticmaal singular.',
      'These/those u isticmaal plural.',
      'Dhow iyo fog si sax ah u kala saar.',
    ],
    type: 'grammar',
    minutes: 24,
    words: demonstrativeVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Demonstratives',
      titleSomali: 'Tilmaamayaasha dhow iyo fog',
      explanationSomali:
          'This: hal dhow. That: hal fog. These: badan oo dhow. Those: badan oo fog. This/that waxaa la socda is; these/those waxaa la socda are.',
      rule: 'this/that + is; these/those + are',
      structure: 'Demonstrative + be + person/noun',
      examples: l7e,
      mistakes: [
        'Ha oran These is; dheh These are.',
        'Ha oran Those is; dheh Those are.',
        'This iyo these waa dhow; that iyo those waa fog.',
      ],
    ),
    examples: l7e,
    fillQuestion: '___ are my friends here beside me.',
    fillOptions: ['This', 'That', 'These', 'Those'],
    fillAnswer: 'These',
    grammarQuestion: 'Dad badan oo fog waxaa lagu tilmaamaa…',
    grammarOptions: ['this', 'that', 'these', 'those'],
    grammarAnswer: 'those',
    arrangeQuestion: 'Kala hagaaji: cousins / Those / my / are',
    arrangeAnswer: 'Those are my cousins.',
    speaking:
        'Adeegso this, that, these iyo those adigoo afar scenario oo dad dhow/fog ah sharaxaya.',
    writing:
        'Qor siddeed jumladood: laba this, laba that, laba these iyo laba those.',
    summary:
        'This/that waa singular; these/those waa plural. This/these waa dhow; that/those waa fog.',
  );

  final l8e = [
    example('Who is he?', 'Isagu waa kuma?'),
    example('Who is she?', 'Iyadu waa kuma?'),
    example('Are they your friends?', 'Ma saaxiibbadaa baa?'),
    example('What is he like?', 'Dabeecaddiisu waa sidee?'),
    example('What does she look like?', 'Muuqaalkeedu waa sidee?'),
  ];
  addLesson(
    number: 8,
    titleEnglish: 'Asking About People',
    titleSomali: 'Weydiinta dadka ku saabsan',
    description:
        'Bar su’aalo fudud oo aqoonsiga, xiriirka, dabeecadda, muuqaalka, da’da iyo meesha qofku deggan yahay.',
    objectives: [
      'Who questions samee.',
      'Dabeecad iyo muuqaal si kala duwan u weydii.',
      'Yes/no questions uga jawaab dadka.',
    ],
    type: 'grammar',
    minutes: 27,
    words: askingVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'Questions about people',
      titleSomali: 'Su’aalaha dadka',
      explanationSomali:
          'Who is/are wuxuu weydiiyaa qofka. What is ... like? wuxuu weydiiyaa dabeecadda. What does ... look like? wuxuu weydiiyaa muuqaalka.',
      rule: 'Who + is/are; What + is/does; How old + is; Where + does + live',
      structure: 'Question word + helper + subject + complement?',
      examples: l8e,
      questions: l8e,
      mistakes: [
        'What is he like? iyo What does he look like? isku macne ma aha.',
        'Where does she lives? waa khalad; dheh Where does she live?',
      ],
    ),
    examples: l8e,
    fillQuestion: 'What does she ___ like?',
    fillOptions: ['looks', 'look', 'is', 'has'],
    fillAnswer: 'look',
    grammarQuestion: 'Su’aashee ayaa dabeecadda weydiinaysa?',
    grammarOptions: [
      'What is he like?',
      'What does he look like?',
      'How old is he?',
      'Where does he live?',
    ],
    grammarAnswer: 'What is he like?',
    arrangeQuestion: 'Kala hagaaji: they / Who / are',
    arrangeAnswer: 'Who are they?',
    speaking:
        'Sawir ama scenario male-awaal ah ka weydii who, personality, appearance, age iyo place.',
    writing:
        'Qor siddeed su’aalood oo dadka ku saabsan, kadib jawaabo gaaban ku dar.',
    summary:
        'Who wuxuu weydiiyaa qofka; What is ... like? dabeecad; What does ... look like? muuqaal.',
  );

  final l9e = [
    example('This is my sister, Amina.', 'Tani waa walaashay, Amina.'),
    example(
      'She is eighteen years old.',
      'Waxay jirtaa siddeed iyo toban sano.',
    ),
    example('She is a student.', 'Waa ardayad.'),
    example(
      'She is friendly and helpful.',
      'Waa saaxiibtinimo iyo caawimo badan tahay.',
    ),
    example('She has long black hair.', 'Waxay leedahay timo madow oo dheer.'),
  ];
  addLesson(
    number: 9,
    titleEnglish: 'Introducing and Describing Someone',
    titleSomali: 'Soo bandhigidda iyo sharaxaadda qof',
    description:
        'Isku dar family, age, occupation, personality, appearance iyo place si qof loogu soo bandhigo 5–7 jumladood.',
    objectives: [
      'Qof si xushmad leh u soo bandhig.',
      '5–7 jumladood isku xiran qor.',
      'Family member, friend, teacher ama coworker sharax.',
    ],
    type: 'speaking',
    minutes: 28,
    words: introducingVocabulary(),
    grammarTopic: grammar(
      titleEnglish: 'A short person description',
      titleSomali: 'Sharaxaad qof oo gaaban',
      explanationSomali:
          'Ku bilow This is…, kadib isticmaal he/she is da’da, shaqada iyo sifooyinka; has muuqaalka; lives meesha.',
      rule: 'This is + person. He/She is… Has… Lives…',
      structure: 'Introduction + age + role + personality + appearance + place',
      examples: l9e,
      mistakes: [
        'Magaca qofka ka dib pronoun isku mid ah sii wad.',
        'Ha gelin xog xasaasi ah; qof male-awaal ah isticmaal.',
      ],
    ),
    examples: l9e,
    fillQuestion: 'She ___ long black hair.',
    fillOptions: ['is', 'has', 'have', 'are'],
    fillAnswer: 'has',
    grammarQuestion: 'Jumladda ugu fiican ee soo bandhigiddu waa tee?',
    grammarOptions: [
      'This my sister Amina.',
      'This is my sister, Amina.',
      'She my sister is Amina.',
      'These is Amina.',
    ],
    grammarAnswer: 'This is my sister, Amina.',
    arrangeQuestion: 'Kala hagaaji: friendly / is / helpful / She / and',
    arrangeAnswer: 'She is friendly and helpful.',
    speaking:
        'Soo bandhig family member, friend, teacher ama coworker male-awaal ah 5–7 jumladood.',
    writing:
        'Qor paragraph 5–7 jumladood ah oo qof tusaale ah soo bandhigaya: xiriir, da’, shaqo, dabeecad, muuqaal iyo magaalo.',
    summary:
        'Soo bandhigid wanaagsan waxay leedahay This is…, kadib is/has/lives oo 5–7 jumladood gaaban ah.',
  );

  final l10e = [
    example('I have two brothers.', 'Waxaan leeyahay laba walaalo lab.'),
    example('Her mother is kind.', 'Hooyadeed waa naxariis badan tahay.'),
    example('He has short black hair.', 'Wuxuu leeyahay timo madow oo gaaban.'),
    example('Those are my cousins.', 'Kuwaas waa cousins-kayga.'),
    example('What is she like?', 'Dabeecaddeedu waa sidee?'),
  ];
  addLesson(
    number: 10,
    titleEnglish: 'Unit Review',
    titleSomali: 'Dib-u-eegista Unit 4',
    description:
        'Dib u eeg family vocabulary, have/has, possessives, appearance, personality, demonstratives iyo sharaxaadda qof.',
    objectives: [
      'Isku dar dhammaan xirfadaha Unit 4.',
      'Aqoonso oo sax khaladaadka caadiga ah.',
      'Qof male-awaal ah si buuxda u sharax.',
    ],
    type: 'review',
    minutes: 35,
    words: reviewVocabulary(),
    examples: l10e,
    fillQuestion: 'He ___ one sister.',
    fillOptions: ['have', 'has', 'are', 'do'],
    fillAnswer: 'has',
    grammarQuestion: 'Kee ayaa sax ah?',
    grammarOptions: [
      'Those is my cousins.',
      'Those are my cousins.',
      'This are my cousin.',
      'These is my cousin.',
    ],
    grammarAnswer: 'Those are my cousins.',
    arrangeQuestion: 'Kala hagaaji: patient / teacher / Our / is',
    arrangeAnswer: 'Our teacher is patient.',
    speaking:
        'Dib u sheeg family members, kadib qof tusaale ah ku sharax family relation, appearance iyo personality.',
    writing:
        'Qor paragraph dib-u-eegis ah oo leh have/has, possessive adjective iyo this/that/these/those.',
    summary:
        'Waxaad dib u eegtay qoyska, lahaanshaha, muuqaalka, dabeecadda, tilmaamayaasha iyo su’aalaha dadka.',
    review: true,
  );

  final unitQuiz = <Json>[
    exercise(
      'a1-u04-q01',
      'multipleChoice',
      '“Niece” waa tee?',
      ['Wiilka walaalka', 'Gabadha walaalka ama walaasha', 'Waalid', 'Ayeeyo'],
      'Gabadha walaalka ama walaasha',
      'Niece waa gabadha uu dhalay walaalka ama walaasha.',
    ),
    exercise(
      'a1-u04-q02',
      'multipleChoice',
      'Plural-ka child waa…',
      ['childs', 'childes', 'children', 'childrens'],
      'children',
      'Child waa singular; children waa plural.',
    ),
    exercise(
      'a1-u04-q03',
      'multipleChoice',
      'Father iyo mother wadajir waa…',
      ['cousins', 'parents', 'children', 'grandparents'],
      'parents',
      'Father iyo mother waa parents.',
    ),
    exercise(
      'a1-u04-q04',
      'multipleChoice',
      '“Husband” lidka xiriirka guurka waa…',
      ['wife', 'sister', 'aunt', 'daughter'],
      'wife',
      'Husband iyo wife waa labada eray ee xiriirka guurka.',
    ),
    exercise(
      'a1-u04-q05',
      'multipleChoice',
      'Ilmaha uncle ama aunt waa…',
      ['parent', 'cousin', 'nephew oo keliya', 'grandparent'],
      'cousin',
      'Cousin waa ilmaha uncle ama aunt.',
    ),
    exercise(
      'a1-u04-q06',
      'fillInTheBlank',
      'I ___ two brothers.',
      ['has', 'have', 'does', 'is'],
      'have',
      'I waxaa la socda have.',
    ),
    exercise(
      'a1-u04-q07',
      'fillInTheBlank',
      'She ___ one sister.',
      ['have', 'has', 'do', 'are'],
      'has',
      'She waxaa la socda has.',
    ),
    exercise(
      'a1-u04-q08',
      'multipleChoice',
      'Kee ayaa sax ah?',
      [
        'Does he has children?',
        'Does he have children?',
        'Do he has children?',
        'He does have children?',
      ],
      'Does he have children?',
      'Does ka dib have ayaa yimaada.',
    ),
    exercise(
      'a1-u04-q09',
      'fillInTheBlank',
      "They ___ have a large family.",
      ["doesn't", "don't", 'has not', 'is not'],
      "don't",
      "They waxaa la socda don't.",
    ),
    exercise(
      'a1-u04-q10',
      'fillInTheBlank',
      "He ___ have a brother.",
      ["don't", "doesn't", 'is not', 'has not a'],
      "doesn't",
      "He waxaa la socda doesn't; ka dibna have.",
    ),
    exercise(
      'a1-u04-q11',
      'fillInTheBlank',
      'I have a sister. ___ name is Hani.',
      ['His', 'Her', 'Our', 'Their'],
      'Her',
      'Sister waa she; lahaanshaheedu waa her.',
    ),
    exercise(
      'a1-u04-q12',
      'multipleChoice',
      'We → possessive adjective kee?',
      ['my', 'your', 'our', 'their'],
      'our',
      'We waxaa lahaansho ahaan u dhigma our.',
    ),
    exercise(
      'a1-u04-q13',
      'fillInTheBlank',
      'Ali has a brother. ___ brother is tall.',
      ['Her', 'His', 'Its', 'Our'],
      'His',
      'Ali waa he; possessive adjective-ku waa his.',
    ),
    exercise(
      'a1-u04-q14',
      'multipleChoice',
      'They → possessive adjective kee?',
      ['their', 'our', 'his', 'your'],
      'their',
      'They waxaa lahaansho ahaan u dhigma their.',
    ),
    exercise(
      'a1-u04-q15',
      'multipleChoice',
      'Kee ayaa muuqaal tilmaamaya?',
      ['honest', 'helpful', 'brown eyes', 'patient'],
      'brown eyes',
      'Brown eyes waa muuqaal; kuwa kale waa dabeecad.',
    ),
    exercise(
      'a1-u04-q16',
      'multipleChoice',
      'Kee ayaa dabeecad tilmaamaya?',
      ['long hair', 'tall', 'friendly', 'brown eyes'],
      'friendly',
      'Friendly waa personality adjective.',
    ),
    exercise(
      'a1-u04-q17',
      'fillInTheBlank',
      'He ___ tall.',
      ['has', 'is', 'have', 'are'],
      'is',
      'Tall waa adjective; He is tall.',
    ),
    exercise(
      'a1-u04-q18',
      'fillInTheBlank',
      'She ___ long hair.',
      ['is', 'are', 'has', 'have'],
      'has',
      'Hair waa feature uu qof leeyahay; She has long hair.',
    ),
    exercise(
      'a1-u04-q19',
      'fillInTheBlank',
      '___ is my brother here beside me.',
      ['This', 'That', 'These', 'Those'],
      'This',
      'Hal qof oo dhow waxaa lagu tilmaamaa this.',
    ),
    exercise(
      'a1-u04-q20',
      'fillInTheBlank',
      '___ are my cousins over there.',
      ['This', 'That', 'These', 'Those'],
      'Those',
      'Dad badan oo fog waxaa lagu tilmaamaa those.',
    ),
    exercise(
      'a1-u04-q21',
      'multipleChoice',
      'Kee ayaa sax ah?',
      [
        'These is my friends.',
        'These are my friends.',
        'This are my friends.',
        'Those is my friends.',
      ],
      'These are my friends.',
      'These waa plural, waxaana la socda are.',
    ),
    exercise(
      'a1-u04-q22',
      'readingComprehension',
      'A: What is Hani like? B: She is kind and helpful. Maxaa laga hadlayaa?',
      ['Da’deeda', 'Dabeecaddeeda', 'Cinwaankeeda', 'Qiimaha'],
      'Dabeecaddeeda',
      'What is ... like? wuxuu weydiiyaa dabeecadda.',
    ),
    exercise(
      'a1-u04-q23',
      'readingComprehension',
      'A: Who are those people? B: They are my cousins. Dadkaasi waa ayo?',
      ['Waalidkiis', 'Macallimiintiis', 'Cousins-kiis', 'Carruurtiis'],
      'Cousins-kiis',
      'Jawaabtu si cad ayay u sheegaysaa “They are my cousins.”',
    ),
    exercise(
      'a1-u04-q24',
      'somaliToEnglish',
      'U beddel: “Waxay leedahay laba walaalo dhedig.”',
      [
        'She is two sisters.',
        'She has two sisters.',
        'She have two sisters.',
        'Her two sisters.',
      ],
      'She has two sisters.',
      'She waxaa la socda has; sisters waa plural.',
    ),
    exercise(
      'a1-u04-q25',
      'somaliToEnglish',
      'U beddel: “Kuwaas waa saaxiibbaday.”',
      [
        'This is my friend.',
        'Those are my friends.',
        'These is my friends.',
        'That are my friends.',
      ],
      'Those are my friends.',
      'Dad badan oo fog: Those are my friends.',
    ),
  ];

  final unit = {
    'id': 'a1-u04',
    'levelId': 'A1',
    'unitNumber': 4,
    'titleEnglish': 'Family and People',
    'titleSomali': 'Qoyska iyo Dadka',
    'introductionSomali':
        'Unit-kan waxaad ku baranaysaa xubnaha qoyska, sida qoys tusaale ah looga hadlo, have/has, lahaanshaha, muuqaalka, dabeecadda iyo sida qof loo soo bandhigo si xushmad leh.',
    'requiredPreviousUnitId': 'a1-u03',
    'lessons': lessonData,
    'unitQuiz': unitQuiz,
    'passingScore': 70,
  };

  final output = const JsonEncoder.withIndent('  ').convert(unit);
  File('assets/content/a1/unit_04.json').writeAsStringSync('$output\n');
}
