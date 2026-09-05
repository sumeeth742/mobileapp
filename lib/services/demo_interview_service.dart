import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/models/interview_session.dart';

/// Local deterministic interview engine used until the secure API is connected.
/// It gives the UI a realistic one-question-at-a-time flow without storing data.
class DemoInterviewService {
  const DemoInterviewService();

  InterviewQuestion openingQuestion(InterviewConfiguration configuration) => switch (configuration.type) {
        InterviewType.hr => const InterviewQuestion(id: 'q1', text: 'Tell me about yourself and what motivates you in your career.', expectedTopics: <String>['background', 'motivation', 'career goals']),
        InterviewType.technical => InterviewQuestion(id: 'q1', text: 'Let\'s begin with ${configuration.programmingLanguage}. Describe a technical problem you solved recently and the approach you took.', expectedTopics: configuration.topics.toList()),
        InterviewType.project => const InterviewQuestion(id: 'q1', text: 'Choose a project you know well. What problem did it solve, and what was your personal contribution?', expectedTopics: <String>['objective', 'contribution', 'impact']),
        InterviewType.behavioral => const InterviewQuestion(id: 'q1', text: 'Tell me about a time you faced a difficult situation while working with others.', expectedTopics: <String>['situation', 'action', 'result']),
      };

  InterviewQuestion nextQuestion({
    required InterviewSession session,
    required String answer,
  }) {
    final int questionNumber = session.answers.length + 2;
    final String conciseAnswer = answer.trim();
    if (conciseAnswer.split(RegExp(r'\s+')).length < 35) {
      return InterviewQuestion(
        id: 'q$questionNumber',
        text: 'Could you add more detail about your specific actions, the constraints you considered, and the result?',
        expectedTopics: const <String>['specific actions', 'constraints', 'result'],
        isFollowUp: true,
      );
    }
    final String focus = _extractFocus(conciseAnswer);
    return switch (session.configuration.type) {
      InterviewType.hr => InterviewQuestion(id: 'q$questionNumber', text: 'You mentioned $focus. How would that help you contribute to a new team?', expectedTopics: const <String>['teamwork', 'self-awareness', 'impact'], isFollowUp: true),
      InterviewType.technical => InterviewQuestion(id: 'q$questionNumber', text: 'You mentioned $focus. What trade-offs did you evaluate, and how would you test that solution?', expectedTopics: const <String>['trade-offs', 'testing', 'reasoning'], isFollowUp: true),
      InterviewType.project => InterviewQuestion(id: 'q$questionNumber', text: 'You mentioned $focus. What design decision was most important, and what would you improve next?', expectedTopics: const <String>['design decision', 'trade-offs', 'improvement'], isFollowUp: true),
      InterviewType.behavioral => InterviewQuestion(id: 'q$questionNumber', text: 'You mentioned $focus. What was the measurable outcome, and what would you do differently next time?', expectedTopics: const <String>['result', 'reflection', 'learning'], isFollowUp: true),
    };
  }

  String _extractFocus(String answer) {
    final List<String> words = answer.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').split(RegExp(r'\s+')).where((String word) => word.length > 3).take(4).toList();
    return words.isEmpty ? 'your approach' : words.join(' ');
  }
}
