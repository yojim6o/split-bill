import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:split_bill/src/services/ai_service.dart';
import 'package:split_bill/src/utils/contants.dart';

class FirebaseAi implements AIService {
  late final GenerativeModel _model;

  @override
  Future<void> initialize() async {
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-pro');
    return;
  }

  @override
  Future<String> prompt(Uint8List imageBytes) async {
    final prompt = [
      Content.multi([
        InlineDataPart('image/jpeg', imageBytes),
        TextPart(Constants.standarMessagePrompt),
      ])
    ];

    final response = await _model.generateContent(prompt);
    //TODO: delete just for testing
    //await Future.delayed(Duration(seconds: 1000));
    return response.text ?? "No hay respuesta";
  }
}
