import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lead_cart/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LeadKartApp(),
      ),
    );

    expect(find.text('LEAD KART'), findsOneWidget);
    expect(find.text('LEAD College of Management'), findsOneWidget);
  });
}
