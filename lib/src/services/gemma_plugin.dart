import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:split_bill/src/models/model.dart';
import 'package:split_bill/src/services/ai_service.dart';
import 'package:split_bill/src/utils/contants.dart';

class GemmaPlugin implements AIService {
  final model = Model.qwen25_vl_7b;
  final _gemma = FlutterGemmaPlugin.instance;
  late final InferenceModel _inferenceModel;

  GemmaPlugin();

  @override
  Future<void> initialize() async {
    /*  print("\n\n\n\n\n Is model installed?");
    final x = await _gemma.modelManager.isModelInstalled;
    debugPrint(x.toString());
    print("\n\n\n\n\n"); */

    await _gemma.modelManager.deleteModel();

    final stream = _gemma.modelManager.downloadModelFromNetworkWithProgress(
        model.url,
        token: "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");

    // Wait for stream to complete - same logic as original but with new downloader
    await for (final progress in stream) {
      // Keep progress as 0-100 (double)
      debugPrint("Download progress: ${progress.toString()}");
    }

    _inferenceModel = await _gemma.createModel(
      modelType: model.modelType, // Required, model type to create
      preferredBackend: model.preferredBackend, // Optional, backend type
      maxTokens: model.maxTokens, // Recommended for multimodal models
      supportImage: model.supportImage, // Enable image support
      maxNumImages: 1, // Optional, maximum number of images per message
    );
  }

  @override
  Future<String> prompt(Uint8List imageBytes) async {
    final session = await _inferenceModel.createSession(
      enableVisionModality: true, // Enable image processing
    );

    // Your image loading method
    await session.addQueryChunk(Message.withImage(
      text: Constants.standarMessagePrompt,
      imageBytes: imageBytes,
      isUser: true,
    ));

    // Note: session.getResponse() returns String directly
    String response = await session.getResponse();
    debugPrint(response);

    await session.close();

    return response;
  }
}
