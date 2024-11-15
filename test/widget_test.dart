import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/main.dart';

void main() {
  // Test to ensure the app launches with the MainDashboard widget
  testWidgets('MainDashboard widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the main dashboard is displayed by checking for the Dashboard text
    expect(find.text('Dashboard'), findsOneWidget);
  });

  // Test to verify navigation to BPM page
  testWidgets('Navigate to BPM page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Ensure the BPM card is visible before tapping it
    final bpmCard = find.byKey(Key('bpmCard'));
    await tester.scrollUntilVisible(bpmCard, 200.0);  // Scroll to make it visible
    await tester.tap(bpmCard);
    await tester.pumpAndSettle();

    // Verify that the BPM screen appears by checking for the 'BPM Monitor' text
    expect(find.text('BPM Monitor'), findsOneWidget);
  });

  // Test to verify navigation to Temperature page
  testWidgets('Navigate to Temperature page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Ensure the Temperature card is visible before tapping it
    final temperatureCard = find.byKey(Key('temperatureCard'));
    await tester.scrollUntilVisible(temperatureCard, 200.0);  // Scroll to make it visible
    await tester.tap(temperatureCard);
    await tester.pumpAndSettle();

    // Verify that the Temperature screen appears by checking for the 'Temperature Monitor' text
    expect(find.text('Temperature Monitor'), findsOneWidget);
  });

  // Test to verify navigation to Stress page
  testWidgets('Navigate to Stress page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Ensure the Stress card is visible before tapping it
    final stressCard = find.byKey(Key('stressCard'));
    await tester.scrollUntilVisible(stressCard, 200.0);  // Scroll to make it visible
    await tester.tap(stressCard);
    await tester.pumpAndSettle();

    // Verify that the Stress screen appears by checking for the 'Stress Level Monitor' text
    expect(find.text('Stress Level Monitor'), findsOneWidget);
  });

  // Test to verify navigation to Continuous Health Monitoring page
  testWidgets('Navigate to Continuous Health Monitoring page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Ensure the Continuous Health Monitoring card is visible before tapping it
    final continuousHealthCard = find.byKey(Key('continuousHealthCard'));
    await tester.scrollUntilVisible(continuousHealthCard, 200.0);  // Scroll to make it visible
    await tester.tap(continuousHealthCard);
    await tester.pumpAndSettle();

    // Verify that the Continuous Health Monitoring screen appears by checking for the unique Key
    expect(find.byKey(Key('ContinuousHealthMonitoringPage')), findsOneWidget);
  });
}
