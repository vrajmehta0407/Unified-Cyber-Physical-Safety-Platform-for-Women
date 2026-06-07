import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_strings.dart';

/// [GAP 1] Voice command SOS trigger using speech_to_text
class VoiceSosService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<bool> initialize() => _speech.initialize();

  Future<void> startListening({required void Function() onTrigger}) async {
    if (_isListening) return;
    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult &&
            result.recognizedWords.toLowerCase().contains(AppStrings.sosHelpPhrase.toLowerCase())) {
          onTrigger();
          stopListening();
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  bool get isListening => _isListening;
}
