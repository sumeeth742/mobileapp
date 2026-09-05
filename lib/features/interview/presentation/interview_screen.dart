import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/models/interview_session.dart';
import 'package:ai_mock_interview/providers/interview_configuration_provider.dart';
import 'package:ai_mock_interview/providers/interview_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(interviewControllerProvider.notifier).start(ref.read(interviewConfigurationProvider)));
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    final String answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Write an answer before submitting.')));
      return;
    }
    ref.read(interviewControllerProvider.notifier).submit(answer);
    _answerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final InterviewState interview = ref.watch(interviewControllerProvider);
    final InterviewSession? session = interview.session;
    if (interview.status == InterviewStatus.loading || session == null && interview.status != InterviewStatus.error) return const _InterviewLoading();
    if (interview.status == InterviewStatus.error) return _InterviewError(message: interview.errorMessage ?? 'Something went wrong.');
    if (interview.status == InterviewStatus.complete) return _InterviewComplete(session: session!);
    return Scaffold(
      appBar: AppBar(
        title: Text(session!.configuration.type.label),
        leading: IconButton(
          tooltip: 'End interview',
          icon: const Icon(Icons.close_rounded),
          onPressed: _returnHome,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: <Widget>[
                _InterviewProgress(session: session),
                const Spacer(),
                CircleAvatar(radius: 42, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(Icons.psychology_alt_rounded, color: Theme.of(context).colorScheme.primary, size: 46)),
                const SizedBox(height: 14),
                Text('AI Interviewer', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                _QuestionCard(question: session.currentQuestion),
                const Spacer(),
                if (interview.errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(interview.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                TextField(controller: _answerController, minLines: 4, maxLines: 7, enabled: interview.status != InterviewStatus.submitting, decoration: const InputDecoration(hintText: 'Write your answer here...', alignLabelWithHint: true)),
                const SizedBox(height: 12),
                Row(children: <Widget>[
                  OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice input will be added in Phase 7.'))), icon: const Icon(Icons.mic_none_rounded), label: const Text('Voice answer')),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.icon(onPressed: interview.status == InterviewStatus.submitting ? null : _submit, icon: interview.status == InterviewStatus.submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded), label: Text(interview.status == InterviewStatus.submitting ? 'Analyzing answer...' : 'Submit answer'))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _returnHome() {
    ref.read(interviewControllerProvider.notifier).reset();
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
  }
}

class _InterviewProgress extends StatelessWidget {
  const _InterviewProgress({required this.session});
  final InterviewSession session;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        Row(children: <Widget>[
          Text('Question ${session.answers.length + 1} of ${session.configuration.questionCount}', style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          Icon(Icons.timer_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(_time(session.elapsedSeconds), style: Theme.of(context).textTheme.titleSmall),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: session.progress),
      ]);

  String _time(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});
  final InterviewQuestion question;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            if (question.isFollowUp) ...<Widget>[Chip(label: const Text('Follow-up question')), const SizedBox(height: 12)],
            Text(question.text, style: Theme.of(context).textTheme.titleLarge),
          ]),
        ),
      );
}

class _InterviewLoading extends StatelessWidget {
  const _InterviewLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[CircularProgressIndicator(), SizedBox(height: 16), Text('Preparing your interviewer...')])));
}

class _InterviewError extends ConsumerWidget {
  const _InterviewError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => ref.read(interviewControllerProvider.notifier).start(ref.read(interviewConfigurationProvider)), child: const Text('Try again')),
            ]),
          ),
        ),
      );
}

class _InterviewComplete extends ConsumerWidget {
  const _InterviewComplete({required this.session});
  final InterviewSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.primary, size: 64),
                  const SizedBox(height: 20),
                  Text('Interview complete', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('You answered ${session.answers.length} questions. Your detailed AI report will be available in Phase 5.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () {
                    ref.read(interviewControllerProvider.notifier).reset();
                    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
                  }, child: const Text('Return home')),
                ]),
              ),
            ),
          ),
        ),
      );
}
