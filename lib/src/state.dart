import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/offer.dart';
import 'domain/outbox.dart';
import 'domain/pickle_request.dart';
import 'domain/profile.dart';
import 'storage.dart';

final localStoreProvider = Provider<LocalStore>((ref) => SharedPrefsStore());

class ProfileController extends Notifier<Profile?> {
  @override
  Profile? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final raw = await ref.read(localStoreProvider).read(StoreKeys.profile);
    if (raw != null) {
      state = Profile.fromJson(jsonDecode(raw) as Map<String, Object?>);
    }
  }

  void loadFrom(Profile profile) => state = profile;

  Future<void> save(Profile profile) async {
    state = profile;
    await ref
        .read(localStoreProvider)
        .write(StoreKeys.profile, jsonEncode(profile.toJson()));
  }
}

final profileProvider = NotifierProvider<ProfileController, Profile?>(
  ProfileController.new,
);

class OfferController extends Notifier<Offer> {
  @override
  Offer build() {
    _load();
    return const Offer();
  }

  Future<void> _load() async {
    final raw = await ref.read(localStoreProvider).read(StoreKeys.offer);
    if (raw != null) {
      state = Offer.fromJson(jsonDecode(raw) as Map<String, Object?>);
    }
  }

  void loadFrom(Offer offer) => state = offer;

  Future<void> update(Offer offer) async {
    state = offer;
    await ref
        .read(localStoreProvider)
        .write(StoreKeys.offer, jsonEncode(offer.toJson()));
  }
}

final offerProvider = NotifierProvider<OfferController, Offer>(
  OfferController.new,
);

abstract class PickleTransport {
  Future<void> send(PickleRequest request);
}

class LocalOnlyTransport implements PickleTransport {
  @override
  Future<void> send(PickleRequest request) async {}
}

final pickleTransportProvider = Provider<PickleTransport>(
  (ref) => LocalOnlyTransport(),
);

class OutboxController extends Notifier<PickleOutbox> {
  @override
  PickleOutbox build() {
    _load();
    return PickleOutbox();
  }

  Future<void> _load() async {
    final raw = await ref.read(localStoreProvider).read(StoreKeys.outbox);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<Object?>;
      state = PickleOutbox.load(
        decoded.whereType<Map<String, Object?>>().map(PickleRequest.fromJson),
      );
    }
  }

  Future<void> add(PickleRequest request) async {
    state = PickleOutbox.load([...state.items, request]);
    await _persist();
    await ref.read(pickleTransportProvider).send(request);
  }

  Future<void> markDone(String id) async {
    final outbox = PickleOutbox.load(state.items);
    outbox.markDone(id);
    state = outbox;
    await _persist();
  }

  Future<void> _persist() async {
    await ref.read(localStoreProvider).write(
      StoreKeys.outbox,
      jsonEncode(state.items.map((r) => r.toJson()).toList()),
    );
  }
}

final outboxProvider = NotifierProvider<OutboxController, PickleOutbox>(
  OutboxController.new,
);