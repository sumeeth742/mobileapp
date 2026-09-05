import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = ref.watch(authControllerProvider).displayName ?? 'Candidate';
    final bool isWide = MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mock Interview'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Welcome back, $name', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Build confidence for your next opportunity.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 28),
                  _StartInterviewCard(isWide: isWide),
                  const SizedBox(height: 24),
                  Text('Your progress', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _MetricGrid(isWide: isWide),
                  const SizedBox(height: 28),
                  Text('Recent interviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const _EmptyInterviewsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartInterviewCard extends StatelessWidget {
  const _StartInterviewCard({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Ready to practice?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Start a tailored interview and receive focused feedback.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.interviewTypes),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start mock interview'),
        ),
      ],
    );
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isWide
            ? Row(children: <Widget>[Expanded(child: copy), _HeroIcon(colors: colors)])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[copy, const SizedBox(height: 20), _HeroIcon(colors: colors)]),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
        child: Icon(Icons.psychology_alt_rounded, color: colors.onPrimary, size: 48),
      );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const List<_Metric> metrics = <_Metric>[
      _Metric('Overall performance', '--', Icons.insights_rounded),
      _Metric('Interviews completed', '0', Icons.check_circle_outline_rounded),
      _Metric('Current streak', '0 days', Icons.local_fire_department_outlined),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics.map((_Metric metric) => SizedBox(width: isWide ? 300 : double.infinity, child: _MetricCard(metric: metric))).toList(),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: <Widget>[
            Icon(metric.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(metric.label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(metric.value, style: Theme.of(context).textTheme.titleLarge),
            ])),
          ]),
        ),
      );
}

class _EmptyInterviewsCard extends StatelessWidget {
  const _EmptyInterviewsCard();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(children: <Widget>[
            Icon(Icons.forum_outlined, size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Your interview history will appear here.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Complete your first mock interview to start tracking progress.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      );
}
