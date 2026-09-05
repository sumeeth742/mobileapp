import 'dart:async';

import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_openHome());
  }

  Future<void> _openHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.record_voice_over_rounded, color: colors.onPrimary, size: 52),
            ),
            const SizedBox(height: 24),
            Text('AI Mock Interview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Practice with purpose.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
