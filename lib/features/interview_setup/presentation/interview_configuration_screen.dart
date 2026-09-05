import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/providers/interview_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewConfigurationScreen extends ConsumerWidget {
  const InterviewConfigurationScreen({super.key});

  static const List<String> _roles = <String>['Software Engineer', 'Frontend Developer', 'Backend Developer', 'Data Analyst', 'AI/ML Engineer'];
  static const List<String> _languages = <String>['Flutter', 'Dart', 'Java', 'Python', 'C++', 'JavaScript'];
  static const List<String> _topics = <String>['Programming', 'Data Structures', 'Algorithms', 'DBMS', 'Operating Systems', 'Computer Networks', 'OOP', 'APIs'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InterviewConfiguration config = ref.watch(interviewConfigurationProvider);
    final InterviewConfigurationController controller = ref.read(interviewConfigurationProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Configure interview')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(padding: const EdgeInsets.all(24), children: <Widget>[
              Text(config.type.label, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Set the session details that guide your interviewer.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              _SectionTitle('Difficulty'),
              Wrap(spacing: 8, children: InterviewDifficulty.values.map((InterviewDifficulty difficulty) => ChoiceChip(label: Text(difficulty.label), selected: config.difficulty == difficulty, onSelected: (_) => controller.update(config.copyWith(difficulty: difficulty)))).toList()),
              const SizedBox(height: 24),
              _SectionTitle('Number of questions'),
              Wrap(spacing: 8, children: <int>[5, 10, 15].map((int count) => ChoiceChip(label: Text('$count questions'), selected: config.questionCount == count, onSelected: (_) => controller.update(config.copyWith(questionCount: count)))).toList()),
              const SizedBox(height: 24),
              _SectionTitle('Target role'),
              DropdownButtonFormField<String>(value: config.jobRole, decoration: const InputDecoration(prefixIcon: Icon(Icons.work_outline_rounded)), items: _roles.map((String role) => DropdownMenuItem<String>(value: role, child: Text(role))).toList(), onChanged: (String? role) { if (role != null) controller.update(config.copyWith(jobRole: role)); }),
              if (config.type == InterviewType.technical) ...<Widget>[
                const SizedBox(height: 24),
                _SectionTitle('Programming language'),
                DropdownButtonFormField<String>(value: config.programmingLanguage, decoration: const InputDecoration(prefixIcon: Icon(Icons.terminal_rounded)), items: _languages.map((String language) => DropdownMenuItem<String>(value: language, child: Text(language))).toList(), onChanged: (String? language) { if (language != null) controller.update(config.copyWith(programmingLanguage: language)); }),
                const SizedBox(height: 24),
                _SectionTitle('Topics'),
                Wrap(spacing: 8, runSpacing: 8, children: _topics.map((String topic) => FilterChip(label: Text(topic), selected: config.topics.contains(topic), onSelected: (bool selected) {
                  final Set<String> topics = Set<String>.from(config.topics);
                  selected ? topics.add(topic) : topics.remove(topic);
                  controller.update(config.copyWith(topics: topics));
                })).toList()),
              ],
              const SizedBox(height: 36),
              FilledButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.interviewPreparation), icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Review interview')),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(text, style: Theme.of(context).textTheme.titleMedium));
}
