import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import 'content.dart';
import 'models.dart';
import 'store.dart';

/// Test Your Knowledge: the website's everyday question bank, shipped offline
/// in assets/content/knowledge/bank.json (written by tools/export_web_content.py).

class KCat {
  final String key;
  final String domain; // app domain used for the question picture
  final IconData icon;
  final Color color;
  final L title;
  final L dek;
  const KCat(
    this.key,
    this.domain,
    this.icon,
    this.color,
    this.title,
    this.dek,
  );
}

const kCats = <KCat>[
  KCat(
    'body',
    'd01',
    Icons.accessibility_new_rounded,
    Color(0xFF6CC4FF),
    L('Body & Puberty', 'Body & Puberty'),
    L(
      'Real names, real changes, zero awkwardness.',
      'Asli naam, asli changes, zero awkwardness.',
    ),
  ),
  KCat(
    'periods',
    'd03',
    Icons.water_drop_rounded,
    Color(0xFFFF677B),
    L('Periods & Menstrual Health', 'Periods & Menstrual Health'),
    L(
      'Cycles, pads, cups, pain and the myths around them.',
      'Cycle, pads, cups, pain aur unke aas-paas ke myths.',
    ),
  ),
  KCat(
    'consent',
    'd05',
    Icons.back_hand_rounded,
    Color(0xFF1FA67A),
    L('Consent & Boundaries', 'Consent & Boundaries'),
    L(
      'Yes, no, maybe, and everything in between.',
      'Haan, na, shayad, aur beech ka sab kuch.',
    ),
  ),
  KCat(
    'relationships',
    'd06',
    Icons.favorite_rounded,
    Color(0xFFFFC247),
    L('Love & Relationships', 'Love & Relationships'),
    L(
      'Crushes, red flags, breakups and respect.',
      'Crush, red flags, breakup aur respect.',
    ),
  ),
  KCat(
    'contraception',
    'd07',
    Icons.verified_user_rounded,
    Color(0xFF8E7BFF),
    L('Contraception & Pregnancy', 'Contraception & Pregnancy'),
    L(
      'What works, what does not, and what to do next.',
      'Kya kaam karta hai, kya nahi, aur aage kya karna hai.',
    ),
  ),
  KCat(
    'sti',
    'd09',
    Icons.medical_services_rounded,
    Color(0xFF2BB8B8),
    L('STIs, HIV & Sexual Health', 'STIs, HIV & Sexual Health'),
    L(
      'Testing, PEP, PrEP, vaccines, minus the stigma.',
      'Testing, PEP, PrEP, vaccines, bina stigma ke.',
    ),
  ),
  KCat(
    'safety',
    'd14',
    Icons.shield_rounded,
    Color(0xFFFF8A3D),
    L('Child Safety', 'Child Safety'),
    L(
      'Safe and unsafe touch, secrets, trusted adults, POCSO.',
      'Safe aur unsafe touch, secrets, trusted adults, POCSO.',
    ),
  ),
  KCat(
    'digital',
    'd13',
    Icons.smartphone_rounded,
    Color(0xFF4AA8F0),
    L('Online Safety', 'Online Safety'),
    L(
      'Photos, sextortion, deepfakes and the first hour.',
      'Photos, sextortion, deepfakes aur pehla ghanta.',
    ),
  ),
  KCat(
    'law',
    'd16',
    Icons.balance_rounded,
    Color(0xFFE0A526),
    L('Law & Your Rights', 'Law & Tumhare Rights'),
    L(
      'Zero FIR, POCSO, POSH, BNS: know your rights.',
      'Zero FIR, POCSO, POSH, BNS: apne rights jaano.',
    ),
  ),
  KCat(
    'gender',
    'd11',
    Icons.diversity_3_rounded,
    Color(0xFF9D8CFF),
    L('Gender & Identity', 'Gender & Identity'),
    L(
      'Stereotypes, LGBTQ+ basics and respect.',
      'Stereotypes, LGBTQ+ basics aur respect.',
    ),
  ),
  KCat(
    'mind',
    'd17',
    Icons.psychology_rounded,
    Color(0xFF34C08E),
    L('Mind, Body Image & Porn', 'Mind, Body Image & Porn'),
    L(
      'Self-esteem, comparison, porn vs reality.',
      'Self-esteem, comparison, porn vs reality.',
    ),
  ),
  KCat(
    'myths',
    'd15',
    Icons.visibility_off_rounded,
    Color(0xFFFF5C77),
    L('Myths vs Facts', 'Myths vs Facts'),
    L(
      'The rumours everyone has heard, busted.',
      'Woh afwaahein jo sabne suni hain, bust.',
    ),
  ),
];

