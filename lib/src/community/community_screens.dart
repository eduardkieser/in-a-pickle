import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/community.dart';
import '../location/village_map.dart';
import '../theme.dart';
import 'community_state.dart';

class NearbyPicklesScreen extends ConsumerWidget {
  const NearbyPicklesScreen({super.key, required this.helperId});

  final String helperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(communityProvider);
    final inbox = snapshot.inboxFor(helperId);
    return Scaffold(
      appBar: AppBar(title: const Text('A neighbour needs a hand')),
      body: SafeArea(
        child: inbox.isEmpty
            ? const _QuietInbox()
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                children: [
                  Text(
                    'You’re one of 5 nearby helpers',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Say yes only if it suits you. The call disappears as soon as one neighbour accepts.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  for (final pickle in inbox)
                    _IncomingPickleCard(
                      pickle: pickle,
                      requester: snapshot.members[pickle.requesterId]!,
                      onAccept: () {
                        ref
                            .read(communityProvider.notifier)
                            .accept(pickle.id, helperId);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => ResponderJourneyScreen(
                              pickleId: pickle.id,
                              helperId: helperId,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}

class _IncomingPickleCard extends StatelessWidget {
  const _IncomingPickleCard({
    required this.pickle,
    required this.requester,
    required this.onAccept,
  });

  final CommunityPickle pickle;
  final CommunityMember requester;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ocean.withValues(alpha: .18)),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.pickle.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.directions_car_outlined,
                  color: AppColors.pickle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pickle.category.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('${requester.name} · about 500 m away',
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
            ),
          ]),
          const SizedBox(height: 20),
          Text(pickle.message,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.volunteer_activism_outlined),
            label: const Text('I can help Sue'),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: () {}, child: const Text('Not this time')),
        ]),
      );
}

class _QuietInbox extends StatelessWidget {
  const _QuietInbox();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline,
                size: 54, color: AppColors.pickle),
            const SizedBox(height: 16),
            Text('The call has been handled',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'There are no open pickles near you. Nothing else needs your attention.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ]),
        ),
      );
}

class ResponderJourneyScreen extends ConsumerWidget {
  const ResponderJourneyScreen({
    super.key,
    required this.pickleId,
    required this.helperId,
  });

  final String pickleId;
  final String helperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(communityProvider);
    final pickle = snapshot.pickle(pickleId);
    final requester = snapshot.members[pickle.requesterId]!;
    final active = pickle.status == CommunityPickleStatus.active;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              active ? 'On the way to ${requester.name}' : 'You said yes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
          children: [
            if (active) ...[
              const VillageMap(
                showRoute: true,
                label: '6 min · 10 Jane Road',
                height: 260,
              ),
              const SizedBox(height: 20),
              Text('6 minutes away',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                '${requester.name} · ${requester.address}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(pickle.message,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MatchChatScreen(
                      pickleId: pickleId,
                      viewerId: helperId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('Chat with ${requester.name}'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.near_me_outlined),
                label: const Text('Open directions'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pickle.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(children: [
                  const Icon(Icons.hourglass_top,
                      color: AppColors.pickle, size: 48),
                  const SizedBox(height: 14),
                  Text('Waiting for ${requester.name}’s OK',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'The other helpers’ call has cleared. The exact address appears here once ${requester.name} approves.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can message here while you wait; the address stays hidden.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MatchChatScreen(
                      pickleId: pickleId,
                      viewerId: helperId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('Message ${requester.name}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RequesterStatusScreen extends ConsumerWidget {
  const RequesterStatusScreen({
    super.key,
    required this.pickleId,
    this.requesterId = 'sue',
  });

  final String pickleId;
  final String requesterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(communityProvider);
    final pickle = snapshot.pickle(pickleId);
    final helper = pickle.acceptedHelperId == null
        ? null
        : snapshot.members[pickle.acceptedHelperId!];
    final active = pickle.status == CommunityPickleStatus.active;
    return Scaffold(
      appBar: AppBar(title: const Text('Your pickle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
          children: [
            if (active) ...[
              Text('${helper!.name} is on the way',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('About 6 minutes away',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 18),
              VillageMap(
                  showRoute: true,
                  label: '${helper.name} · 6 min',
                  height: 250),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MatchChatScreen(
                      pickleId: pickleId,
                      viewerId: requesterId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('Chat with ${helper.name}'),
              ),
            ] else if (helper != null) ...[
              Text('${helper.name} can help',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text(
                '${helper.name} is a verified neighbour about 500 m away. Approving shares your exact address and opens directions.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref
                    .read(communityProvider.notifier)
                    .approve(pickleId, requesterId),
                child: Text('Approve ${helper.name}'),
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () {}, child: const Text('Ask someone else')),
            ] else ...[
              Text('Calling 5 nearby helpers',
                  style: Theme.of(context).textTheme.headlineLarge),
            ],
          ],
        ),
      ),
    );
  }
}

class MatchChatScreen extends ConsumerStatefulWidget {
  const MatchChatScreen({
    super.key,
    required this.pickleId,
    required this.viewerId,
  });

  final String pickleId;
  final String viewerId;

  @override
  ConsumerState<MatchChatScreen> createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends ConsumerState<MatchChatScreen> {
  final _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(communityProvider);
    final pickle = snapshot.pickle(widget.pickleId);
    final otherId = widget.viewerId == pickle.requesterId
        ? pickle.acceptedHelperId!
        : pickle.requesterId;
    final other = snapshot.members[otherId]!;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(other.name),
          const Text('Matched neighbour',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.ocean.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                        'Today · exact address stays inside this match'),
                  ),
                ),
                const SizedBox(height: 18),
                for (final message in pickle.messages)
                  _MessageBubble(
                    message: message,
                    mine: message.senderId == widget.viewerId,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _composer,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: 'Write a message',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Send message',
                onPressed: () {
                  ref.read(communityProvider.notifier).sendMessage(
                        widget.pickleId,
                        widget.viewerId,
                        _composer.text,
                      );
                  _composer.clear();
                },
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mine});

  final CommunityMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) => Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: mine ? AppColors.pickle : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: mine ? Colors.white : AppColors.ocean,
              fontSize: 18,
              height: 1.35,
            ),
          ),
        ),
      );
}
