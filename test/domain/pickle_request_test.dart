import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/categories.dart';
import 'package:in_a_pickle/src/domain/pickle_request.dart';

void main() {
  final lift = categoryById('lift')!;
  final medical = categoryById('medical')!;

  test('a request requires a message', () {
    expect(
      () => PickleRequest(category: lift, message: '   '),
      throwsArgumentError,
    );
  });

test('a request requires a category', () {
      expect(
        () => PickleRequest.fromJson({'categoryId': 'nope', 'message': 'Lift please'}),
        throwsArgumentError,
      );
    });

  test('a valid request takes sensible defaults', () {
    final r = PickleRequest(category: lift, message: 'Lift to the clinic');
    expect(r.audience, PickleAudience.nearbyHelpers);
    expect(r.status, PickleStatus.sent);
    expect(r.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
  });

  test('requests carry an id', () {
    final r = PickleRequest(category: medical, message: 'Script at the pharmacy');
    expect(r.id, isNotEmpty);
  });

  test('audience only reaches the two known options', () {
    expect(PickleAudience.values, [PickleAudience.nearbyHelpers, PickleAudience.anyoneListening]);
  });

  test('status only reaches sent and done', () {
    expect(PickleStatus.values, [PickleStatus.sent, PickleStatus.done]);
  });

  test('the message is trimmed', () {
    final r = PickleRequest(category: lift, message: '  lift please  ');
    expect(r.message, 'lift please');
  });

  test('round-trips through JSON', () {
    final r = PickleRequest(
      category: lift,
      message: 'Lift to the clinic',
      audience: PickleAudience.anyoneListening,
    );
    final restored = PickleRequest.fromJson(r.toJson());
    expect(restored.category.id, lift.id);
    expect(restored.message, r.message);
    expect(restored.audience, PickleAudience.anyoneListening);
    expect(restored.createdAt, r.createdAt);
  });

  test('rejects stored data missing an id', () {
    final json = {
      'categoryId': 'lift',
      'message': 'Lift please',
      'audience': 'nearbyHelpers',
      'status': 'sent',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    };
    expect(() => PickleRequest.fromJson(json), throwsArgumentError);
  });

  test('rejects stored data missing a created time', () {
    final json = {
      'id': '1',
      'categoryId': 'lift',
      'message': 'Lift please',
      'audience': 'nearbyHelpers',
      'status': 'sent',
    };
    expect(() => PickleRequest.fromJson(json), throwsArgumentError);
  });

  test('rejects stored data with an unknown audience', () {
    final json = {
      'id': '1',
      'categoryId': 'lift',
      'message': 'Lift please',
      'audience': 'everyoneAndTheirDog',
      'status': 'sent',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    };
    expect(() => PickleRequest.fromJson(json), throwsArgumentError);
  });

  test('rejects stored data with an unknown status', () {
    final json = {
      'id': '1',
      'categoryId': 'lift',
      'message': 'Lift please',
      'audience': 'nearbyHelpers',
      'status': 'halfway',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    };
    expect(() => PickleRequest.fromJson(json), throwsArgumentError);
  });
}