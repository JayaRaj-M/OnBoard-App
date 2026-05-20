import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onboard/main.dart';

void main() {
  testWidgets('OnBoard app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OnBoardApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
