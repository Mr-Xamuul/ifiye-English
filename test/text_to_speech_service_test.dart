import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/services/text_to_speech_service.dart';
import 'package:ifiye_english/widgets/english_speech_button.dart';

class FakeTtsEngine implements TextToSpeechEngine {
  FakeTtsEngine({
    this.languages = const ['en-US', 'en-GB'],
    this.failSpeak = false,
    this.languageResult = 1,
    this.speakResult = 1,
  });
  final List<String>? languages;
  final bool failSpeak;
  final dynamic languageResult;
  final dynamic speakResult;
  final List<String> spoken = [];
  int stopCalls = 0;
  String? selectedLanguage;
  double? rate, pitch, volume;
  VoidCallback? start, complete, cancel;
  void Function(dynamic)? error;

  @override
  Future<dynamic> getLanguages() async => languages;
  @override
  Future<dynamic> setLanguage(String value) async {
    selectedLanguage = value;
    return languageResult;
  }

  @override
  Future<dynamic> setPitch(double value) async => pitch = value;
  @override
  Future<dynamic> setSpeechRate(double value) async => rate = value;
  @override
  Future<dynamic> setVolume(double value) async => volume = value;
  @override
  Future<dynamic> awaitSpeakCompletion(bool value) async => 1;
  @override
  Future<dynamic> speak(String text) async {
    if (failSpeak) throw PlatformException(code: 'tts_error');
    spoken.add(text);
    start?.call();
    return speakResult;
  }

  @override
  Future<dynamic> stop() async {
    stopCalls++;
    cancel?.call();
    return 1;
  }

  @override
  void setStartHandler(VoidCallback handler) => start = handler;
  @override
  void setCompletionHandler(VoidCallback handler) => complete = handler;
  @override
  void setCancelHandler(VoidCallback handler) => cancel = handler;
  @override
  void setErrorHandler(void Function(dynamic message) handler) =>
      error = handler;
}

void main() {
  test('configures preferred English voice and beginner speech rate', () async {
    final engine = FakeTtsEngine();
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('  Hello  ');
    expect(engine.selectedLanguage, 'en-US');
    expect(engine.rate, 0.42);
    expect(engine.pitch, 1.0);
    expect(engine.volume, 1.0);
    expect(engine.spoken, ['Hello']);
  });

  test('falls back to en-GB and ignores empty text', () async {
    final engine = FakeTtsEngine(languages: const ['so-SO', 'en-GB']);
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('   ');
    expect(engine.spoken, isEmpty);
    await service.speakEnglish('Good morning');
    expect(engine.selectedLanguage, 'en-GB');
  });

  test('throws a safe error when no English voice exists', () async {
    final service = TextToSpeechService(
      engine: FakeTtsEngine(languages: const ['so-SO']),
    );
    expect(
      () => service.speakEnglish('Hello'),
      throwsA(isA<TtsUnavailableException>()),
    );
  });

  test('a second tap on the same text stops current speech', () async {
    final engine = FakeTtsEngine();
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('Hello');
    expect(service.isSpeaking, isTrue);
    await service.speakEnglish('Hello');
    expect(service.isSpeaking, isFalse);
    expect(engine.spoken, hasLength(1));
  });

  test('a second word stops the first and starts the new text', () async {
    final engine = FakeTtsEngine();
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('Hello');
    await service.speakEnglish('Good morning');
    expect(engine.spoken, ['Hello', 'Good morning']);
    expect(engine.stopCalls, greaterThanOrEqualTo(2));
    expect(service.currentText, 'Good morning');
  });

  test('converts a platform speak failure to a safe TTS error', () async {
    final service = TextToSpeechService(engine: FakeTtsEngine(failSpeak: true));
    expect(
      () => service.speakEnglish('Hello'),
      throwsA(isA<TtsUnavailableException>()),
    );
  });

  test(
    'handles setLanguage returning 0 (Android LANG_AVAILABLE) as success',
    () async {
      final engine = FakeTtsEngine(languageResult: 0);
      final service = TextToSpeechService(engine: engine);
      await service.speakEnglish('Hello');
      expect(engine.selectedLanguage, 'en-US');
      expect(engine.spoken, ['Hello']);
    },
  );

  test('handles setLanguage returning null as success', () async {
    final engine = FakeTtsEngine(languageResult: null);
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('Hello');
    expect(engine.selectedLanguage, 'en-US');
  });

  test('handles setLanguage returning false as failure', () async {
    final engine = FakeTtsEngine(languageResult: false);
    final service = TextToSpeechService(engine: engine);
    expect(
      () => service.speakEnglish('Hello'),
      throwsA(isA<TtsUnavailableException>()),
    );
  });

  test('falls back to en-US if getLanguages returns null or empty', () async {
    final engine = FakeTtsEngine(languages: null);
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('Hello');
    expect(engine.selectedLanguage, 'en-US');
  });

  test('handles speak returning null as success', () async {
    final engine = FakeTtsEngine(speakResult: null);
    final service = TextToSpeechService(engine: engine);
    await service.speakEnglish('Hello');
    expect(engine.spoken, ['Hello']);
  });

  test('handles speak returning 0 as failure', () async {
    final engine = FakeTtsEngine(speakResult: 0);
    final service = TextToSpeechService(engine: engine);
    expect(
      () => service.speakEnglish('Hello'),
      throwsA(isA<TtsUnavailableException>()),
    );
  });

  testWidgets('speaker button sends the full English phrase', (tester) async {
    final engine = FakeTtsEngine();
    final service = TextToSpeechService(engine: engine);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnglishSpeechButton(
            service: service,
            text: 'Can you help me, please?',
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.volume_up_outlined));
    await tester.pump();
    expect(engine.spoken, ['Can you help me, please?']);
  });
}
