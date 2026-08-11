import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/categories.dart';
import 'package:in_a_pickle/src/domain/outbox.dart';
import 'package:in_a_pickle/src/domain/pickle_request.dart';

void main() {
  final lift = categoryById('lift')!;
  final tech = categoryById('tech')!;

  test('a new outbox is empty', () {
    final outbox = PickleOutbox();
    expect(outbox.items, isEmpty);
  });

  test('saving a request makes it appear', () {
    final outbox = PickleOutbox();
    final r = PickleRequest(category: lift, message: 'Lift please');
    outbox.save(r);
    expect(outbox.items, hasLength(1));
    expect(outbox.items.first.id, r.id);
  });

  test('items are listed newest first', () {
    final outbox = PickleOutbox();
    final older = PickleRequest(
      category: lift,
      message: 'Older',
      createdAt: DateTime(2026, 1, 1),
    );
    final newer = PickleRequest(
      category: tech,
      message: 'Newer',
      createdAt: DateTime(2026, 1, 2),
    );
    outbox.save(older);
    outbox.save(newer);
    expect(outbox.items.map((e) => e.id).toList(), [newer.id, older.id]);
  });

  test('marking a request done flips only that request', () {
    final outbox = PickleOutbox();
    final r = PickleRequest(category: lift, message: 'Lift please');
    outbox.save(r);
    outbox.markDone(r.id);
    expect(outbox.items.single.status, PickleStatus.done);
  });

  test('marking an unknown id is a no-op', () {
    final outbox = PickleOutbox();
    outbox.markDone('missing');
    expect(outbox.items, isEmpty);
  });

  test('marking a request done is idempotent', () {
    final outbox = PickleOutbox();
    final r = PickleRequest(category: lift, message: 'Lift please');
    outbox.save(r);
    outbox.markDone(r.id);
    outbox.markDone(r.id);
    expect(outbox.items.single.status, PickleStatus.done);
  });

  test('items can be loaded from a list in memory', () {
    final r = PickleRequest(category: lift, message: 'Lift please');
    final outbox = PickleOutbox.load([r]);
    expect(outbox.items, hasLength(1));
  });
}