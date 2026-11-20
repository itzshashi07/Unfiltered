import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../filters/topic_filter_bar.dart';
import '../onboarding/onboarding.dart';
import 'educator.dart';

const kAppVersion = '1.2.1';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final c = context.c;

    Widget head(String key) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Semantics(
        header: true,
        child: Text(context.t(key), style: context.tx.titleLarge),
      ),
    );

    Widget link(
      String key,
      IconData icon,
      VoidCallback onTap, {
      Color? color,
      Key? k,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        key: k,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? c.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.t(key),
                style: context.tx.titleMedium?.copyWith(color: color),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.inkSoft),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.settings.title'))),
      body: PageBody(
        children: [
          head('settings.language'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in Lang.values)
                ChoicePill(
                  key: Key('set-lang-${l.name}'),
                  label: l.label,
                  selected: s.lang == l,
                  onTap: () => n.setLang(l),
                ),
            ],
          ),
          head('settings.track'),
          if (s.locked)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InfoBanner(
                icon: Icons.lock_rounded,
                text: context.t('lock.isOn.body'),
              ),
            ),
          for (final t in s.selectableTracks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TrackTile(
                track: t,
                selected: s.track == t,
                onTap: () => changeTrack(context, ref, t),
              ),
            ),
          Text(context.t('onb.track.note'), style: context.tx.bodySmall),
          const SizedBox(height: 10),
          link(
            s.locked ? 'lock.turnOff' : 'lock.title',
            s.locked
                ? Icons.lock_open_rounded
                : Icons.admin_panel_settings_rounded,
            () => showEducatorLockSheet(context, ref),
            k: const Key('set-lock'),
          ),
          const TopicFilterBar(initiallyOpen: true),
          head('settings.access'),
          const AccessibilityControls(),
          head('settings.data'),
          Text(
            context.t('settings.data.body'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 10),
          link('settings.export', Icons.ios_share_rounded, () async {
            final text = ref.read(storeProvider).exportJson();
            final done = context.t('settings.exported');
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: text));
            messenger.showSnackBar(SnackBar(content: Text(done)));
          }, k: const Key('set-export')),
          link(
            'settings.delete',
            Icons.delete_forever_rounded,
            () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(ctx.t('settings.delete')),
                  content: Text(ctx.t('settings.delete.body')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(ctx.t('common.cancel')),
                    ),
                    FilledButton(
                      key: const Key('set-delete-confirm'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ctx.c.danger,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(ctx.t('common.delete')),
                    ),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              // The educator lock protects track choice, so wiping it needs the PIN.
              if (s.locked) {
                final pin = await askPin(context);
                if (pin == null || !context.mounted) return;
                if (!n.checkPin(pin)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t('lock.wrong'))),
                  );
                  return;
                }
              }
              await deleteAllLocalData(ref);
              if (context.mounted) context.go('/onboarding');
            },
            color: c.danger,
            k: const Key('set-delete'),
          ),
          head('settings.about'),
          link(
            'settings.privacy',
            Icons.privacy_tip_rounded,
            () => context.push('/legal/privacy'),
          ),
          link(
            'settings.disclaimer',
            Icons.medical_information_rounded,
            () => context.push('/legal/disclaimer'),
          ),
          link(
            'settings.contact',
            Icons.mail_rounded,
            () => launchUrl(
              Uri.parse(
                'mailto:support@theunfiltered.in?subject=UNFILTERED%20app%20feedback',
              ),
            ),
          ),
          link(
            'settings.website',
            Icons.language_rounded,
            () => launchUrl(
              Uri.parse('https://theunfiltered.in/'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          link(
            'settings.credits',
            Icons.favorite_rounded,
            () => context.push('/legal/credits'),
          ),
          link(
            'me.references.title',
            Icons.library_books_rounded,
            () => context.push('/references'),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'UNFILTERED $kAppVersion · ${context.t('settings.edition.$kEdition')}',
              key: const Key('set-version'),
              style: context.tx.bodySmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              context.t('settings.offline'),
              style: context.tx.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
