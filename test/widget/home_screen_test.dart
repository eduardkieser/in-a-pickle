import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/app.dart';
import 'package:in_a_pickle/src/storage.dart';
import 'package:in_a_pickle/src/state.dart';

void main() {
  Future<Widget> host() async {
    final store = InMemoryStore();
    await store.write(
      StoreKeys.profile,
      jsonEncode(const {'name': 'Gogo'}),
    );
    return ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        profileProvider.overrideWith(ProfileController.new),
        offerProvider.overrideWith(OfferController.new),
        outboxProvider.overrideWith(OutboxController.new),
      ],
      child: const InAPickleApp(),
    );
  }

  testWidgets('home shows the two big calls to action', (tester) async {
    await tester.pumpWidget(await host());
    await tester.pumpAndSettle();

    expect(find.text('I need help'), findsOneWidget);
    expect(find.text('I can help'), findsOneWidget);
  });

  testWidgets('home names the signed-in neighbour', (tester) async {
    await tester.pumpWidget(await host());
    await tester.pumpAndSettle();

    expect(find.text('Hello Gogo'), findsOneWidget);
  });

  testWidgets('a helper-offer screen is reachable from the can-help button', (tester) async {
    await tester.pumpWidget(await host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('I can help'));
    await tester.pumpAndSettle();

    expect(find.text('What can you help with?'), findsOneWidget);
  });
}