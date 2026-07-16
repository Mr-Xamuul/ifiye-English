import 'package:flutter/material.dart';

import '../core/services/text_to_speech_service.dart';

class EnglishSpeechButton extends StatelessWidget {
  const EnglishSpeechButton({
    required this.service,
    required this.text,
    this.compact = false,
    super.key,
  });

  final TextToSpeechService service;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: service,
    builder: (context, _) {
      final speakingThis =
          service.isSpeaking && service.currentText == text.trim();
      final label = service.isLoading
          ? 'Codka ayaa diyaar garoobaya'
          : speakingThis
          ? 'Jooji codka English-ka'
          : 'Dhageyso English pronunciation';
      return Semantics(
        button: true,
        label: label,
        child: Tooltip(
          message: 'Dhageyso dhawaaqa English-ka',
          child: IconButton.filledTonal(
            visualDensity: compact ? VisualDensity.compact : null,
            onPressed: service.isLoading
                ? null
                : () async {
                    try {
                      await service.speakEnglish(text);
                    } on TtsUnavailableException {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Codka lama daarin. Hubi in qalabkaagu leeyahay English Text-to-Speech voice.',
                          ),
                        ),
                      );
                    }
                  },
            icon: service.isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    speakingThis
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_outlined,
                  ),
          ),
        ),
      );
    },
  );
}
