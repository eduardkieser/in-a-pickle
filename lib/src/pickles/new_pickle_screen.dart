import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/categories.dart';
import '../domain/pickle_request.dart';
import '../state.dart';
import '../theme.dart';

class NewPickleScreen extends ConsumerStatefulWidget {
  const NewPickleScreen({super.key});

  @override
  ConsumerState<NewPickleScreen> createState() => _NewPickleScreenState();
}

class _NewPickleScreenState extends ConsumerState<NewPickleScreen> {
  PickleCategory? _selected;
  PickleAudience _audience = PickleAudience.nearbyHelpers;
  final _message = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _message.text.trim();
    if (_selected == null) {
      setState(() => _error = 'Tap a tile to say what kind of pickle it is.');
      return;
    }
    if (message.isEmpty) {
      setState(() => _error = 'Say what you need in one line.');
      return;
    }
    final request = PickleRequest(
      category: _selected!,
      message: message,
      audience: _audience,
    );
    await ref.read(outboxProvider.notifier).add(request);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your pickle is out. We\'ll ring you when someone says yes.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ask for a hand')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('What kind of pickle is it?', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final category in kPickleCategories)
                      SizedBox(
                        width: tileWidth,
                        child: _CategoryTile(
                          category: category,
                          selected: _selected?.id == category.id,
                          onTap: () => setState(() => _selected = category),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Say it in one line', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              maxLines: 3,
              maxLength: 200,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'E.g. A lift to the clinic at 10 on Tuesday',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            Text('Who should see it?', style: theme.textTheme.titleLarge),
            RadioListTile<PickleAudience>(
              value: PickleAudience.nearbyHelpers,
              groupValue: _audience,
              onChanged: (v) => setState(() => _audience = v!),
              title: const Text('Helpers nearby, right now'),
              subtitle: const Text('Pings people who are offering to help'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<PickleAudience>(
              value: PickleAudience.anyoneListening,
              groupValue: _audience,
              onChanged: (v) => setState(() => _audience = v!),
              title: const Text('Anyone listening'),
              subtitle: const Text('The wider village circle'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send, size: 30),
              label: const Text('Send the pickle'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final PickleCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.pickle : AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.title,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.ocean,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.hint,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF4A5B63),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.check_circle, color: Colors.white, size: 26),
              ),
          ],
        ),
      ),
    );
  }
}