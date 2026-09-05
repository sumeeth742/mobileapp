import 'dart:async';

import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/models/interview_session.dart';
import 'package:ai_mock_interview/core/network/backend_configuration.dart';
import 'package:ai_mock_interview/repositories/api_interview_repository.dart';
import 'package:ai_mock_interview/repositories/demo_interview_repository.dart';
import 'package:ai_mock_interview/repositories/interview_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InterviewStatus { idle, loading, ready, submitting, complete, error }

class InterviewState {
  const InterviewState({this.session, this.status = InterviewStatus.idle, this.errorMessage});

  final InterviewSession? session;
  final InterviewStatus status;
  final String? errorMessage;

  InterviewState copyWith({InterviewSession? session, InterviewStatus? status, String? errorMessage, bool clearError = false}) => InterviewState(session: session ?? this.session, status: status ?? this.status, errorMessage: clearError ? null : errorMessage ?? this.errorMessage);
}

final Provider<InterviewRepository> interviewRepositoryProvider = Provider<InterviewRepository>(
  (Ref ref) => BackendConfiguration.isConfigured ? ApiInterviewRepository() : DemoInterviewRepository(),
);

class InterviewController extends Notifier<InterviewState> {
  Timer? _timer;

  @override
  InterviewState build() {
    ref.onDispose(() => _timer?.cancel());
    return const InterviewState();
  }

  Future<void> start(InterviewConfiguration configuration) async {
    if (state.status == InterviewStatus.loading || state.session != null) return;
    state = const InterviewState(status: InterviewStatus.loading);
    try {
      final InterviewSession session = await ref.read(interviewRepositoryProvider).createSession(configuration);
      state = InterviewState(session: session, status: InterviewStatus.ready);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final InterviewSession? current = state.session;
        if (current != null && state.status != InterviewStatus.complete) state = state.copyWith(session: current.copyWith(elapsedSeconds: current.elapsedSeconds + 1));
      });
    } on InterviewApiException catch (error) {
      state = InterviewState(status: InterviewStatus.error, errorMessage: error.message);
    } catch (_) {
      state = const InterviewState(status: InterviewStatus.error, errorMessage: 'We could not start the interview. Please try again.');
    }
  }

  Future<void> submit(String answer) async {
    final InterviewSession? session = state.session;
    if (session == null || answer.trim().isEmpty || state.status == InterviewStatus.submitting) return;
    state = state.copyWith(status: InterviewStatus.submitting, clearError: true);
    try {
      final InterviewSession updated = await ref.read(interviewRepositoryProvider).submitAnswer(session: session, answer: answer);
      state = InterviewState(session: updated, status: updated.isComplete ? InterviewStatus.complete : InterviewStatus.ready);
      if (updated.isComplete) _timer?.cancel();
    } on InterviewApiException catch (error) {
      state = state.copyWith(status: InterviewStatus.ready, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(status: InterviewStatus.ready, errorMessage: 'Your answer could not be submitted. Please try again.');
    }
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = const InterviewState();
  }
}

final NotifierProvider<InterviewController, InterviewState> interviewControllerProvider = NotifierProvider<InterviewController, InterviewState>(InterviewController.new);
