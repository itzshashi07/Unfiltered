import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';

/// Asks for the educator PIN. Returns null if cancelled.
Future<String?> askPin(BuildContext context, {String? titleKey}) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.t(titleKey ?? 'lock.enter')),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: ctx.t('lock.pinHint'),
          counterText: '',
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(ctx.t('common.cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text),
          child: Text(ctx.t('common.ok')),
        ),
      ],
    ),
  );
}

/// Lets an educator / guardian restrict which tracks this device can use and
/// protect that choice with a PIN (school-managed configuration).
Future<void> showEducatorLockSheet(BuildContext context, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  if (settings.locked) {
    final pin = await askPin(context);
    if (pin == null || !context.mounted) return;
    final ok = ref.read(settingsProvider.notifier).unlock(pin);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t(ok ? 'lock.removed' : 'lock.wrong'))),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _LockSheet(),
  );
}

class _LockSheet extends ConsumerStatefulWidget {
  const _LockSheet();

  @override
  ConsumerState<_LockSheet> createState() => _LockSheetState();
}

class _LockSheetState extends ConsumerState<_LockSheet> {
  final _pin = TextEditingController();
  final Set<Track> _allowed = {...editionTracks};

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _pin.text.length >= 4 && _allowed.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        0,
        22,
        22 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t('lock.title'), style: context.tx.headlineSmall),
            const SizedBox(height: 6),
            Text(
              context.t('lock.body'),
              style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
            ),
            const SizedBox(height: 16),
            Text(context.t('lock.allowed'), style: context.tx.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in editionTracks)
                  ChoicePill(
                    label: '${t.ages} · ${context.t(t.nameKey)}',
                    selected: _allowed.contains(t),
                    onTap: () => setState(
                      () => _allowed.contains(t)
                          ? _allowed.remove(t)
                          : _allowed.add(t),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: context.t('lock.pinNew'),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(context.t('lock.honest'), style: context.tx.bodySmall),
            const SizedBox(height: 16),
            PrimaryButton(
              label: context.t('lock.turnOn'),
              icon: Icons.lock_rounded,
              onPressed: valid
                  ? () {
                      ref.read(settingsProvider.notifier).lock(_pin.text, [
                        for (final t in Track.values)
                          if (_allowed.contains(t)) t,
                      ]);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.t('lock.on'))),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Track chooser honouring the educator lock. Returns true if the track changed.
Future<bool> changeTrack(BuildContext context, WidgetRef ref, Track t) async {
  final notifier = ref.read(settingsProvider.notifier);
  final s = ref.read(settingsProvider);
  if (s.track == t) return false;
  String? pin;
  if (s.locked && s.track != null) {
    pin = await askPin(context);
    if (pin == null) return false;
  }
  final ok = notifier.setTrack(t, pin: pin);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.t('lock.wrong'))));
  }
  return ok;
}
