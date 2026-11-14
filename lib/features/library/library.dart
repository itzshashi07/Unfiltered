import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/achievements.dart';
import '../../data/models.dart';
import '../../data/search.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../home/cards.dart';

// ───────────────────────── Glossary ─────────────────────────

class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final sets = content.glossaryFor(context.track);
    final n = SearchEngine.normalize(_q);
    bool match(GlossaryTerm t) =>
        n.isEmpty ||
        [
          ...t.term.all,
          ...t.def.all,
        ].any((s) => SearchEngine.normalize(s).contains(n));
    final shown = [
      for (final g in sets)
        if (g.terms.any(match)) g,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.glossary.title'))),
      body: PageBody(
        children: [
          TextField(
            key: const Key('glossary-search'),
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: context.t('glossary.hint'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (shown.isEmpty)
            EmptyState(
              title: context.t('glossary.empty'),
              body: context.t('glossary.empty.body'),
            )
          else
            for (final g in shown) ...[
              Row(
                children: [
                  DomainArt(g.domain, size: 32, radius: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.lx(g.title),
                      style: context.tx.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final t in g.terms.where(match))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.lx(t.term), style: context.tx.titleMedium),
                        if (context.lang != Lang.en &&
                            t.term.en != context.lx(t.term))
                          Text(t.term.en, style: context.tx.bodySmall),
                        const SizedBox(height: 4),
                        Text(context.lx(t.def), style: context.tx.bodyMedium),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

// ───────────────────────── Achievements ─────────────────────────

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final c = context.c;
    final domains = content.domainsFor(track);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.achievements.title'))),
      body: PageBody(
        children: [
          Text(
            context.t('ach.note'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 16),
          for (final b in kBadges)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Builder(
                builder: (context) {
                  final earned = b.earned(progress, content, track);
                  final v = b.value(progress, content, track);
                  return AppCard(
                    key: Key('badge-${b.id}'),
                    padding: const EdgeInsets.all(14),
                    semanticLabel:
                        '${context.t(b.titleKey)}. ${context.t(earned ? 'ach.earned' : 'ach.locked')}. $v/${b.goal}',
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: earned
                                ? const LinearGradient(
                                    colors: [Palette.purple, Palette.coral],
                                  )
                                : null,
                            color: earned ? null : c.surfaceAlt,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            b.icon,
                            color: earned ? Colors.white : c.inkSoft,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(b.titleKey),
                                style: context.tx.titleMedium,
                              ),
                              Text(
                                context.t(b.descKey),
                                style: context.tx.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: v / b.goal,
                                  minHeight: 6,
                                  color: earned ? c.success : c.primary,
                                  backgroundColor: c.surfaceAlt,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        earned
                            ? Icon(Icons.check_circle_rounded, color: c.success)
                            : Text(
                                '$v/${b.goal}',
                                style: context.tx.labelMedium,
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Text(context.t('ach.topics'), style: context.tx.headlineSmall),
          const SizedBox(height: 12),
          for (final d in domains)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  DomainArt(d.id, size: 36, radius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.lx(d.titleFor(context.track)),
                          style: context.tx.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: content.domainProgress(
                              d.id,
                              track,
                              progress.completedIds,
                            ),
                            minHeight: 6,
                            color: DomainStyle.of(d.id).a,
                            backgroundColor: c.surfaceAlt,
                            semanticsLabel: context.lx(d.titleFor(context.track)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(content.domainProgress(d.id, track, progress.completedIds) * 100).round()}%',
                    style: context.tx.labelMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Private notes ─────────────────────────

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(progressProvider).notes;
    final n = ref.read(progressProvider.notifier);
    final c = context.c;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('me.notes.title')),
        actions: [
          if (notes.isNotEmpty)
            IconButton(
              key: const Key('notes-delete-all'),
              tooltip: context.t('notes.deleteAll'),
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(ctx.t('notes.deleteAll')),
                    content: Text(ctx.t('notes.deleteAll.body')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(ctx.t('common.cancel')),
                      ),
                      FilledButton(
                        key: const Key('notes-delete-all-confirm'),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(ctx.t('common.delete')),
                      ),
                    ],
                  ),
                );
                if (ok == true) n.deleteAllNotes();
              },
            ),
        ],
      ),
      body: PageBody(
        children: [
          InfoBanner(
            icon: Icons.lock_outline_rounded,
            text: context.t('notes.privacy'),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('notes-field'),
            controller: _ctrl,
            minLines: 2,
            maxLines: 6,
            maxLength: 600,
            decoration: InputDecoration(hintText: context.t('notes.hint')),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            key: const Key('notes-save'),
            label: context.t('notes.save'),
            icon: Icons.add_rounded,
            onPressed: () {
              n.addNote(_ctrl.text);
              _ctrl.clear();
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 18),
          if (notes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                context.t('notes.empty'),
                style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final note in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  key: Key('note-${note.id}'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.created, style: context.tx.labelSmall),
                            const SizedBox(height: 4),
                            Text(note.text, style: context.tx.bodyLarge),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: context.t('common.delete'),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: c.inkSoft,
                        ),
                        onPressed: () => n.deleteNote(note.id),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ───────────────────────── Bookmarks ─────────────────────────

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final lessons = [
      for (final id in progress.bookmarks)
        if (content.canOpenLesson(id, track)) content.lesson(id)!,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.bookmarks.title'))),
      body: lessons.isEmpty
          ? EmptyState(
              title: context.t('bookmarks.empty'),
              body: context.t('bookmarks.empty.body'),
            )
          : PageBody(
              children: [
                for (final l in lessons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LessonRow(lesson: l, showDomain: true),
                  ),
              ],
            ),
    );
  }
}

// ───────────────────────── References Center ─────────────────────────

class ReferencesScreen extends ConsumerWidget {
  const ReferencesScreen({super.key});

  static const _order = [
    'cse',
    'medical',
    'india-health',
    'india-law',
    'india-support',
    'platform',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final c = context.c;
    final counts = content.counts;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.references.title'))),
      body: PageBody(
        children: [
          InfoBanner(
            icon: Icons.pending_actions_rounded,
            color: c.warning,
            title: context.t('refs.review.title'),
            text: context.t('refs.review.body'),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('refs.inside'), style: context.tx.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in const [
                      'lessons',
                      'faqs',
                      'myths',
                      'quiz',
                      'scenarios',
                      'glossaryTerms',
                      'references',
                    ])
                      Pill('${counts[k]} ${context.t('refs.count.$k')}'),
                  ],
                ),
              ],
            ),
          ),
          for (final cat in _order)
            if (content.refs.values.any((r) => r.category == cat)) ...[
              const SizedBox(height: 20),
              Text(context.t('refs.cat.$cat'), style: context.tx.titleLarge),
              const SizedBox(height: 10),
              SourceList([
                for (final r in content.refs.values)
                  if (r.category == cat) r,
              ]),
            ],
          const SizedBox(height: 14),
          Text(context.t('refs.license'), style: context.tx.bodySmall),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/legal/credits'),
              child: Text(context.t('settings.credits')),
            ),
          ),
        ],
      ),
    );
  }
}
