import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewConfigurationController extends Notifier<InterviewConfiguration> {
  @override
  InterviewConfiguration build() => const InterviewConfiguration();

  void update(InterviewConfiguration configuration) => state = configuration;
}

final NotifierProvider<InterviewConfigurationController, InterviewConfiguration> interviewConfigurationProvider = NotifierProvider<InterviewConfigurationController, InterviewConfiguration>(InterviewConfigurationController.new);