KCat? kCat(String key) {
  for (final c in kCats) {
    if (c.key == key) return c;
  }
  return null;
}

/// One bank question: the app's quiz model plus its topic and difficulty.
class KQ {
  final QuizQ quiz;
  final String cat;
  final int level;
  const KQ(this.quiz, this.cat, this.level);
}

class KnowledgeBank {
  final List<KQ> all;
  const KnowledgeBank(this.all);
  static const empty = KnowledgeBank([]);

  static KnowledgeBank parse(String? raw) {
    if (raw == null) return empty;
    final list = jsonDecode(raw) as List;
    return KnowledgeBank([
      for (final j in list.cast<Map<String, dynamic>>())
        KQ(
          QuizQ.fromJson(j, domain: kCat('${j['cat']}')?.domain ?? ''),
          '${j['cat']}',
          (j['level'] as num?)?.toInt() ?? 2,
        ),
    ]);
  }

  /// Questions this age group may see, optionally from one topic.
  List<KQ> pool(Track track, {String? cat}) => [
    for (final q in all)
      if ((cat == null || q.cat == cat) && q.quiz.tracks.contains(track)) q,
  ];

  /// Topics with enough questions for this age group to make a test.
  List<KCat> catsFor(Track track) => [
    for (final c in kCats)
      if (pool(track, cat: c.key).length >= 5) c,
  ];

  /// Rounded down for headlines ("1,200+").
  int get rounded => all.length >= 100 ? all.length ~/ 100 * 100 : all.length;
}

final knowledgeProvider = FutureProvider<KnowledgeBank>((ref) async {
  final read = ref.watch(knowledgeReaderProvider);
  return KnowledgeBank.parse(await read('knowledge/bank.json'));
});

/// How the bank is read: the app bundle by default, files in tests.
final knowledgeReaderProvider = Provider<ContentReader>(
  (ref) => (p) async {
    try {
      return await rootBundle.loadString('$kContentRoot/$p');
    } catch (_) {
      return null;
    }
  },
);

// ── picking questions ────────────────────────────────────────────────────

/// Today's date in India, as yyyy-mm-dd (the daily set changes at IST midnight).
String istDay([int offsetDays = 0]) {
  final d = DateTime.now().toUtc().add(
    Duration(hours: 5, minutes: 30, days: offsetDays),
  );
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Daily challenge number, counted from the launch on 23 Nov 2026.
int dailyNumber() =>
    DateTime.parse(istDay()).difference(DateTime.parse('2026-11-23')).inDays +
    1;

int _hash(String s) {
  var h = 2166136261;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 16777619) & 0xFFFFFFFF;
  }
  return h;
}

/// Shuffles the options so the answer is not always in the same place.
QuizQ shuffleOptions(QuizQ q, Random rnd) {
  final order = List<int>.generate(q.options.length, (i) => i)..shuffle(rnd);
  return QuizQ(
    id: q.id,
    domain: q.domain,
    type: q.type,
    q: q.q,
    options: [for (final i in order) q.options[i]],
    answer: order.indexOf(q.answer),
    explain: q.explain,
    tracks: q.tracks,
  );
}

/// Takes [n] questions spread across topics (round robin), keeping order within a topic.
List<KQ> spread(List<KQ> qs, int n) {
  final by = <String, List<KQ>>{};
  for (final q in qs) {
    by.putIfAbsent(q.cat, () => []).add(q);
  }
  final lists = by.values.toList();
  final out = <KQ>[];
  for (var k = 0; out.length < n && lists.any((l) => l.length > k); k++) {
    for (final l in lists) {
      if (out.length < n && k < l.length) out.add(l[k]);
    }
  }
  return out;
}

enum KMode { topic, daily, mega }

