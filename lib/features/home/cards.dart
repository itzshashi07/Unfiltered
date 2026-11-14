import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';

/// Lab keys with their icon and colours. Titles: `lab.<key>.title` / `.sub`.
const kLabStyle = <String, (IconData, Color, Color)>{
  'body_lab': (
    Icons.accessibility_new_rounded,
    Color(0xFF765BFF),
    Color(0xFFB5A4FF),
  ),
  'puberty_lab': (
    Icons.auto_awesome_rounded,
    Color(0xFFFF8A5B),
    Color(0xFFFFC95C),
  ),
  'period_lab': (
    Icons.water_drop_rounded,
    Color(0xFFFF677B),
    Color(0xFFFFA6B2),
  ),
  'myth_buster': (
    Icons.fact_check_rounded,
    Color(0xFFE8862E),
    Color(0xFFFFD28A),
  ),
  'consent_sim': (
    Icons.back_hand_rounded,
    Color(0xFF12A37A),
    Color(0xFFA9EBD4),
  ),
  'relationship_radar': (
    Icons.radar_rounded,
    Color(0xFF3D8BFF),
    Color(0xFF80B9FF),
  ),
  'protection_lab': (
    Icons.shield_rounded,
    Color(0xFF5B6BFF),
    Color(0xFF9DB0FF),
  ),
  'digital_safety': (
    Icons.phonelink_lock_rounded,
    Color(0xFF2F6BFF),
    Color(0xFF7FD4FF),
  ),
  'sti_match': (Icons.extension_rounded, Color(0xFF00A3B4), Color(0xFF8BE3EC)),
  'support_circle': (
    Icons.groups_rounded,
    Color(0xFF2BAE9E),
    Color(0xFFA9EBD4),
  ),
  'communication': (
    Icons.record_voice_over_rounded,
    Color(0xFFEF5DA8),
    Color(0xFFFFB3D9),
  ),
  'quiz': (Icons.quiz_rounded, Color(0xFF4A4A8F), Color(0xFF9D9DE0)),
  'final': (Icons.verified_rounded, Color(0xFF111127), Color(0xFF765BFF)),
  'signals': (
    Icons.swap_vert_circle_rounded,
    Color(0xFF3D8BFF),
    Color(0xFF80B9FF),
  ),
  'digital_challenge': (
    Icons.mark_chat_unread_rounded,
    Color(0xFF2F6BFF),
    Color(0xFF7FD4FF),
  ),
};

class LabCard extends StatelessWidget {
  final String labKey;
  final VoidCallback onTap;
  final bool wide;
  const LabCard({
    super.key,
    required this.labKey,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final st = kLabStyle[labKey] ?? kLabStyle['quiz']!;
    final title = context.t('lab.$labKey.title');
    final sub = context.t('lab.$labKey.sub');
    final icon = Container(
      width: wide ? 64 : 48,
      height: wide ? 64 : 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(wide ? 20 : 16),
      ),
      child: Icon(st.$1, color: Colors.white, size: wide ? 34 : 26),
    );
    return AppCard(
      key: Key('lab-$labKey'),
      onTap: onTap,
      semanticLabel: '$title. $sub',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [st.$2, Color.lerp(st.$2, st.$3, 0.7)!],
      ),
      padding: const EdgeInsets.all(16),
      child: wide
          ? Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.tx.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: context.tx.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.tx.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.tx.bodySmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
    );
  }
}

class DomainTile extends StatelessWidget {
  final Domain domain;
  final double progress;
  const DomainTile({super.key, required this.domain, required this.progress});

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(domain.id);
    return AppCard(
      key: Key('domain-${domain.id}'),
      onTap: () => context.push('/domain/${domain.id}'),
      semanticLabel: context.lx(domain.titleFor(context.track)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DomainArt(domain.id, size: 46, radius: 15),
              const Spacer(),
              if (progress >= 1)
                Icon(Icons.check_circle_rounded, color: context.c.success)
              else if (progress > 0)
                ProgressRing(value: progress, size: 26, stroke: 4, color: st.a),
            ],
          ),
          const Spacer(),
          Text(
            context.lx(domain.titleFor(context.track)),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.tx.titleSmall,
          ),
        ],
      ),
    );
  }
}

