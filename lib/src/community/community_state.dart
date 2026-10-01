import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/categories.dart';
import '../domain/community.dart';

class CommunityController extends Notifier<CommunitySnapshot> {
  CommunityController({CommunitySnapshot? seed}) : _seed = seed;

  final CommunitySnapshot? _seed;

  @override
  CommunitySnapshot build() => _seed ?? CommunitySnapshot.demo();

  void openPickle({
    required String id,
    required String requesterId,
    required PickleCategory category,
    required String message,
    required DateTime createdAt,
  }) {
    final hub = CommunityHub(state)
      ..openPickle(
        id: id,
        requesterId: requesterId,
        category: category,
        message: message,
        createdAt: createdAt,
      );
    state = hub.snapshot;
  }

  void accept(String pickleId, String helperId) {
    final hub = CommunityHub(state)..accept(pickleId, helperId);
    state = hub.snapshot;
  }

  void approve(String pickleId, String requesterId) {
    final hub = CommunityHub(state)..approve(pickleId, requesterId);
    state = hub.snapshot;
  }

  void sendMessage(String pickleId, String senderId, String text) {
    final hub = CommunityHub(state)..sendMessage(pickleId, senderId, text);
    state = hub.snapshot;
  }
}

final communityProvider =
    NotifierProvider<CommunityController, CommunitySnapshot>(
  CommunityController.new,
);
