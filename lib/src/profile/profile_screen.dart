import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile.dart';
import '../state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _bio = TextEditingController();
  String? _error;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _hydrate(ref.read(profileProvider));
    ref.listenManual<Profile?>(profileProvider, (previous, next) {
      if (!_dirty) _hydrate(next);
    });
  }

  void _hydrate(Profile? profile) {
    _name.text = profile?.name ?? '';
    _address.text = profile?.address ?? '';
    _bio.text = profile?.bio ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = ref.read(profileProvider);
    final profile = Profile(
      name: _name.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      capabilityIds: current?.capabilityIds ?? const {},
      homeLocation: current?.homeLocation,
      verificationStatus:
          current?.verificationStatus ?? AddressVerificationStatus.unverified,
      matchingLocation: current?.matchingLocation ?? MatchingLocation.home,
      onboardingComplete: current?.onboardingComplete ?? false,
    );
    final error = profile.validationError;
    if (error.isNotEmpty) {
      setState(() => _error = error);
      return;
    }
    await ref.read(profileProvider.notifier).save(profile);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('About you', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Your exact address is only shared inside an accepted match. To move '
              'home, ask a street captain to verify the new address.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _name,
              style: const TextStyle(fontSize: 20),
              textInputAction: TextInputAction.next,
              onChanged: (_) => _dirty = true,
              decoration: InputDecoration(
                labelText: 'Your name',
                labelStyle: const TextStyle(fontSize: 20),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _address,
              readOnly: true,
              style: const TextStyle(fontSize: 20),
              textInputAction: TextInputAction.next,
              onChanged: (_) => _dirty = true,
              decoration: const InputDecoration(
                labelText: 'Verified home address',
                labelStyle: TextStyle(fontSize: 20),
                suffixIcon: Icon(Icons.verified_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bio,
              style: const TextStyle(fontSize: 20),
              maxLines: 3,
              maxLength: Profile.maxBioLength,
              onChanged: (_) => _dirty = true,
              decoration: const InputDecoration(
                labelText: 'A few words about you (optional)',
                labelStyle: TextStyle(fontSize: 20),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save profile'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
