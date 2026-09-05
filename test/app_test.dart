import 'package:ai_mock_interview/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app presents splash then authentication', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AiMockInterviewApp()));

    expect(find.text('AI Mock Interview'), findsOneWidget);
    expect(find.text('Practice with purpose.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
