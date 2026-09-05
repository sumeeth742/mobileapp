import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/core/theme/app_theme.dart';
import 'package:ai_mock_interview/features/auth/presentation/auth_screen.dart';
import 'package:ai_mock_interview/features/home/presentation/home_screen.dart';
import 'package:ai_mock_interview/features/interview_setup/presentation/interview_configuration_screen.dart';
import 'package:ai_mock_interview/features/interview_setup/presentation/interview_preparation_screen.dart';
import 'package:ai_mock_interview/features/interview_setup/presentation/interview_type_selection_screen.dart';
import 'package:ai_mock_interview/features/interview/presentation/interview_screen.dart';
import 'package:ai_mock_interview/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';

class AiMockInterviewApp extends StatelessWidget {
  const AiMockInterviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Mock Interview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (BuildContext context) => const SplashScreen(),
        AppRoutes.auth: (BuildContext context) => const AuthScreen(),
        AppRoutes.home: (BuildContext context) => const HomeScreen(),
        AppRoutes.interviewTypes: (BuildContext context) => const InterviewTypeSelectionScreen(),
        AppRoutes.interviewConfiguration: (BuildContext context) => const InterviewConfigurationScreen(),
        AppRoutes.interviewPreparation: (BuildContext context) => const InterviewPreparationScreen(),
        AppRoutes.interview: (BuildContext context) => const InterviewScreen(),
      },
    );
  }
}
