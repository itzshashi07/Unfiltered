import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../home/cards.dart';
import '../lessons/lesson_visual.dart';

const _moduleLab = {
  'consent': 'consent_sim',
  'relationship': 'relationship_radar',
  'digital': 'digital_safety',
  'communication': 'communication',
};

/// Decision Paths hub for one module (Consent Simulator, Relationship Radar,
/// Digital Safety Lab, Communication Practice).
class ScenarioListScreen extends ConsumerWidget {
  final String module;
  const ScenarioListScreen(this.module, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final lab = _moduleLab[module];
    if (lab == null || !kScenarioModules.contains(module)) {
      return const NotAvailableScreen();
    }
    final list = content.scenariosFor(track, module: module);
    final c = context.c;
    final extra = switch (module) {
      'relationship' when content.visible(content.signals, track).isNotEmpty =>
        'signals',
      'digital'
          when content.visible(content.digitalChallenge, track).isNotEmpty =>
        'digital_challenge',
      _ => null,
    };
    if (list.isEmpty && extra == null) return const NotAvailableScreen();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.$lab.title'))),
      body: PageBody(
        children: [
          ScreenPicture(
            lab: lab,
            scene: switch (module) {
              'consent' => 'stop',
              'relationship' => 'friends',
              'digital' => 'phone',
              _ => 'family',
            },
            domain: switch (module) {
              'consent' => 'd05',
              'relationship' => 'd06',
              'digital' => 'd13',
              _ => 'd18',
            },
          ),
          Text(
            context.t('scen.$module.intro'),
            style: context.tx.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            context.t('scen.fiction'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 16),
          if (extra != null) ...[
            LabCard(
              labKey: extra,
              wide: true,
              onTap: () => context.push('/lab/$extra'),
            ),
            const SizedBox(height: 16),
          ],
          if (list.isNotEmpty)
            Text(context.t('scen.paths'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          for (final s in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('scenario-${s.id}'),
                onTap: () => context.push('/scenario/${s.id}'),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.alt_route_rounded,
                        color: context.isDark ? Colors.white : c.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lx(s.title),
                            style: context.tx.titleMedium,
                          ),
                          Text(
                            context.lx(s.intro),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.tx.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      progress.scenariosDone.contains(s.id)
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      color: progress.scenariosDone.contains(s.id)
                          ? c.success
                          : c.inkSoft,
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

/// Plays one branching scenario: pick a response, see what it leads to.
class ScenarioScreen extends ConsumerStatefulWidget {
  final String id;
  const ScenarioScreen(this.id, {super.key});

  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends ConsumerState<ScenarioScreen> {
  String? _node; // null = intro
  ScenarioChoice? _picked;
  bool _debrief = false;
  int _steps = 0;
  final List<Tone> _tones = [];

  void _restart() => setState(() {
    _node = null;
    _picked = null;
    _debrief = false;
    _steps = 0;
    _tones.clear();
  });

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final s = content.scenarios.cast<Scenario?>().firstWhere(
      (x) => x!.id == widget.id,
      orElse: () => null,
    );
    if (s == null || !s.visibleTo(track)) return const NotAvailableScreen();
    final c = context.c;
    final node = _node == null ? null : s.nodes[_node];
    final refs = [
      for (final r in s.refs)
        if (content.ref(r) != null) content.ref(r)!,
    ];

    Widget body;
    if (_debrief) {
      final good = _tones.where((t) => t == Tone.good).length;
      body = Column(
        key: const Key('scenario-debrief'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Mascot(
              size: 104,
              mood: s.sensitive ? Mood.calm : Mood.happy,
            ),
          ),
          const SizedBox(height: 14),
          Text(context.t('scen.debrief'), style: context.tx.headlineSmall),
          const SizedBox(height: 8),
          Text(context.lx(s.debrief), style: context.tx.bodyLarge),
          const SizedBox(height: 14),
          InfoBanner(
            icon: Icons.insights_rounded,
            text: context.t('scen.summary', {
              'good': good,
              'total': _tones.length,
            }),
          ),
          const SizedBox(height: 14),
          Text(context.t('common.sources'), style: context.tx.labelMedium),
          const SizedBox(height: 8),
          SourceList(refs),
          const SizedBox(height: 8),
          SoftButton(
            label: context.t('scen.again'),
            icon: Icons.refresh_rounded,
            onPressed: _restart,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            key: const Key('scenario-done'),
            label: context.t('common.done'),
            onPressed: () => context.pop(),
          ),
          if (s.sensitive) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/safety'),
                icon: const Icon(Icons.health_and_safety_rounded),
                label: Text(context.t('safety.title')),
              ),
            ),
          ],
        ],
      );
    } else if (node == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Palette.dark, Color(0xFF3B2F96)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SceneArt(
                  kind: switch (s.module) {
                    'consent' => 'stop',
                    'digital' => 'phone',
                    'relationship' =>
                      s.tracks.every((t) => t.index >= Track.d.index)
                          ? 'couple'
                          : 'friends',
                    _ => 'friends',
                  },
                  seed: s.id.hashCode,
                  kids:
                      s.tracks.contains(Track.a) || s.tracks.contains(Track.b),
                  height: 130,
                ),
                const SizedBox(height: 12),
                Text(
                  context.lx(s.title),
                  style: context.tx.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.lx(s.intro),
                  style: context.tx.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(context.t('scen.fiction'), style: context.tx.bodySmall),
          const SizedBox(height: 18),
          PrimaryButton(
            key: const Key('scenario-start'),
            label: context.t('scen.start'),
            icon: Icons.play_arrow_rounded,
            onPressed: () => setState(() => _node = s.start),
          ),
        ],
      );
    } else {
      final picked = _picked;
      body = Column(
        key: ValueKey('$_node-${picked != null}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            context.t('scen.step', {'n': _steps + 1}),
            icon: Icons.flag_rounded,
          ),
          const SizedBox(height: 12),
          AppCard(
            color: c.surfaceAlt,
            child: Text(
              context.lx(node.text),
              style: context.tx.titleMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          if (picked == null) ...[
            Text(
              context.t('scen.choose'),
              style: context.tx.labelLarge?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < node.choices.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  key: Key('choice-$i'),
                  onTap: () => setState(() {
                    _picked = node.choices[i];
                    _tones.add(node.choices[i].tone);
                  }),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.lx(node.choices[i].label),
                          style: context.tx.bodyLarge,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                    ],
                  ),
                ),
              ),
          ] else ...[
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, color: c.inkSoft, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.lx(picked.label),
                      style: context.tx.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: InfoBanner(
                key: const Key('scenario-feedback'),
                icon: switch (picked.tone) {
                  Tone.good => Icons.check_circle_rounded,
                  Tone.okay => Icons.info_rounded,
                  Tone.risky => Icons.report_problem_rounded,
                },
                color: switch (picked.tone) {
                  Tone.good => c.success,
                  Tone.okay => c.warning,
                  Tone.risky => c.danger,
                },
                title: context.t('scen.tone.${picked.tone.name}'),
                text: context.lx(picked.feedback),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              key: const Key('scenario-continue'),
              label: context.t(
                picked.next == null ? 'scen.finish' : 'common.next',
              ),
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                final next = picked.next;
                if (next == null || s.nodes[next] == null) {
                  ref.read(progressProvider.notifier).finishScenario(s.id);
                  setState(() => _debrief = true);
                } else {
                  setState(() {
                    _node = next;
                    _picked = null;
                    _steps++;
                  });
                }
              },
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.lx(s.title),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PageBody(
        children: [
          FadeSlide(
            key: ValueKey('$_node-$_debrief-${_picked != null}'),
            child: body,
          ),
        ],
      ),
    );
  }
}
