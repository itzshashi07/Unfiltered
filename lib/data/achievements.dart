import 'package:flutter/material.dart';

import '../core/l10n.dart';
import 'content.dart';
import 'store.dart';

/// A private learning milestone. There are no leaderboards and nothing is shared.
class Badge {
  final String id;
  final IconData icon;
  final int goal;
  final int Function(Progress p, ContentRepository c, Track t) current;
  const Badge(this.id, this.icon, this.goal, this.current);

  String get titleKey => 'badge.$id.title';
  String get descKey => 'badge.$id.desc';

  int value(Progress p, ContentRepository c, Track t) =>
      current(p, c, t).clamp(0, goal);
  bool earned(Progress p, ContentRepository c, Track t) =>
      current(p, c, t) >= goal;
}

int _domainsDone(Progress p, ContentRepository c, Track t) => c
    .domainsFor(t)
    .where((d) => c.domainProgress(d.id, t, p.completedIds) >= 1)
    .length;

final kBadges = <Badge>[
  Badge('first', Icons.flag_rounded, 1, (p, c, t) => p.completed.length),
  Badge(
    'five',
    Icons.local_fire_department_rounded,
    5,
    (p, c, t) => p.completed.length,
  ),
  Badge(
    'fifteen',
    Icons.rocket_launch_rounded,
    15,
    (p, c, t) => p.completed.length,
  ),
  Badge('domain', Icons.workspace_premium_rounded, 1, _domainsDone),
  Badge('domains3', Icons.military_tech_rounded, 3, _domainsDone),
  Badge(
    'myth10',
    Icons.fact_check_rounded,
    10,
    (p, c, t) => p.mythsSeen.length,
  ),
  Badge(
    'myth30',
    Icons.psychology_rounded,
    30,
    (p, c, t) => p.mythsSeen.length,
  ),
  Badge(
    'quiz80',
    Icons.emoji_events_rounded,
    1,
    (p, c, t) => p.quizBest.values.where((v) => v >= 80).length,
  ),
  Badge(
    'scenario3',
    Icons.alt_route_rounded,
    3,
    (p, c, t) => p.scenariosDone.length,
  ),
  Badge('labs4', Icons.science_rounded, 4, (p, c, t) => p.labsVisited.length),
  Badge('circle', Icons.groups_rounded, 3, (p, c, t) => p.support.length),
  Badge(
    'final',
    Icons.verified_rounded,
    1,
    (p, c, t) => p.quizBest.containsKey('final') ? 1 : 0,
  ),
];
