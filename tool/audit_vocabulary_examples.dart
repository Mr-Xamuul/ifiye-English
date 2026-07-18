import 'dart:convert';
import 'dart:io';

const contentPaths = <String>[
  'assets/content/a1/unit_01.json',
  'assets/content/a1/unit_02.json',
  'assets/content/a1/unit_03.json',
  'assets/content/a1/unit_04.json',
  'assets/content/a1/unit_05.json',
  'assets/content/a1/unit_06.json',
  'assets/content/a1/unit_07.json',
  'assets/content/a1/unit_08.json',
  'assets/content/a1/unit_09.json',
  'assets/content/a1/unit_10.json',
  'assets/content/a1/final_review.json',
  'assets/content/a2/unit_01.json',
  'assets/content/a2/unit_02.json',
  'assets/content/a2/unit_03.json',
  'assets/content/a2/unit_04.json',
];

final genericPattern = RegExp(
  r"today.?s lesson|this phrase is useful|the phrase .+ is useful|available in the example shop|this word means|the thing is|i use this|is in the lesson|is useful in",
  caseSensitive: false,
);
final somaliInEnglishPattern = RegExp(
  r'\b(ayaa|waxaan|wuxuu|waxay|waxaad|fadlan|sidaas darteed)\b',
  caseSensitive: false,
);

String normalize(String value) => value
    .toLowerCase()
    .replaceAll('…', '')
    .replaceAll(RegExp(r'[^a-z0-9’]+'), ' ')
    .trim();

List<String> targetTokens(String word) {
  var target = word;
  if (target.contains(' / ')) target = target.split(' / ').first;
  if (target.contains(' → ')) target = target.split(' → ').last;
  const ignored = {'a', 'an', 'the', 'to', 'of', 'and', 'or'};
  return normalize(target)
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 2 && !ignored.contains(token))
      .toList();
}

bool containsTarget(String sentence, String word) {
  final normalized = normalize(sentence);
  final tokens = targetTokens(word);
  if (tokens.isEmpty) return true;
  final matches = tokens.where((token) {
    if (normalized.contains(token)) return true;
    if (token.endsWith('s') &&
        normalized.contains(token.substring(0, token.length - 1))) {
      return true;
    }
    if (token.endsWith('ed') &&
        normalized.contains(token.substring(0, token.length - 2))) {
      return true;
    }
    return false;
  }).length;
  return matches >= (tokens.length * 0.6).ceil();
}

class VocabularyAuditResult {
  const VocabularyAuditResult({required this.total, required this.errors});

  final int total;
  final List<String> errors;
}

VocabularyAuditResult auditVocabularyExamples() {
  final errors = <String>[];
  final seenIds = <String>{};
  final sentenceOwners = <String, String>{};
  var total = 0;

  for (final path in contentPaths) {
    final root =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final unitId = root['id'];
    if (unitId is String && !seenIds.add(unitId)) {
      errors.add('$path: duplicate unit ID “$unitId”.');
    }
    final level = path.contains('/a1/') ? 'A1' : 'A2';
    final maximumWords = level == 'A1' ? 18 : 25;
    for (final rawLesson in (root['lessons'] as List<dynamic>? ?? const [])) {
      final lesson = rawLesson as Map<String, dynamic>;
      final lessonId = lesson['id'] as String;
      if (!seenIds.add(lessonId)) {
        errors.add('$path: duplicate lesson ID “$lessonId”.');
      }
      for (final rawVocab
          in (lesson['vocabulary'] as List<dynamic>? ?? const [])) {
        total++;
        final vocab = rawVocab as Map<String, dynamic>;
        final word = (vocab['englishWord'] as String?)?.trim() ?? '';
        final english = (vocab['exampleEnglish'] as String?)?.trim() ?? '';
        final somali = (vocab['exampleSomali'] as String?)?.trim() ?? '';
        final owner = '$lessonId/$word';
        if (word.isEmpty) {
          errors.add('$owner: English vocabulary text is empty.');
        }
        if (english.isEmpty) errors.add('$owner: English example is empty.');
        if (somali.isEmpty) errors.add('$owner: Somali translation is empty.');
        if (english.isEmpty || somali.isEmpty) continue;
        if (genericPattern.hasMatch(english)) {
          errors.add('$owner: generic example “$english”.');
        }
        if (!RegExp(r'''[.!?][”"']?$''').hasMatch(english)) {
          errors.add('$owner: English example needs final punctuation.');
        }
        if (!RegExp(r'''[.!?][”"']?$''').hasMatch(somali)) {
          errors.add('$owner: Somali translation needs final punctuation.');
        }
        final wordCount = english.split(RegExp(r'\s+')).length;
        if (wordCount < 3) {
          errors.add('$owner: example is too short ($wordCount words).');
        }
        if (wordCount > maximumWords) {
          errors.add('$owner: $level example is too long ($wordCount words).');
        }
        if (!containsTarget(english, word)) {
          errors.add('$owner: target is not visible in “$english”.');
        }
        if (somaliInEnglishPattern.hasMatch(english)) {
          errors.add('$owner: Somali text appears in the English field.');
        }
        final sentenceKey = normalize(english);
        final previousOwner = sentenceOwners[sentenceKey];
        if (previousOwner != null &&
            previousOwner.split('/').last.toLowerCase() != word.toLowerCase()) {
          errors.add('$owner: duplicate example also used by $previousOwner.');
        } else {
          sentenceOwners[sentenceKey] = owner;
        }
      }
    }
  }

  return VocabularyAuditResult(total: total, errors: errors);
}

void main() {
  final result = auditVocabularyExamples();
  stdout.writeln(
    'Audited ${result.total} vocabulary items in ${contentPaths.length} files.',
  );
  if (result.errors.isEmpty) {
    stdout.writeln('Vocabulary example audit passed.');
    return;
  }
  for (final error in result.errors) {
    stderr.writeln(error);
  }
  stderr.writeln(
    'Vocabulary example audit failed with ${result.errors.length} issue(s).',
  );
  exitCode = 1;
}
