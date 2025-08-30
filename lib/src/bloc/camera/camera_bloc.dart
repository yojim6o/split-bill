import 'dart:async';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/utils/camera_utils.dart';

part 'camera_event.dart';

part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUtils cameraUtils;
  final ResolutionPreset resolutionPreset;
  final CameraLensDirection cameraLensDirection;

  late CameraController _controller;

  CameraBloc({
    required this.cameraUtils,
    this.resolutionPreset = ResolutionPreset.veryHigh,
    this.cameraLensDirection = CameraLensDirection.back,
  }) : super(CameraInitial()) {
    // Registrar handlers
    on<CameraInitialized>(_onCameraInitialized);
    on<CameraBack>(_onCameraBack);
    on<CameraCaptured>(_onCameraCaptured);
    on<CameraStopped>(_onCameraStopped);
  }

  CameraController getController() => _controller;

  bool isInitialized() => _controller.value.isInitialized;

  // Handlers
  Future<void> _onCameraInitialized(
    CameraInitialized event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _controller = await cameraUtils.getCameraController(
        resolutionPreset,
        cameraLensDirection,
      );
      await _controller.initialize();
      emit(CameraReady());
    } on CameraException catch (error) {
      _controller.dispose();
      emit(CameraFailure(error: error.description ?? ""));
    } catch (error) {
      emit(CameraFailure(error: error.toString()));
    }
  }

  Future<void> _onCameraBack(
    CameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraReady());
  }

  Future<void> _onCameraCaptured(
    CameraCaptured event,
    Emitter<CameraState> emit,
  ) async {
    if (state is CameraReady) {
      emit(CameraCaptureInProgress());
      try {
        final image = await _controller.takePicture();
        emit(CameraCaptureSuccess(image.path));
      } on CameraException catch (error) {
        emit(
          CameraCaptureFailure(
            error: error.description ?? "Something went wrong",
          ),
        );
      }
    }
  }

  Future<void> _onCameraStopped(
    CameraStopped event,
    Emitter<CameraState> emit,
  ) async {
    _controller.dispose();
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _controller.dispose();
    return super.close();
  }
}
