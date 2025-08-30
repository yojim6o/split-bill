import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class AIEvent extends Equatable {
  const AIEvent();

  @override
  List<Object> get props => [];
}

class AIInitialized extends AIEvent {}

class AIQuestion extends AIEvent {
  final Uint8List imageBytes;

  const AIQuestion({required this.imageBytes});
}
