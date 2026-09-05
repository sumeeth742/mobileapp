import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/providers/interview_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewTypeSelectionScreen extends ConsumerWidget {
  const InterviewTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Choose interview type')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  Text('What would you like to practice?', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Choose a format and tailor it in the next step.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth >= 650 ? 2 : 1;
                      final double width = (constraints.maxWidth - (columns - 1) * 16) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: InterviewType.values.map((InterviewType type) => SizedBox(width: width, child: _TypeCard(type: type, onTap: () {
                          final InterviewConfiguration current = ref.read(interviewConfigurationProvider);
                          ref.read(interviewConfigurationProvider.notifier).update(current.copyWith(type: type));
                          Navigator.of(context).pushNamed(AppRoutes.interviewConfiguration);
                        }))).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.onTap});
  final InterviewType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Icon(type.icon, color: Theme.of(context).colorScheme.primary, size: 38),
              const SizedBox(height: 24),
              Text(type.label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(type.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Text('Customizable difficulty', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}
