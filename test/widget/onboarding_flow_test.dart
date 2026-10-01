import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/app.dart';
import 'package:in_a_pickle/src/state.dart';
import 'package:in_a_pickle/src/storage.dart';

void main() {
  testWidgets('a neighbour can verify at home and finish one-time onboarding',
      (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(InMemoryStore()),
          profileProvider.overrideWith(ProfileController.new),
          offerProvider.overrideWith(OfferController.new),
          outboxProvider.overrideWith(OutboxController.new),
        ],
        child: const InAPickleApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Set up my account'));
    await tester.tap(find.text('Set up my account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).at(0), 'Sue');
    await tester.enterText(
      find.byType(EditableText).at(1),
      '10 Jane Road, Pringle Bay',
    );
    await tester.ensureVisible(find.text('That’s my home'));
    await tester.tap(find.text('That’s my home'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I’m at home now'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Home confirmed'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dogs'));
    await tester.ensureVisible(find.text('Join the village'));
    await tester.tap(find.text('Join the village'));
    await tester.pumpAndSettle();

    expect(find.text('Hello Sue'), findsOneWidget);
    expect(find.text('Verified home'), findsOneWidget);
  });
}
