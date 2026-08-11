import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offer/offer_screen.dart';
import '../pickles/my_pickles_screen.dart';
import '../pickles/new_pickle_screen.dart';
import '../profile/profile_screen.dart';
import '../state.dart';
import '../theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final offer = ref.watch(offerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('In a Pickle', style: Theme.of(context).textTheme.headlineLarge),
              Text(
                'Pringle Bay',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.pickle,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                profile == null
                    ? 'Welcome'
                    : 'Hello ${profile.name.split(' ').first}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              _BigAction(
                label: 'I need help',
                hint: 'Ask the village for a hand',
                background: AppColors.pickle,
                onTap: () => _go(context, const NewPickleScreen()),
              ),
              const SizedBox(height: 16),
              _BigAction(
                label: 'I can help',
                hint: 'Turn on your offer to help',
                background: AppColors.ocean,
                onTap: () => _go(context, const OfferScreen()),
              ),
              const SizedBox(height: 24),
              _StatusStrip(available: offer.available),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _go(context, const MyPicklesScreen()),
                      icon: const Icon(Icons.receipt_long, size: 30),
                      label: const Text('My pickles'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _go(context, const ProfileScreen()),
                      icon: const Icon(Icons.person, size: 30),
                      label: const Text('Profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _BigAction extends StatelessWidget {
  const _BigAction({
    required this.label,
    required this.hint,
    required this.background,
    required this.onTap,
  });

  final String label;
  final String hint;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.pickle : AppColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(available ? Icons.check_circle : Icons.pause_circle, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              available
                  ? 'You are available to help.'
                  : 'Off duty — helpers will not see you.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}