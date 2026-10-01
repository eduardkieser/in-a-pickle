import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/categories.dart';
import 'package:in_a_pickle/src/domain/community.dart';

void main() {
  test('requester calls, nearby matches see it, first yes clears it', () {
    final hub = CommunityHub(
      CommunitySnapshot(
        members: CommunitySnapshot.demoMembers(),
        pickles: const [],
      ),
    );
    final opened = hub.openPickle(
      id: 'pickle-clinic',
      requesterId: 'sue',
      category: categoryById('lift')!,
      message: 'A lift to the clinic at 10:00 today',
      createdAt: DateTime(2026, 8, 14, 9, 12),
    );

    expect(opened.targetHelperIds, ['marius', 'fatima']);
    expect(hub.inboxFor('marius'), hasLength(1));
    expect(hub.inboxFor('fatima'), hasLength(1));

    hub.accept('pickle-clinic', 'marius');

    expect(hub.inboxFor('marius'), isEmpty);
    expect(hub.inboxFor('fatima'), isEmpty);
    expect(
      hub.snapshot.pickle('pickle-clinic').status,
      CommunityPickleStatus.awaitingApproval,
    );
  });

  test('exact address stays hidden until the requester approves', () {
    final hub = CommunityHub(CommunitySnapshot.demo());
    hub.accept('pickle-clinic', 'marius');

    expect(hub.addressVisibleTo('pickle-clinic', 'marius'), isNull);
    expect(hub.addressVisibleTo('pickle-clinic', 'fatima'), isNull);

    hub.approve('pickle-clinic', 'sue');

    expect(
      hub.addressVisibleTo('pickle-clinic', 'marius'),
      '10 Jane Road, Pringle Bay',
    );
    expect(hub.addressVisibleTo('pickle-clinic', 'fatima'), isNull);
  });

  test('requester and accepted helper share one conversation', () {
    final hub = CommunityHub(CommunitySnapshot.demo());
    hub.accept('pickle-clinic', 'marius');
    hub.sendMessage('pickle-clinic', 'marius', 'I can leave now.');
    hub.sendMessage('pickle-clinic', 'sue', 'Please do, thank you.');

    final messages = hub.snapshot.pickle('pickle-clinic').messages;
    expect(messages.map((message) => message.senderId), ['marius', 'sue']);
    expect(messages.last.text, 'Please do, thank you.');
  });

  test('an untargeted helper cannot accept the call', () {
    final hub = CommunityHub(CommunitySnapshot.demo());

    expect(
      () => hub.accept('pickle-clinic', 'pieter'),
      throwsStateError,
    );
  });
}
