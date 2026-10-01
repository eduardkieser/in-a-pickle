import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/home_screen.dart';
import 'onboarding/onboarding_flow_screen.dart';
import 'state.dart';
import 'theme.dart';

class InAPickleApp extends StatelessWidget {
  const InAPickleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In a Pickle',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: profile?.onboardingComplete == true
          ? const HomeScreen(key: ValueKey('home'))
          : const OnboardingFlowScreen(key: ValueKey('onboarding')),
    );
  }
}
