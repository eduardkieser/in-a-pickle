import 'categories.dart';
import 'profile.dart';

enum CommunityPickleStatus { open, awaitingApproval, active, complete }

class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.categoryIds = const {},
    this.available = false,
    this.verified = true,
  });

  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final Set<String> categoryIds;
  final bool available;
  final bool verified;
}

class CommunityMessage {
  const CommunityMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
}

class CommunityPickle {
  const CommunityPickle({
    required this.id,
    required this.requesterId,
    required this.category,
    required this.message,
    required this.createdAt,
    required this.targetHelperIds,
    this.status = CommunityPickleStatus.open,
    this.acceptedHelperId,
    this.messages = const [],
  });

  final String id;
  final String requesterId;
  final PickleCategory category;
  final String message;
  final DateTime createdAt;
  final List<String> targetHelperIds;
  final CommunityPickleStatus status;
  final String? acceptedHelperId;
  final List<CommunityMessage> messages;

  CommunityPickle copyWith({
    CommunityPickleStatus? status,
    String? acceptedHelperId,
    List<CommunityMessage>? messages,
  }) =>
      CommunityPickle(
        id: id,
        requesterId: requesterId,
        category: category,
        message: message,
        createdAt: createdAt,
        targetHelperIds: targetHelperIds,
        status: status ?? this.status,
        acceptedHelperId: acceptedHelperId ?? this.acceptedHelperId,
        messages: messages ?? this.messages,
      );
}

class CommunitySnapshot {
  const CommunitySnapshot({required this.members, required this.pickles});

  final Map<String, CommunityMember> members;
  final List<CommunityPickle> pickles;

  CommunityPickle pickle(String id) =>
      pickles.firstWhere((item) => item.id == id);

  List<CommunityPickle> inboxFor(String memberId) => pickles
      .where((item) =>
          item.status == CommunityPickleStatus.open &&
          item.targetHelperIds.contains(memberId))
      .toList();

  CommunitySnapshot replace(CommunityPickle replacement) => CommunitySnapshot(
        members: members,
        pickles: [
          for (final item in pickles)
            if (item.id == replacement.id) replacement else item,
        ],
      );

  static CommunitySnapshot demo({
    CommunityPickleStatus status = CommunityPickleStatus.open,
  }) {
    final members = demoMembers();
    final accepted = status == CommunityPickleStatus.open ? null : 'marius';
    return CommunitySnapshot(
      members: members,
      pickles: [
        CommunityPickle(
          id: 'pickle-clinic',
          requesterId: 'sue',
          category: categoryById('lift')!,
          message: 'A lift to the clinic at 10:00 today',
          createdAt: DateTime(2026, 8, 14, 9, 12),
          targetHelperIds: const ['marius', 'fatima'],
          status: status,
          acceptedHelperId: accepted,
          messages: status == CommunityPickleStatus.active
              ? [
                  CommunityMessage(
                    id: 'message-1',
                    senderId: 'marius',
                    text: 'I’m leaving now. I should be there in six minutes.',
                    sentAt: DateTime(2026, 8, 14, 9, 16),
                  ),
                  CommunityMessage(
                    id: 'message-2',
                    senderId: 'sue',
                    text: 'Thank you. I’ll wait by the front gate.',
                    sentAt: DateTime(2026, 8, 14, 9, 17),
                  ),
                ]
              : const [],
        ),
      ],
    );
  }

