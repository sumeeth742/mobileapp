import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/models/interview_session.dart';

abstract interface class InterviewRepository {
  Future<InterviewSession> createSession(InterviewConfiguration configuration);

  Future<InterviewSession> submitAnswer({
    required InterviewSession session,
    required String answer,
  });
}
