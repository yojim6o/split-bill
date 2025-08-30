import 'dart:typed_data';

abstract class AIService {
  Future<void> initialize();
  Future<String> prompt(Uint8List imageBytes);
}
