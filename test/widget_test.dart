import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/app.dart';
import 'package:in_a_pickle/src/storage.dart';
import 'package:in_a_pickle/src/state.dart';

void main() {
  testWidgets('the app boots to the home screen', (tester) async {
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

    expect(find.text('In a Pickle'), findsOneWidget);
    expect(find.text('Pringle Bay'), findsOneWidget);
  });
}