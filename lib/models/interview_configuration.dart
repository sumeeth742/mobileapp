import 'package:flutter/material.dart';

enum InterviewType { hr, technical, project, behavioral }

extension InterviewTypeDetails on InterviewType {
  String get label => switch (this) {
        InterviewType.hr => 'HR Interview',
        InterviewType.technical => 'Technical Interview',
        InterviewType.project => 'Project Interview',
        InterviewType.behavioral => 'Behavioral Interview',
      };

  String get description => switch (this) {
        InterviewType.hr => 'Explore motivation, communication, and culture fit.',
        InterviewType.technical => 'Practice role-specific technical reasoning.',
        InterviewType.project => 'Explain the decisions behind your work.',
        InterviewType.behavioral => 'Answer realistic workplace scenarios.',
      };

  IconData get icon => switch (this) {
        InterviewType.hr => Icons.groups_rounded,
        InterviewType.technical => Icons.code_rounded,
        InterviewType.project => Icons.account_tree_rounded,
        InterviewType.behavioral => Icons.chat_bubble_outline_rounded,
      };
}

enum InterviewDifficulty { beginner, intermediate, advanced }

extension InterviewDifficultyLabel on InterviewDifficulty {
  String get label => '${name[0].toUpperCase()}${name.substring(1)}';
}

class InterviewConfiguration {
  const InterviewConfiguration({
    this.type = InterviewType.technical,
    this.difficulty = InterviewDifficulty.intermediate,
    this.questionCount = 5,
    this.jobRole = 'Software Engineer',
    this.programmingLanguage = 'Flutter',
    this.topics = const <String>{'Programming'},
  });

  final InterviewType type;
  final InterviewDifficulty difficulty;
  final int questionCount;
  final String jobRole;
  final String programmingLanguage;
  final Set<String> topics;

  InterviewConfiguration copyWith({
    InterviewType? type,
    InterviewDifficulty? difficulty,
    int? questionCount,
    String? jobRole,
    String? programmingLanguage,
    Set<String>? topics,
  }) =>
      InterviewConfiguration(
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        questionCount: questionCount ?? this.questionCount,
        jobRole: jobRole ?? this.jobRole,
        programmingLanguage: programmingLanguage ?? this.programmingLanguage,
        topics: topics ?? this.topics,
      );
}
