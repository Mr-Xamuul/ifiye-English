import 'package:flutter_test/flutter_test.dart';

import '../tool/audit_vocabulary_examples.dart';

void main() {
  test(
    'all A1 and available A2 vocabulary examples pass the quality audit',
    () {
      final result = auditVocabularyExamples();

      expect(result.total, 3529);
      expect(result.errors, isEmpty, reason: result.errors.join('\n'));
    },
  );
}
