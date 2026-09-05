import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/providers/interview_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewPreparationScreen extends ConsumerWidget {
  const InterviewPreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InterviewConfiguration config = ref.watch(interviewConfigurationProvider);
    final List<(String, String)> details = <(String, String)>[
      ('Interview type', config.type.label),
      ('Difficulty', config.difficulty.label),
      ('Questions', '${config.questionCount}'),
      ('Job role', config.jobRole),
      if (config.type == InterviewType.technical) ('Language', config.programmingLanguage),
      if (config.type == InterviewType.technical) ('Topics', config.topics.isEmpty ? 'General technical interview' : config.topics.join(', ')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Prepare for your interview')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                Icon(config.type.icon, color: Theme.of(context).colorScheme.primary, size: 54),
                const SizedBox(height: 16),
                Text('Your session is ready', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Review the settings before you enter the interview room.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: details.map(((String, String) detail) => _DetailRow(label: detail.$1, value: detail.$2)).toList()))),
                const Spacer(),
                FilledButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.interview), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start interview')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(width: 118, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.titleSmall)),
        ]),
      );
}
import 'package:ai_mock_interview/core/constants/app_routes.dart';
