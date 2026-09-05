import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/models/interview_session.dart';
import 'package:ai_mock_interview/repositories/interview_repository.dart';
import 'package:ai_mock_interview/services/demo_interview_service.dart';

class DemoInterviewRepository implements InterviewRepository {
  DemoInterviewRepository({DemoInterviewService service = const DemoInterviewService()}) : _service = service;

  final DemoInterviewService _service;

  @override
  Future<InterviewSession> createSession(InterviewConfiguration configuration) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return InterviewSession(id: DateTime.now().microsecondsSinceEpoch.toString(), configuration: configuration, questions: <InterviewQuestion>[_service.openingQuestion(configuration)]);
  }

  @override
  Future<InterviewSession> submitAnswer({required InterviewSession session, required String answer}) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final List<InterviewAnswer> answers = <InterviewAnswer>[...session.answers, InterviewAnswer(questionId: session.currentQuestion.id, text: answer.trim())];
    if (answers.length >= session.configuration.questionCount) return session.copyWith(answers: answers);
    final InterviewSession answeredSession = session.copyWith(answers: answers);
    return answeredSession.copyWith(questions: <InterviewQuestion>[...answeredSession.questions, _service.nextQuestion(session: answeredSession, answer: answer)]);
  }
}
