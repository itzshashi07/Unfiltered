import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/achievements.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';

class MeTab extends ConsumerWidget {
  const MeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final c = context.c;
    final all = content.lessonsFor(track);
    final done = all.where((l) => progress.completed.containsKey(l.id)).length;
    final earned = kBadges
        .where((b) => b.earned(progress, content, track))
        .length;

    Widget stat(String value, String label, IconData icon, Color color) =>
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 8),
                Text(value, style: context.tx.headlineMedium),
                Text(
                  label,
                  style: context.tx.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

    Widget item(
      String key,
      IconData icon,
      String route, {
      Color? color,
      Key? k,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        key: k,
        onTap: () => context.push(route),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (color ?? c.primary).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color ?? c.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t('$key.title'), style: context.tx.titleMedium),
                  Text(context.t('$key.sub'), style: context.tx.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.inkSoft),
          ],
        ),
      ),
    );

    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            const Mascot(size: 72, mood: Mood.happy),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      context.t('me.title'),
                      style: context.tx.displaySmall,
                    ),
                  ),
                  Text(
                    '${track.ages} · ${context.t(track.nameKey)}',
                    style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            stat(
              '$done/${all.length}',
              context.t('me.stat.lessons'),
              Icons.menu_book_rounded,
              c.primary,
            ),
            const SizedBox(width: 10),
            stat(
              '${progress.mythsSeen.length}',
              context.t('me.stat.myths'),
              Icons.fact_check_rounded,
              c.coral,
            ),
            const SizedBox(width: 10),
            stat(
              '$earned/${kBadges.length}',
              context.t('me.stat.badges'),
              Icons.emoji_events_rounded,
              c.success,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(context.t('me.private'), style: context.tx.bodySmall),
        const SizedBox(height: 18),
        item(
          'me.achievements',
          Icons.emoji_events_rounded,
          '/achievements',
          k: const Key('me-achievements'),
        ),
        item('me.bookmarks', Icons.bookmark_rounded, '/bookmarks'),
        item(
          'me.notes',
          Icons.edit_note_rounded,
          '/notes',
          k: const Key('me-notes'),
        ),
        item('me.glossary', Icons.translate_rounded, '/glossary'),
        item(
          'me.safety',
          Icons.health_and_safety_rounded,
          '/safety',
          color: c.danger,
        ),
        const SizedBox(height: 8),
        Text(
          context.t('me.grownups'),
          style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
        ),
        const SizedBox(height: 10),
        item(
          'me.teacher',
          Icons.co_present_rounded,
          '/teacher',
          color: c.success,
          k: const Key('me-teacher'),
        ),
        item(
          'me.parents',
          Icons.family_restroom_rounded,
          '/parents',
          color: c.success,
        ),
        const SizedBox(height: 8),
        Text(
          context.t('me.about'),
          style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
        ),
        const SizedBox(height: 10),
        item('me.references', Icons.library_books_rounded, '/references'),
        item(
          'me.settings',
          Icons.settings_rounded,
          '/settings',
          k: const Key('me-settings'),
        ),
      ],
    );
  }
}
