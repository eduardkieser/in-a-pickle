import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/offer.dart';

void main() {
  test('a new offer offers nothing and is not available', () {
    const offer = Offer();
    expect(offer.available, isFalse);
    expect(offer.categoryIds, isEmpty);
  });

  test('availability can be toggled on', () {
    const offer = Offer();
    final on = offer.withAvailable(true);
    expect(on.available, isTrue);
  });

  test('offering a category adds it', () {
    const offer = Offer();
    final withLift = offer.withOffer('lift', true);
    expect(withLift.categoryIds, contains('lift'));
    expect(withLift.offers('lift'), isTrue);
  });

  test('removing an offer takes it away', () {
    const offer = Offer();
    final withLift = offer.withOffer('lift', true);
    final without = withLift.withOffer('lift', false);
    expect(without.categoryIds, isNot(contains('lift')));
    expect(without.offers('lift'), isFalse);
  });

  test('offers are stored as a set so duplicates collapse', () {
    const offer = Offer();
    final a = offer.withOffer('lift', true);
    final b = a.withOffer('lift', true);
    expect(b.categoryIds.length, 1);
  });

  test('availability can be switched off without losing offers', () {
    const offer = Offer();
    final withLift = offer.withOffer('lift', true).withAvailable(true);
    final paused = withLift.withAvailable(false);
    expect(paused.available, isFalse);
    expect(paused.offers('lift'), isTrue);
  });

  test('round-trips through JSON', () {
    final offer = Offer();
    final state = offer.withOffer('lift', true).withOffer('shopping', true).withAvailable(true);
    final restored = Offer.fromJson(state.toJson());
    expect(restored.available, isTrue);
    expect(restored.offers('lift'), isTrue);
    expect(restored.offers('shopping'), isTrue);
    expect(restored.categoryIds.length, 2);
  });

  test('rejects an offer with an unknown category id', () {
    expect(
      () => Offer.fromJson({'available': true, 'categoryIds': ['not-a-thing']}),
      throwsArgumentError,
    );
  });

  test('rejects an offer with a non-string category id', () {
    expect(
      () => Offer.fromJson({'available': true, 'categoryIds': [42]}),
      throwsArgumentError,
    );
  });
}