String lessonMeta(BuildContext context, Lesson l) =>
    '${context.t('common.minutes', {'n': l.minutes})} · ${context.t('difficulty.${l.difficulty}')}';

class ContinueCard extends StatelessWidget {
  final Lesson lesson;
  const ContinueCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(lesson.domain);
    return AppCard(
      key: const Key('continue-card'),
      onTap: () => context.push('/lesson/${lesson.id}'),
      child: Row(
        children: [
          LessonThumb(lesson: lesson, width: 96, height: 80),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.lx(lesson.title),
                  style: context.tx.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(lessonMeta(context, lesson), style: context.tx.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: st.a, shape: BoxShape.circle),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class PathCard extends StatelessWidget {
  final Lesson lesson;
  final int step;
  const PathCard({super.key, required this.lesson, required this.step});

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(lesson.domain);
    return SizedBox(
      width: 168 * textScaleOf(context),
      child: AppCard(
        onTap: () => context.push('/lesson/${lesson.id}'),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.a, Color.lerp(st.a, st.b, 0.65)!],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$step',
                    textScaler: TextScaler.noScaling,
                    style: context.tx.labelLarge?.copyWith(color: st.a),
                  ),
                ),
                const Spacer(),
                Icon(st.icon, color: Colors.white.withValues(alpha: 0.9)),
              ],
            ),
            const Spacer(),
            Text(
              context.lx(lesson.title),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.tx.titleSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              lessonMeta(context, lesson),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tx.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// A lesson row used in lists (domain page, filters, bookmarks, teacher mode).
class LessonRow extends ConsumerWidget {
  final Lesson lesson;
  final VoidCallback? onTap;
  final bool showDomain;
  const LessonRow({
    super.key,
    required this.lesson,
    this.onTap,
    this.showDomain = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final content = ref.watch(contentProvider);
    final done = progress.completed.containsKey(lesson.id);
    final locked = lesson.prereqs.any(
      (p) =>
          !progress.completed.containsKey(p) &&
          content.canOpenLesson(p, context.track),
    );
    final c = context.c;
    return AppCard(
      key: Key('lesson-${lesson.id}'),
      onTap: onTap ?? () => context.push('/lesson/${lesson.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          LessonThumb(lesson: lesson),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDomain)
                  Text(
                    context.lx(
                      content.domain(lesson.domain)?.titleFor(context.track) ??
                          L.empty,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tx.labelSmall,
                  ),
                Text(
                  context.lx(lesson.title),
                  style: context.tx.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.lx(lesson.subtitle),
                  style: context.tx.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Pill(
                      lessonMeta(context, lesson),
                      icon: Icons.schedule_rounded,
                    ),
                    if (lesson.interactive != null)
                      Pill(
                        context.t('lesson.hasLab'),
                        icon: Icons.science_rounded,
                      ),
                    if (locked && !done)
                      Pill(
                        context.t('lesson.suggestedAfter'),
                        icon: Icons.low_priority_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            color: done ? c.success : c.inkSoft,
            semanticLabel: done ? context.t('lesson.done') : null,
          ),
        ],
      ),
    );
  }
}

/// A small picture for a lesson in lists: its photo when one exists for this
/// track, otherwise a still mini scene on the topic's colours.
class LessonThumb extends ConsumerWidget {
  final Lesson lesson;
  final double width;
  final double height;
  const LessonThumb({
    super.key,
    required this.lesson,
    this.width = 76,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picture = ref
        .watch(contentProvider)
        .imageForLesson(lesson, context.track);
    final st = DomainStyle.of(lesson.domain);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          width: width,
          height: height,
          child: picture != null
              ? Image.asset(
                  picture.asset,
                  fit: BoxFit.cover,
                  cacheWidth: (width * 3).round(),
                  errorBuilder: (_, _, _) => DomainArt(lesson.domain),
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [st.a, Color.lerp(st.a, st.b, 0.75)!],
                    ),
                  ),
                  child: SceneArt.forLesson(
                    lesson,
                    height: height,
                    animate: false,
                  ),
                ),
        ),
      ),
    );
  }
}
