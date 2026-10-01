import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/offer/offer_screen.dart';
import 'package:in_a_pickle/src/storage.dart';
import 'package:in_a_pickle/src/state.dart';
import 'package:in_a_pickle/src/theme.dart';

void main() {
  Widget host() {
    return ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(InMemoryStore()),
        offerProvider.overrideWith(OfferController.new),
      ],
      child: MaterialApp(theme: buildTheme(), home: const OfferScreen()),
    );
  }

  testWidgets('an off-duty helper sees the instruction to go live',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Make me available to helpers'), findsOneWidget);
  });

  testWidgets('turning the switch on flips the label to the live state',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('You are available to helpers'), findsOneWidget);
    expect(find.text('Make me available to helpers'), findsNothing);
  });
}
