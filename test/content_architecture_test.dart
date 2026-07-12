import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/validation/content_validator.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog loads six valid CEFR level definitions', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();

    final levels = await repository.loadLevels();

    expect(levels.map((level) => level.id), [
      'A1',
      'A2',
      'B1',
      'B2',
      'C1',
      'C2',
    ]);
    for (final level in levels) {
      expect(validator.validateLevel(level).errors, isEmpty);
    }
  });
}
