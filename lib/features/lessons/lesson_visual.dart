import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';

/// Icon vocabulary for "at a glance" visuals. Content files may only use these
/// keys (see assets/content/extras/visual_icons.json, checked by the validator).
const kVisualIcons = <String, IconData>{
  'check': Icons.check_circle_rounded,
  'cross': Icons.cancel_rounded,
  'warning': Icons.warning_rounded,
  'info': Icons.info_rounded,
  'idea': Icons.lightbulb_rounded,
  'star': Icons.star_rounded,
  'heart': Icons.favorite_rounded,
  'heart_broken': Icons.heart_broken_rounded,
  'shield': Icons.shield_rounded,
  'lock': Icons.lock_rounded,
  'key': Icons.key_rounded,
  'clock': Icons.schedule_rounded,
  'date': Icons.event_rounded,
  'hourglass': Icons.hourglass_bottom_rounded,
  'repeat': Icons.repeat_rounded,
  'up': Icons.arrow_upward_rounded,
  'down': Icons.arrow_downward_rounded,
  'plus': Icons.add_circle_rounded,
  'minus': Icons.remove_circle_rounded,
  'stop': Icons.back_hand_rounded,
  'talk': Icons.forum_rounded,
  'listen': Icons.hearing_rounded,
  'ask': Icons.help_rounded,
  'yes': Icons.thumb_up_rounded,
  'no': Icons.thumb_down_rounded,
  'people': Icons.groups_rounded,
  'person': Icons.person_rounded,
  'child': Icons.child_care_rounded,
  'family': Icons.family_restroom_rounded,
  'friends': Icons.diversity_1_rounded,
  'doctor': Icons.medical_services_rounded,
  'hospital': Icons.local_hospital_rounded,
  'clinic': Icons.health_and_safety_rounded,
  'medicine': Icons.medication_rounded,
  'test': Icons.science_rounded,
  'vaccine': Icons.vaccines_rounded,
  'microscope': Icons.biotech_rounded,
  'germ': Icons.coronavirus_rounded,
  'drop': Icons.water_drop_rounded,
  'fever': Icons.thermostat_rounded,
  'pain': Icons.sick_rounded,
  'sleep': Icons.bedtime_rounded,
  'food': Icons.restaurant_rounded,
  'water': Icons.local_drink_rounded,
  'exercise': Icons.fitness_center_rounded,
  'wash': Icons.clean_hands_rounded,
  'shower': Icons.shower_rounded,
  'brain': Icons.psychology_rounded,
  'happy': Icons.mood_rounded,
  'sad': Icons.sentiment_dissatisfied_rounded,
  'angry': Icons.mood_bad_rounded,
  'calm': Icons.self_improvement_rounded,
  'growth': Icons.trending_up_rounded,
  'height': Icons.height_rounded,
  'body': Icons.accessibility_new_rounded,
  'baby': Icons.child_friendly_rounded,
  'pregnant': Icons.pregnant_woman_rounded,
  'egg': Icons.egg_rounded,
  'hormone': Icons.bolt_rounded,
  'cycle': Icons.autorenew_rounded,
  'phone': Icons.smartphone_rounded,
  'chat': Icons.chat_rounded,
  'camera': Icons.photo_camera_rounded,
  'no_photo': Icons.no_photography_rounded,
  'block': Icons.block_rounded,
  'report': Icons.flag_rounded,
  'delete': Icons.delete_rounded,
  'eye': Icons.visibility_rounded,
  'eye_off': Icons.visibility_off_rounded,
  'online': Icons.public_rounded,
  'game': Icons.sports_esports_rounded,
  'money': Icons.payments_rounded,
  'gift': Icons.card_giftcard_rounded,
  'law': Icons.gavel_rounded,
  'police': Icons.local_police_rounded,
  'id': Icons.badge_rounded,
  'document': Icons.description_rounded,
  'school': Icons.school_rounded,
  'teacher': Icons.co_present_rounded,
  'book': Icons.menu_book_rounded,
  'home': Icons.home_rounded,
  'work': Icons.work_rounded,
  'travel': Icons.directions_bus_rounded,
  'party': Icons.celebration_rounded,
  'alcohol': Icons.local_bar_rounded,
  'smoke': Icons.smoking_rooms_rounded,
  'run': Icons.directions_run_rounded,
  'sos': Icons.sos_rounded,
  'call': Icons.call_rounded,
  'search': Icons.search_rounded,
  'compass': Icons.explore_rounded,
  'balance': Icons.balance_rounded,
  'transgender': Icons.transgender_rounded,
  'male': Icons.male_rounded,
  'female': Icons.female_rounded,
  'diversity': Icons.diversity_3_rounded,
  'wheelchair': Icons.accessible_rounded,
  'elder': Icons.elderly_rounded,
  'face': Icons.face_rounded,
  'weight': Icons.monitor_weight_rounded,
  'fire': Icons.local_fire_department_rounded,
  'mask': Icons.theater_comedy_rounded,
  'puzzle': Icons.extension_rounded,
  'target': Icons.track_changes_rounded,
  'path': Icons.alt_route_rounded,
  'handshake': Icons.handshake_rounded,
  'care': Icons.volunteer_activism_rounded,
  'support': Icons.support_rounded,
  'umbrella': Icons.umbrella_rounded,
  'sun': Icons.wb_sunny_rounded,
  'moon': Icons.dark_mode_rounded,
};

