import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/bloc/ai/ai_event.dart';
import 'package:split_bill/src/bloc/ai/ai_state.dart';
import 'package:split_bill/src/services/ai_service.dart';

class AIBloc extends Bloc<AIEvent, AIServiceState> {
  final AIService service;

  AIBloc({required this.service}) : super(AIInitializing()) {
    // Registrar handlers
    on<AIInitialized>(_initialize);
    on<AIQuestion>(_askAI);
  }

  Future<void> _initialize(
    AIInitialized event,
    Emitter<AIServiceState> emit,
  ) async {
    try {
      await service.initialize();
      emit(AIInitializedSuccess());
    } catch (e) {
      emit(AIInitializedError(e.toString()));
    }
  }

  Future<void> _askAI(
    AIQuestion event,
    Emitter<AIServiceState> emit,
  ) async {
    emit(AIResponseWaiting());
    try {
      final response = await service.prompt(event.imageBytes);
      emit(AIResponseReady(response));
    } catch (e) {
      debugPrint('AI Error: $e');
      emit(AIResponseError());
    }
  }
}
