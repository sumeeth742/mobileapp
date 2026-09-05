import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('configuration retains values when one setting changes', () {
    const InterviewConfiguration original = InterviewConfiguration(
      type: InterviewType.technical,
      jobRole: 'Backend Developer',
      topics: <String>{'APIs'},
    );

    final InterviewConfiguration updated = original.copyWith(questionCount: 10);

    expect(updated.questionCount, 10);
    expect(updated.jobRole, 'Backend Developer');
    expect(updated.topics, contains('APIs'));
  });

  test('interview type exposes a presentable label', () {
    expect(InterviewType.behavioral.label, 'Behavioral Interview');
  });
}