/// Keys drawn as realistic object illustrations instead of an icon.
const kVisualObjects = {
  'pad',
  'tampon',
  'cup',
  'cloth',
  'condom',
  'condom_in',
  'pill',
  'iud',
  'iud_cu', //
  'implant', 'injection', 'calendar', 'emergency', 'pause', 'warn', 'question',
};

bool isVisualIcon(String key) =>
    kVisualIcons.containsKey(key) || kVisualObjects.contains(key);

class _Glyph extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const _Glyph(this.name, this.color, {this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (kVisualObjects.contains(name)) return ObjectArt(name, size: size);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(
          kVisualIcons[name] ?? Icons.info_rounded,
          color: color,
          size: size * 0.55,
        ),
      ),
    );
  }
}

/// "At a glance": the lesson's key idea as steps, a fact grid or a comparison.
class LessonVisualCard extends ConsumerWidget {
  final LessonVisual visual;
  final String domain;
  const LessonVisualCard({
    super.key,
    required this.visual,
    required this.domain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = DomainStyle.of(domain);
    final c = context.c;
    final accent = context.isDark
        ? Color.lerp(st.a, Colors.white, 0.35)!
        : st.a;
    return AppCard(
      key: const Key('lesson-visual'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('visual.glance'),
            style: context.tx.labelMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(context.lx(visual.title), style: context.tx.titleLarge),
          ),
          const SizedBox(height: 14),
          switch (visual.type) {
            'steps' => _steps(context, accent, c),
            'compare' => _compare(context, c),
            _ => _grid(context, accent),
          },
        ],
      ),
    );
  }

  Widget _steps(BuildContext context, Color accent, AppColors c) => Column(
    children: [
      for (var i = 0; i < visual.items.length; i++)
        FadeSlide(
          delayMs: i * 140,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _StepPulse(
                          index: i,
                          count: visual.items.length,
                          child: _Glyph(visual.items[i].icon, accent),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: ExcludeSemantics(
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${i + 1}',
                                textScaler: TextScaler.noScaling,
                                style: context.tx.labelSmall?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (i < visual.items.length - 1)
                      Expanded(
                        child: Container(
                          width: 3,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: c.outline,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < visual.items.length - 1 ? 16 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${context.lx(visual.items[i].label)}',
                          style: context.tx.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.lx(visual.items[i].text),
                          style: context.tx.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _grid(BuildContext context, Color accent) => LayoutBuilder(
    builder: (context, box) {
      final two = box.maxWidth >= 300 && textScaleOf(context) < 1.35;
      final w = two ? (box.maxWidth - 12) / 2 : box.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final (i, it) in visual.items.indexed)
            FadeSlide(
              delayMs: i * 110,
              child: SizedBox(
                width: w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Glyph(it.icon, accent, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lx(it.label),
                            style: context.tx.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.lx(it.text),
                            style: context.tx.bodySmall?.copyWith(
                              color: context.c.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _compare(BuildContext context, AppColors c) {
    Widget side(VisualSide s) {
      // Tone is carried by an icon and a word, never by colour alone.
      final (color, mark) = switch (s.tone) {
        'good' => (c.success, Icons.check_circle_rounded),
        'bad' => (c.danger, Icons.cancel_rounded),
        _ => (c.primary, Icons.info_rounded),
      };
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: context.isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(mark, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.lx(s.title),
                    style: context.tx.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final p in s.points)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(context.lx(p), style: context.tx.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 340 && textScaleOf(context) < 1.3;
        // The two sides slide in one after the other.
        final l = FadeSlide(child: side(visual.left!));
        final r = FadeSlide(delayMs: 220, child: side(visual.right!));
        return wide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: l),
                    const SizedBox(width: 10),
                    Expanded(child: r),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [l, const SizedBox(height: 10), r],
              );
      },
    );
  }
}

/// A bundled picture with its caption and, for generated pictures, an honest label.
class ContentPicture extends StatelessWidget {
  final ContentImage image;
  final double aspect;
  final double radius;
  final Color? captionColor;
  final bool showCaption;
  const ContentPicture({
    super.key,
    required this.image,
    this.aspect = 3 / 2,
    this.radius = 22,
    this.captionColor,
    this.showCaption = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = captionColor ?? context.c.ink;
    return Column(
      key: Key('picture-${image.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AspectRatio(
            aspectRatio: aspect,
            child: Image.asset(
              image.asset,
              fit: BoxFit.cover,
              semanticLabel: context.lx(image.alt),
              errorBuilder: (_, _, _) => Container(
                color: context.c.surfaceAlt,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: context.c.inkSoft,
                ),
              ),
            ),
          ),
        ),
        if (showCaption) ...[
          const SizedBox(height: 8),
          Text(
            context.lx(image.caption),
            style: context.tx.bodyMedium?.copyWith(color: color),
          ),
          if (image.generated)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                context.t('image.ai'),
                style: context.tx.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.75),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// The picture assigned to a lab or screen, if there is one for this track.
class ScreenPicture extends ConsumerWidget {
  final String? lab;
  final String? screen;

  /// Animated scene shown when no picture exists for this screen and track,
  /// drawn on the colours of [domain].
  final String? scene;
  final String domain;
  const ScreenPicture({
    super.key,
    this.lab,
    this.screen,
    this.scene,
    this.domain = 'd18',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref
        .watch(contentProvider)
        .imageFor(context.track, lab: lab, screen: screen);
    if (image == null) {
      if (scene == null) return const SizedBox.shrink();
      return SceneBanner(
        kind: scene!,
        domain: domain,
        kids: context.track.isChild,
        seed: (lab ?? screen ?? scene!).hashCode,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ContentPicture(image: image),
    );
  }
}

/// An animated scene on a domain's colours.
class SceneBanner extends StatelessWidget {
  final String kind;
  final String domain;
  final bool kids;
  final int seed;
  final double height;
  const SceneBanner({
    super.key,
    required this.kind,
    required this.domain,
    this.kids = false,
    this.seed = 1,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(domain);
    return Container(
      key: Key('scene-banner-$kind'),
      height: height,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.a, Color.lerp(st.a, st.b, 0.75)!],
        ),
      ),
      child: SceneArt(kind: kind, kids: kids, seed: seed, height: height),
    );
  }
}

/// What the owner asked every legal lesson to show: jurisdiction, the laws,
/// official sources, when it was last checked, and the review status.
class LegalBox extends ConsumerWidget {
  final Lesson lesson;
  const LegalBox({super.key, required this.lesson});

  /// Legal lessons: the laws domain, or any lesson that names its laws.
  static bool appliesTo(Lesson l) => l.domain == 'd16' || l.laws.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final c = context.c;
    final official = [
      for (final r in lesson.refs)
        if (content.ref(r) != null &&
            content.ref(r)!.category.startsWith('india'))
          content.ref(r)!,
    ];
    final laws = lesson.laws.isNotEmpty
        ? [for (final l in lesson.laws) context.lx(l)]
        : [
            for (final r in official)
              if (r.category == 'india-law') r.title,
          ];
    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.tx.bodyMedium)),
        ],
      ),
    );
    return AppCard(
      key: const Key('legal-box'),
      color: c.primarySoft.withValues(alpha: context.isDark ? 0.6 : 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                color: context.isDark ? Colors.white : c.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t('legalbox.title'),
                  style: context.tx.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          line(Icons.public_rounded, context.t('legalbox.jurisdiction')),
          if (laws.isNotEmpty)
            line(
              Icons.description_rounded,
              '${context.t('legalbox.laws')}: ${laws.join(' · ')}',
            ),
          line(
            Icons.event_available_rounded,
            content.legalChecked == null
                ? context.t('legalbox.unchecked')
                : context.t('legalbox.checked', {
                    'date': content.legalChecked!,
                  }),
          ),
          line(Icons.pending_actions_rounded, context.t('legalbox.status')),
          line(Icons.update_rounded, context.t('legalbox.change')),
          if (official.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(context.t('legalbox.sources'), style: context.tx.labelMedium),
            const SizedBox(height: 8),
            SourceList(official),
          ],
        ],
      ),
    );
  }
}

/// A small animated scene on the topic's colours, for places that were text
/// only: FAQ answers, myth cards, quiz questions, guides. When a real picture
/// exists for [lesson] on this track it is shown instead.
class TopicBanner extends ConsumerWidget {
  final String domain;
  final List<Track> tracks;
  final int seed;
  final double height;
  final String? lesson;

  /// Optional icon shown as a badge in the corner (for example a myth stamp).
  final Widget? badge;
  const TopicBanner({
    super.key,
    required this.domain,
    required this.tracks,
    this.seed = 1,
    this.height = 112,
    this.lesson,
    this.badge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final l = lesson == null ? null : content.lesson(lesson!);
    final picture = l != null && l.visibleTo(track)
        ? content.imageForLesson(l, track)
        : null;
    if (picture != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ContentPicture(image: picture, radius: 18),
      );
    }
    final st = DomainStyle.of(domain);
    return Container(
      key: const Key('topic-banner'),
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.a, Color.lerp(st.a, st.b, 0.75)!],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SceneArt.forTopic(
              domain,
              tracks,
              seed: seed,
              height: height,
            ),
          ),
          if (badge != null) Positioned(top: 10, right: 10, child: badge!),
        ],
      ),
    );
  }
}

/// Lights up each step in turn, over and over, like an animated diagram.
class _StepPulse extends StatefulWidget {
  final int index;
  final int count;
  final Widget child;
  const _StepPulse({
    required this.index,
    required this.count,
    required this.child,
  });

  @override
  State<_StepPulse> createState() => _StepPulseState();
}

class _StepPulseState extends State<_StepPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1100 * widget.count),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reducedMotion) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final local = _c.value * widget.count - widget.index;
        final s = local >= 0 && local < 1 ? math.sin(local * math.pi) : 0.0;
        return Transform.scale(scale: 1 + 0.16 * s, child: child);
      },
      child: widget.child,
    );
  }
}
