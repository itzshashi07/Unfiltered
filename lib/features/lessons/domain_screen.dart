import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../home/ask_tab.dart';
import '../home/cards.dart';
import 'lesson_visual.dart';

class DomainScreen extends ConsumerStatefulWidget {
  final String id;
  const DomainScreen(this.id, {super.key});

  @override
  ConsumerState<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends ConsumerState<DomainScreen> {
  String? _openFaq;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final d = content.domain(widget.id);
    final lessons = content.lessonsFor(track, domain: widget.id);
    if (d == null || !d.visibleTo(track) || lessons.isEmpty) {
      return const NotAvailableScreen();
    }
    final st = DomainStyle.of(d.id);
    final p = content.domainProgress(d.id, track, progress.completedIds);
    final myths = content.mythsFor(track, domain: d.id);
    final faqs = content.faqsFor(track, domain: d.id);
    final quiz = content.quizFor(track, domain: d.id);
    final gloss = content
        .glossaryFor(track)
        .where((g) => g.domain == d.id)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260 + 106 * textScaleOf(context),
            backgroundColor: st.a,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [st.a, Color.lerp(st.a, st.b, 0.75)!],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 56, 22, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SceneArt.forLesson(lessons.first, height: 104),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                st.icon,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const Spacer(),
                            ProgressRing(
                              value: p,
                              size: 50,
                              stroke: 6,
                              color: Colors.white,
                              track: Colors.white24,
                              child: Text(
                                '${(p * 100).round()}%',
                                textScaler: TextScaler.noScaling,
                                style: context.tx.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.lx(d.titleFor(context.track)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.tx.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.lx(d.tagline),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.tx.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (content.imageFor(track, domain: d.id) != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: ContentPicture(
                  image: content.imageFor(track, domain: d.id)!,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SectionTitle(
              context.t('domain.lessons', {'n': lessons.length}),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: lessons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => FadeSlide(
                delayMs: i * 50,
                child: LessonRow(lesson: lessons[i]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  if (myths.isNotEmpty)
                    Expanded(
                      child: _Action(
                        icon: Icons.fact_check_rounded,
                        label: context.t('domain.myths', {'n': myths.length}),
                        onTap: () =>
                            context.push('/lab/myth_buster?domain=${d.id}'),
                      ),
                    ),
                  if (myths.isNotEmpty && quiz.isNotEmpty)
                    const SizedBox(width: 10),
                  if (quiz.isNotEmpty)
                    Expanded(
                      child: _Action(
                        icon: Icons.quiz_rounded,
                        label: context.t('domain.quiz', {'n': quiz.length}),
                        onTap: () => context.push('/quiz/domain/${d.id}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (faqs.isNotEmpty) ...[
            SliverToBoxAdapter(child: SectionTitle(context.t('domain.faqs'))),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => FaqCard(
                  faq: faqs[i],
                  open: _openFaq == faqs[i].id,
                  onToggle: () => setState(
                    () => _openFaq = _openFaq == faqs[i].id ? null : faqs[i].id,
                  ),
                ),
              ),
            ),
          ],
          if (gloss.isNotEmpty) ...[
            SliverToBoxAdapter(child: SectionTitle(context.t('domain.words'))),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final g in gloss)
                      for (final t in g.terms)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${context.lx(t.term)}  ',
                                  style: context.tx.titleSmall,
                                ),
                                TextSpan(
                                  text: context.lx(t.def),
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
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    color: context.c.primarySoft,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.isDark ? Colors.white : context.c.primary),
        const SizedBox(height: 8),
        Text(label, style: context.tx.titleSmall),
      ],
    ),
  );
}
