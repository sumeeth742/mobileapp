import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/repositories/demo_interview_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short answer receives a deterministic clarification follow-up', () async {
    final DemoInterviewRepository repository = DemoInterviewRepository();
    final session = await repository.createSession(const InterviewConfiguration(questionCount: 5));

    final updated = await repository.submitAnswer(session: session, answer: 'I used a list.');

    expect(updated.answers, hasLength(1));
    expect(updated.currentQuestion.isFollowUp, isTrue);
    expect(updated.currentQuestion.text, contains('add more detail'));
  });

  test('final answer completes a requested one-question interview', () async {
    final DemoInterviewRepository repository = DemoInterviewRepository();
    final session = await repository.createSession(const InterviewConfiguration(questionCount: 5));

    var current = session;
    for (var index = 0; index < 5; index++) {
      current = await repository.submitAnswer(session: current, answer: 'I identified the constraints, chose a clear approach, tested the implementation, and shared the measurable outcome with the team.');
    }

    expect(current.isComplete, isTrue);
  });
}
