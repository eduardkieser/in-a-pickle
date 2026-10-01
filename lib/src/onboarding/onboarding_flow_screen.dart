import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/capabilities.dart';
import '../domain/profile.dart';
import '../location/location_verifier.dart';
import '../location/village_map.dart';
import '../state.dart';
import '../theme.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({
    super.key,
    this.initialStep = 0,
    this.preview = false,
    this.initialVerificationStatus = AddressVerificationStatus.unverified,
  });

  final int initialStep;
  final bool preview;
  final AddressVerificationStatus initialVerificationStatus;

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  late int _step;
  late AddressVerificationStatus _verification;
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _capabilities = <String>{};
  final _home = const GeoPoint(-34.3477, 18.8281);
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, 3);
    _verification = widget.initialVerificationStatus;
    if (widget.preview) {
      _name.text = 'Sue';
      _address.text = '10 Jane Road, Pringle Bay';
      _capabilities.addAll({'driving', 'dogs', 'errands'});
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 &&
        (_name.text.trim().isEmpty || _address.text.trim().isEmpty)) {
      setState(() => _error = 'Add your name and home address to continue.');
      return;
    }
    if (_step == 2 && _verification == AddressVerificationStatus.unverified) {
      setState(
          () => _error = 'Choose how you would like to confirm your home.');
      return;
    }
    setState(() {
      _error = null;
      _step += 1;
    });
  }

  Future<void> _checkLocation() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    final result = await ref.read(locationVerifierProvider).checkAtHome(_home);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _verification = result.isCloseEnough
          ? AddressVerificationStatus.verifiedAtHome
          : AddressVerificationStatus.unverified;
      if (!result.isCloseEnough) {
        _error = 'Your phone is too far from the pin. Try again at home.';
      }
    });
  }

  Future<void> _finish() async {
    if (_capabilities.isEmpty) {
      setState(() => _error = 'Choose at least one way you could lend a hand.');
      return;
    }
    await ref.read(profileProvider.notifier).save(
          Profile(
            name: _name.text.trim(),
            address: _address.text.trim(),
            capabilityIds: _capabilities,
            homeLocation: _home,
            verificationStatus: _verification,
            onboardingComplete: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => setState(() => _step -= 1),
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'In a Pickle',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 7),
                        LinearProgressIndicator(
                          value: (_step + 1) / 4,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor:
                              AppColors.ocean.withValues(alpha: .12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _screenForStep(theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _screenForStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _TrustStep(onContinue: _next);
      case 1:
        return _AddressStep(
          name: _name,
          address: _address,
          error: _error,
          onContinue: _next,
        );
      case 2:
        return _VerificationStep(
          status: _verification,
          checking: _checking,
          error: _error,
          onCheck: _checkLocation,
          onCaptain: () => setState(() {
            _verification = AddressVerificationStatus.captainPending;
            _error = null;
          }),
          onContinue: _next,
        );
      default:
        return _CapabilitiesStep(
          selected: _capabilities,
          error: _error,
          onChanged: (id, selected) => setState(() {
            selected ? _capabilities.add(id) : _capabilities.remove(id);
            _error = null;
          }),
          onFinish: _finish,
        );
    }
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

class _TrustStep extends StatelessWidget {
  const _TrustStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepBody(children: [
      const Icon(Icons.home_work_outlined, size: 54, color: AppColors.pickle),
      const SizedBox(height: 22),
      Text(
        'A trusted circle of neighbours',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineLarge,
      ),
      const SizedBox(height: 16),
      Text(
        'This is a closed Pringle Bay community, not a public social network. '
        'We confirm every member’s home before their account can receive calls.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      const _Promise(
        icon: Icons.verified_user_outlined,
        title: 'Why we check',
        body: 'When a neighbour says yes, you can trust that they belong here.',
      ),
      const SizedBox(height: 12),
      const _Promise(
        icon: Icons.location_off_outlined,
        title: 'What stays private',
        body: 'Your exact address is shown only after you approve a helper.',
      ),
      const SizedBox(height: 28),
      FilledButton(
          onPressed: onContinue, child: const Text('Set up my account')),
    ]);
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.pickle, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
        ]),
      );
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.name,
    required this.address,
    required this.error,
    required this.onContinue,
  });

  final TextEditingController name;
  final TextEditingController address;
  final String? error;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepBody(children: [
      Text('Pin your home', style: theme.textTheme.headlineLarge),
      const SizedBox(height: 10),
      Text(
        'Put the pin on your house. We use it to find nearby help; it is not shown on a public map.',
        style: theme.textTheme.bodyLarge,
      ),
      const SizedBox(height: 18),
      const VillageMap(label: 'Move pin to your house', height: 180),
      const SizedBox(height: 18),
      TextField(
        controller: name,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(labelText: 'Your first name'),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: address,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(labelText: 'Home address'),
      ),
      if (error != null) ...[
        const SizedBox(height: 12),
        Text(error!,
            style: const TextStyle(color: AppColors.coral, fontSize: 17)),
      ],
      const SizedBox(height: 24),
      FilledButton(onPressed: onContinue, child: const Text('That’s my home')),
    ]);
  }
}

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({
    required this.status,
    required this.checking,
    required this.error,
    required this.onCheck,
    required this.onCaptain,
    required this.onContinue,
  });

  final AddressVerificationStatus status;
  final bool checking;
  final String? error;
  final VoidCallback onCheck;
  final VoidCallback onCaptain;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verified = status == AddressVerificationStatus.verifiedAtHome;
    final captain = status == AddressVerificationStatus.captainPending;
    return _StepBody(children: [
      Text('Confirm you live here', style: theme.textTheme.headlineLarge),
      const SizedBox(height: 10),
      Text(
        'The quickest check uses your phone’s location once, while you are at home. We do not track where you go.',
        style: theme.textTheme.bodyLarge,
      ),
      const SizedBox(height: 20),
      if (verified)
        const _VerificationResult(
          icon: Icons.check_circle,
          color: AppColors.pickle,
          title: 'Home confirmed',
          body:
              'Your phone was 11 m from your pin. Your account can join the trusted circle.',
        )
      else if (captain)
        const _VerificationResult(
          icon: Icons.schedule,
          color: AppColors.ocean,
          title: 'Visit requested',
          body:
              'A street captain can say hello and confirm your address. Your account stays quiet until then.',
        )
      else ...[
        FilledButton.icon(
          onPressed: checking ? null : onCheck,
          icon: checking
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Icon(Icons.my_location),
          label: Text(checking ? 'Checking your location…' : 'I’m at home now'),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onCaptain,
          icon: const Icon(Icons.directions_car_outlined),
          label: const Text('Ask a street captain'),
        ),
      ],
      if (error != null) ...[
        const SizedBox(height: 12),
        Text(error!,
            style: const TextStyle(color: AppColors.coral, fontSize: 17)),
      ],
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2BF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Unverified accounts stay quiet: no calls, neighbours’ addresses, or chat.',
          style: TextStyle(fontSize: 17, height: 1.35, color: AppColors.ocean),
        ),
      ),
      if (verified || captain) ...[
        const SizedBox(height: 24),
        FilledButton(onPressed: onContinue, child: const Text('Continue')),
      ],
    ]);
  }
}

class _VerificationResult extends StatelessWidget {
  const _VerificationResult({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Icon(icon, size: 44, color: color),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _CapabilitiesStep extends StatelessWidget {
  const _CapabilitiesStep({
    required this.selected,
    required this.error,
    required this.onChanged,
    required this.onFinish,
  });

  final Set<String> selected;
  final String? error;
  final void Function(String, bool) onChanged;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepBody(children: [
      Text('How could you lend a hand?', style: theme.textTheme.headlineLarge),
      const SizedBox(height: 10),
      Text(
        'Choose as many as you like. This keeps calls relevant, and you can change it later.',
        style: theme.textTheme.bodyLarge,
      ),
      const SizedBox(height: 18),
      for (final category in kHelperCapabilities)
        CheckboxListTile(
          value: selected.contains(category.id),
          onChanged: (value) => onChanged(category.id, value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(category.title, style: theme.textTheme.titleLarge),
          subtitle: Text(category.hint, style: theme.textTheme.bodySmall),
        ),
      if (error != null)
        Text(error!,
            style: const TextStyle(color: AppColors.coral, fontSize: 17)),
      const SizedBox(height: 18),
      FilledButton(onPressed: onFinish, child: const Text('Join the village')),
    ]);
  }
}
