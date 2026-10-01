import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/home/home_screen.dart';
import 'package:in_a_pickle/src/pickles/new_pickle_screen.dart';
import 'package:in_a_pickle/src/storage.dart';
import 'package:in_a_pickle/src/state.dart';
import 'package:in_a_pickle/src/theme.dart';

void main() {
  final overrides = [
    localStoreProvider.overrideWithValue(InMemoryStore()),
    profileProvider.overrideWith(ProfileController.new),
    offerProvider.overrideWith(OfferController.new),
    outboxProvider.overrideWith(OutboxController.new),
  ];

  Widget fullApp() {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: buildTheme(), home: const HomeScreen()),
    );
  }

  Widget scaledPickleScreen(double textScale) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildTheme(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: const NewPickleScreen(),
          ),
        ),
      ),
    );
  }

  Future<void> gotoNewPickle(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('I need help'));
    await tester.pumpAndSettle();
  }

  testWidgets('category tiles do not overflow at 2x text on a narrow phone',
      (tester) async {
    tester.view.physicalSize = const Size(700, 1290);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(scaledPickleScreen(2.0));
    await tester.pumpAndSettle();

    expect(find.text('A lift'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sending a pickle confirms with the shared copy and goes back',
      (tester) async {
    await gotoNewPickle(tester);

    await tester.tap(find.text('A lift'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Lift to the clinic');
    await tester.tap(find.text('Send the pickle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('Your pickle is out. We\'ll ring you when someone says yes.'),
      findsOneWidget,
    );
    expect(find.byType(NewPickleScreen), findsNothing);
  });

  testWidgets('sending with no category explains exactly what is missing',
      (tester) async {
    await gotoNewPickle(tester);

    await tester.tap(find.text('Send the pickle'));
    await tester.pump();

    expect(find.text('Tap a tile to say what kind of pickle it is.'),
        findsOneWidget);
  });

  testWidgets('sending with no message explains exactly what is missing',
      (tester) async {
    await gotoNewPickle(tester);

    await tester.tap(find.text('A lift'));
    await tester.pump();
    await tester.tap(find.text('Send the pickle'));
    await tester.pump();

    expect(find.text('Say what you need in one line.'), findsOneWidget);
  });
}
