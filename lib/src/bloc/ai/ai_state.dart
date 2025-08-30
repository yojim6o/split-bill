abstract class AIServiceState {}

class AIInitializing extends AIServiceState {}

class AIInitializedSuccess extends AIServiceState {}

class AIInitializedError extends AIServiceState {
  final String error;

  AIInitializedError(this.error);
}

class AIResponseWaiting extends AIServiceState {}

class AIResponseError extends AIServiceState {}

class AIResponseReady extends AIServiceState {
  final String response;

  AIResponseReady(this.response);
}
