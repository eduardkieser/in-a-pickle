import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pickle_request.dart';
import '../state.dart';

class MyPicklesScreen extends ConsumerWidget {
  const MyPicklesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outbox = ref.watch(outboxProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My pickles')),
      body: SafeArea(
        child: outbox.items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No pickles yet.\nWhen you ask the village for a hand, it will show up here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final request in outbox.items)
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: _StatusDot(status: request.status),
                        title: Text(
                          request.category.title,
                          style: theme.textTheme.titleLarge,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(request.message, style: theme.textTheme.bodyMedium),
                        ),
                        trailing: request.status == PickleStatus.sent
                            ? TextButton(
                                onPressed: () =>
                                    ref.read(outboxProvider.notifier).markDone(request.id),
                                child: const Text('Done'),
                              )
                            : const Icon(Icons.check_circle, size: 30),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final PickleStatus status;

  @override
  Widget build(BuildContext context) {
    return Icon(
      status == PickleStatus.sent ? Icons.radio_button_checked : Icons.check_circle,
      size: 34,
      color: status == PickleStatus.sent
          ? Theme.of(context).colorScheme.primary
          : const Color(0xFF8A9A93),
    );
  }
}