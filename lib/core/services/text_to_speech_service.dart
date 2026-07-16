import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TextToSpeechEngine {
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion);
  Future<dynamic> getLanguages();
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
  void setStartHandler(VoidCallback handler);
  void setCompletionHandler(VoidCallback handler);
  void setCancelHandler(VoidCallback handler);
  void setErrorHandler(void Function(dynamic message) handler);
}

class FlutterTtsEngine implements TextToSpeechEngine {
  FlutterTtsEngine([FlutterTts? instance]) : _tts = instance ?? FlutterTts();
  final FlutterTts _tts;

  @override
  Future<dynamic> awaitSpeakCompletion(bool value) =>
      _tts.awaitSpeakCompletion(value);
  @override
  Future<dynamic> getLanguages() => _tts.getLanguages;
  @override
  Future<dynamic> setLanguage(String value) => _tts.setLanguage(value);
  @override
  Future<dynamic> setPitch(double value) => _tts.setPitch(value);
  @override
  Future<dynamic> setSpeechRate(double value) => _tts.setSpeechRate(value);
  @override
  Future<dynamic> setVolume(double value) => _tts.setVolume(value);
  @override
  Future<dynamic> speak(String text) => _tts.speak(text);
  @override
  Future<dynamic> stop() => _tts.stop();
  @override
  void setStartHandler(VoidCallback handler) => _tts.setStartHandler(handler);
  @override
  void setCompletionHandler(VoidCallback handler) =>
      _tts.setCompletionHandler(handler);
  @override
  void setCancelHandler(VoidCallback handler) => _tts.setCancelHandler(handler);
  @override
  void setErrorHandler(void Function(dynamic message) handler) =>
      _tts.setErrorHandler(handler);
}

class TextToSpeechService extends ChangeNotifier {
  TextToSpeechService({TextToSpeechEngine? engine})
    : _engine = engine ?? FlutterTtsEngine();

  final TextToSpeechEngine _engine;
  bool _initialized = false;
  bool _loading = false;
  bool _speaking = false;
  bool _disposed = false;
  String? _currentText;

  bool get isLoading => _loading;
  bool get isSpeaking => _speaking;
  String? get currentText => _currentText;

  Future<void> initialize() async {
    if (_initialized) return;
    _setLoading(true);
    try {
      final languages = await _engine.getLanguages();
      final available = (languages as List<dynamic>? ?? const [])
          .map((item) => item.toString().replaceAll('_', '-'))
          .toList();
      final locale = _selectEnglishLocale(available);
      if (locale == null) {
        throw const TtsUnavailableException();
      }
      final languageResult = await _engine.setLanguage(locale);
      if (languageResult == 0 || languageResult == false) {
        throw const TtsUnavailableException();
      }
      await _engine.setVolume(1.0);
      await _engine.setPitch(1.0);
      await _engine.setSpeechRate(0.42);
      await _engine.awaitSpeakCompletion(true);
      _engine.setStartHandler(() => _setSpeaking(true));
      _engine.setCompletionHandler(_resetSpeaking);
      _engine.setCancelHandler(_resetSpeaking);
      _engine.setErrorHandler((message) {
        if (kDebugMode) debugPrint('TTS error: $message');
        _resetSpeaking();
      });
      _initialized = true;
    } on PlatformException catch (error) {
      if (kDebugMode) debugPrint('TTS initialization error: $error');
      throw const TtsUnavailableException();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> speakEnglish(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    if (_speaking && _currentText == value) {
      await stop();
      return;
    }
    try {
      _setLoading(true);
      await initialize();
      await _engine.stop();
      _currentText = value;
      _setSpeaking(true);
      final result = await _engine.speak(value);
      if (result == 0 || result == false) throw const TtsUnavailableException();
    } on TtsUnavailableException {
      _resetSpeaking();
      rethrow;
    } on PlatformException catch (error) {
      if (kDebugMode) debugPrint('TTS speak error: $error');
      _resetSpeaking();
      throw const TtsUnavailableException();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stop() async {
    try {
      await _engine.stop();
    } finally {
      _resetSpeaking();
    }
  }

  Future<void> disposeService() => stop();

  static String? _selectEnglishLocale(List<String> languages) {
    String? find(String wanted) {
      for (final item in languages) {
        if (item.toLowerCase() == wanted.toLowerCase()) return item;
      }
      return null;
    }

    return find('en-US') ??
        find('en-GB') ??
        languages.cast<String?>().firstWhere(
          (item) => item!.toLowerCase().startsWith('en-'),
          orElse: () => null,
        );
  }

  void _setLoading(bool value) {
    _loading = value;
    _notify();
  }

  void _setSpeaking(bool value) {
    _speaking = value;
    _notify();
  }

  void _resetSpeaking() {
    _speaking = false;
    _currentText = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class TtsUnavailableException implements Exception {
  const TtsUnavailableException();
}