  static Map<String, CommunityMember> demoMembers() => const {
        'sue': CommunityMember(
          id: 'sue',
          name: 'Sue',
          address: '10 Jane Road, Pringle Bay',
          location: GeoPoint(-34.3477, 18.8281),
        ),
        'marius': CommunityMember(
          id: 'marius',
          name: 'Marius',
          address: '7 Peak Road, Pringle Bay',
          location: GeoPoint(-34.3493, 18.8302),
          categoryIds: {'lift', 'shopping', 'anything'},
          available: true,
        ),
        'fatima': CommunityMember(
          id: 'fatima',
          name: 'Fatima',
          address: '4 Eric Road, Pringle Bay',
          location: GeoPoint(-34.3511, 18.8320),
          categoryIds: {'lift', 'medical'},
          available: true,
        ),
        'pieter': CommunityMember(
          id: 'pieter',
          name: 'Pieter',
          address: '12 Hangklip Road, Pringle Bay',
          location: GeoPoint(-34.3522, 18.8258),
          categoryIds: {'house', 'tech'},
          available: true,
        ),
      };
}

class CommunityHub {
  CommunityHub(this.snapshot);

  CommunitySnapshot snapshot;

  List<CommunityPickle> inboxFor(String memberId) =>
      snapshot.inboxFor(memberId);

  CommunityPickle openPickle({
    required String id,
    required String requesterId,
    required PickleCategory category,
    required String message,
    required DateTime createdAt,
  }) {
    final requester = snapshot.members[requesterId];
    if (requester == null || !requester.verified) {
      throw StateError('Only a verified member can open a pickle.');
    }
    final candidates = snapshot.members.values
        .where((member) =>
            member.id != requesterId &&
            member.verified &&
            member.available &&
            (member.categoryIds.contains(category.id) ||
                member.categoryIds.contains('anything')))
        .toList()
      ..sort((a, b) {
        double distanceSquared(CommunityMember member) {
          final lat = member.location.latitude - requester.location.latitude;
          final lng = member.location.longitude - requester.location.longitude;
          return lat * lat + lng * lng;
        }

        final byDistance = distanceSquared(a).compareTo(distanceSquared(b));
        return byDistance != 0 ? byDistance : a.id.compareTo(b.id);
      });
    final pickle = CommunityPickle(
      id: id,
      requesterId: requesterId,
      category: category,
      message: message,
      createdAt: createdAt,
      targetHelperIds: candidates.take(5).map((member) => member.id).toList(),
    );
    snapshot = CommunitySnapshot(
      members: snapshot.members,
      pickles: [...snapshot.pickles, pickle],
    );
    return pickle;
  }

  void accept(String pickleId, String helperId) {
    final item = snapshot.pickle(pickleId);
    if (item.status != CommunityPickleStatus.open ||
        !item.targetHelperIds.contains(helperId)) {
      throw StateError('This pickle is no longer available.');
    }
    snapshot = snapshot.replace(item.copyWith(
      status: CommunityPickleStatus.awaitingApproval,
      acceptedHelperId: helperId,
    ));
  }

  void approve(String pickleId, String requesterId) {
    final item = snapshot.pickle(pickleId);
    if (item.requesterId != requesterId ||
        item.status != CommunityPickleStatus.awaitingApproval) {
      throw StateError('Only the requester can approve this match.');
    }
    snapshot =
        snapshot.replace(item.copyWith(status: CommunityPickleStatus.active));
  }

  String? addressVisibleTo(String pickleId, String memberId) {
    final item = snapshot.pickle(pickleId);
    final canSee = memberId == item.requesterId ||
        (item.status == CommunityPickleStatus.active &&
            memberId == item.acceptedHelperId);
    return canSee ? snapshot.members[item.requesterId]?.address : null;
  }

  void sendMessage(String pickleId, String senderId, String text) {
    final item = snapshot.pickle(pickleId);
    final allowed =
        senderId == item.requesterId || senderId == item.acceptedHelperId;
    if (!allowed || item.status == CommunityPickleStatus.open) {
      throw StateError('This conversation is not available.');
    }
    final clean = text.trim();
    if (clean.isEmpty) return;
    final message = CommunityMessage(
      id: 'message-${item.messages.length + 1}',
      senderId: senderId,
      text: clean,
      sentAt: DateTime(2026, 8, 14, 9, 18 + item.messages.length),
    );
    snapshot =
        snapshot.replace(item.copyWith(messages: [...item.messages, message]));
  }
}
