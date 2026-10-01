import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/categories.dart';
import '../domain/offer.dart';
import '../state.dart';
import '../theme.dart';

class OfferScreen extends ConsumerWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(offerProvider);
    final theme = Theme.of(context);

    Future<void> save(Offer next) =>
        ref.read(offerProvider.notifier).update(next);

    return Scaffold(
      appBar: AppBar(title: const Text('Lend a hand')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('What can you help with?',
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Tap what you can do. When you are available, pickles that match come to '
              'you as one card at a time.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: offer.available
                    ? AppColors.pickle.withValues(alpha: 0.12)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: offer.available
                      ? AppColors.pickle
                      : const Color(0xFFB8C0C0),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.available
                          ? 'You are available to helpers'
                          : 'Make me available to helpers',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Switch(
                    value: offer.available,
                    onChanged: (v) => save(offer.withAvailable(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (final category in kPickleCategories)
              CheckboxListTile(
                value: offer.offers(category.id),
                onChanged: (v) =>
                    save(offer.withOffer(category.id, v ?? false)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(category.title, style: theme.textTheme.titleLarge),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(category.hint, style: theme.textTheme.bodyMedium),
                ),
              ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
