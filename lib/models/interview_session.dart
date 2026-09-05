import 'package:ai_mock_interview/models/interview_configuration.dart';

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.expectedTopics,
    this.isFollowUp = false,
  });

  final String id;
  final String text;
  final List<String> expectedTopics;
  final bool isFollowUp;
}

class InterviewAnswer {
  const InterviewAnswer({required this.questionId, required this.text});

  final String questionId;
  final String text;
}

class InterviewSession {
  const InterviewSession({
    required this.id,
    required this.configuration,
    required this.questions,
    this.answers = const <InterviewAnswer>[],
    this.elapsedSeconds = 0,
  });

  final String id;
  final InterviewConfiguration configuration;
  final List<InterviewQuestion> questions;
  final List<InterviewAnswer> answers;
  final int elapsedSeconds;

  InterviewQuestion get currentQuestion => questions[answers.length];
  bool get isComplete => answers.length >= configuration.questionCount;
  double get progress => answers.length / configuration.questionCount;

  InterviewSession copyWith({
    List<InterviewQuestion>? questions,
    List<InterviewAnswer>? answers,
    int? elapsedSeconds,
  }) =>
      InterviewSession(
        id: id,
        configuration: configuration,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );
}