/// Builds a test. Daily: the same 10 for everyone on the same day and age group.
/// Topic and mega prefer questions the learner has not seen yet.
List<QuizQ> buildKnowledgeTest(
  KnowledgeBank bank,
  Track track, {
  required KMode mode,
  String? cat,
  int length = 10,
  Set<String> seen = const {},
  Random? random,
}) {
  final pool = bank.pool(track, cat: mode == KMode.topic ? cat : null);
  if (mode == KMode.daily) {
    final rnd = Random(_hash('${istDay()}|${track.name}'));
    final picked = spread([...pool]..shuffle(rnd), 10)
      ..sort((a, b) => a.level.compareTo(b.level));
    return [for (final q in picked) shuffleOptions(q.quiz, rnd)];
  }
  final rnd = random ?? Random();
  final fresh = [...pool]..shuffle(rnd);
  // unseen questions first (stable for the random order)
  final ordered = [
    ...fresh.where((q) => !seen.contains(q.quiz.id)),
    ...fresh.where((q) => seen.contains(q.quiz.id)),
  ];
  final picked =
      (mode == KMode.mega ? spread(ordered, 25) : ordered.take(length).toList())
        ..sort((a, b) => a.level.compareTo(b.level));
  return [for (final q in picked) shuffleOptions(q.quiz, rnd)];
}

// ── scores (on this device only; cleared by "delete all data") ───────────

class KScores {
  final Map<String, List<int>> best; // key -> [score, total]
  final Map<String, List<int>> daily; // yyyy-mm-dd -> [score, total]
  final List<String> seen;
  final String name;
  final String age;
  const KScores({
    this.best = const {},
    this.daily = const {},
    this.seen = const [],
    this.name = '',
    this.age = '',
  });

  int get dayStreak {
    var n = 0;
    for (
      var k = daily.containsKey(istDay()) ? 0 : -1;
      daily.containsKey(istDay(k));
      k--
    ) {
      n++;
    }
    return n;
  }

  Map<String, dynamic> toJson() => {
    'best': best,
    'daily': daily,
    'seen': seen,
    'name': name,
    'age': age,
  };

  static Map<String, List<int>> _m(dynamic j) => {
    if (j is Map)
      for (final e in j.entries)
        '${e.key}': [for (final v in (e.value as List)) (v as num).toInt()],
  };

  factory KScores.fromJson(Map<String, dynamic> j) => KScores(
    best: _m(j['best']),
    daily: _m(j['daily']),
    seen: [for (final s in (j['seen'] as List? ?? const [])) '$s'],
    name: '${j['name'] ?? ''}',
    age: '${j['age'] ?? ''}',
  );
}

class KScoresNotifier extends Notifier<KScores> {
  static const key = '${AppStore.prefix}kt';

  @override
  KScores build() {
    final s = ref.read(storeProvider).prefs.getString(key);
    if (s == null) return const KScores();
    try {
      return KScores.fromJson((jsonDecode(s) as Map).cast<String, dynamic>());
    } catch (_) {
      return const KScores();
    }
  }

  void _save(KScores s) {
    state = s;
    ref.read(storeProvider).prefs.setString(key, jsonEncode(s.toJson()));
  }

  void record(
    String testKey,
    int score,
    int total,
    List<String> ids, {
    bool daily = false,
  }) {
    final best = {...state.best};
    final prev = best[testKey];
    if (prev == null || score * prev[1] > prev[0] * total) {
      best[testKey] = [score, total];
    }
    final days = {...state.daily};
    if (daily) days.putIfAbsent(istDay(), () => [score, total]);
    final seen = {...state.seen, ...ids}.toList();
    _save(
      KScores(
        best: best,
        daily: days,
        seen: seen.length > 3000 ? seen.sublist(seen.length - 3000) : seen,
        name: state.name,
        age: state.age,
      ),
    );
  }

  void setMe(String name, String age) => _save(
    KScores(
      best: state.best,
      daily: state.daily,
      seen: state.seen,
      name: name,
      age: age,
    ),
  );

  void reset() => state = const KScores();
}

final kScoresProvider = NotifierProvider<KScoresNotifier, KScores>(
  KScoresNotifier.new,
);
