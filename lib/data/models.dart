import 'package:flutter/foundation.dart';

import '../core/l10n.dart';

List<Track> _tracks(dynamic j) => [
  if (j is List)
    for (final t in j)
      if (TrackX.parse('$t') != null) TrackX.parse('$t')!,
];
List<String> _strs(dynamic j) => [
  if (j is List)
    for (final s in j) '$s',
];
List<L> _ls(dynamic j) => [
  if (j is List)
    for (final s in j) L.from(s),
];
List<Map<String, dynamic>> _maps(dynamic j) => [
  if (j is List)
    for (final m in j)
      if (m is Map) m.cast<String, dynamic>(),
];

/// Anything that is only shown to learners on specific tracks.
mixin Tracked {
  List<Track> get tracks;
  bool visibleTo(Track t) => tracks.contains(t);
}

/// "Topics I want to explore": who a piece of content is mainly about or for.
/// This organises content; it is never an access restriction and never an
/// identity question. Anatomy is tagged separately with [BodyTopic].
enum Audience { men, women, transNb, intersex, everyone }

extension AudienceX on Audience {
  /// Key used in the content JSON and in saved settings.
  String get key =>
      const ['men', 'women', 'trans_nb', 'intersex', 'everyone'][index];
  String get labelKey => 'filter.audience.$key';
  static Audience? parse(String? s) {
    for (final a in Audience.values) {
      if (a.key == s) return a;
    }
    return null;
  }
}

/// Body-related topic of a piece of content, independent of anyone's gender.
enum BodyTopic {
  penisTesticular,
  vulvaVaginal,
  menstrual,
  pregnancyRepro,
  hormonesChanges,
}

extension BodyTopicX on BodyTopic {
  String get key => const [
    'penis_testicular',
    'vulva_vaginal',
    'menstrual',
    'pregnancy_repro',
    'hormones_changes',
  ][index];
  String get labelKey => 'filter.body.$key';
  static BodyTopic? parse(String? s) {
    for (final b in BodyTopic.values) {
      if (b.key == s) return b;
    }
    return null;
  }
}

List<Audience> _audience(dynamic j) {
  final out = <Audience>[
    if (j is List)
      for (final a in j)
        if (AudienceX.parse('$a') != null) AudienceX.parse('$a')!,
  ];
  // Untagged content is treated as being for everyone.
  return out.isEmpty ? const [Audience.everyone] : out;
}

List<BodyTopic> _body(dynamic j) => [
  if (j is List)
    for (final b in j)
      if (BodyTopicX.parse('$b') != null) BodyTopicX.parse('$b')!,
];

/// Content that carries explicit audience and body-topic tags.
mixin Topical {
  List<Audience> get audience;
  List<BodyTopic> get body;
}

/// The learner's optional "Topics I want to explore" selection.
/// Empty = show all. Within a group the chips are OR-ed; the two groups are
/// AND-ed. It only ever narrows what the age track already allows.
@immutable
class TopicFilter {
  final Set<Audience> audience;
  final Set<BodyTopic> body;
  const TopicFilter({this.audience = const {}, this.body = const {}});
  static const all = TopicFilter();

  bool get isActive => audience.isNotEmpty || body.isNotEmpty;
  int get count => audience.length + body.length;

  bool matches(Topical item) =>
      (audience.isEmpty || item.audience.any(audience.contains)) &&
      (body.isEmpty || item.body.any(body.contains));

  TopicFilter toggleAudience(Audience a) => TopicFilter(
    audience: audience.contains(a)
        ? ({...audience}..remove(a))
        : {...audience, a},
    body: body,
  );

  TopicFilter toggleBody(BodyTopic b) => TopicFilter(
    audience: audience,
    body: body.contains(b) ? ({...body}..remove(b)) : {...body, b},
  );

  @override
  bool operator ==(Object other) =>
      other is TopicFilter &&
      setEquals(other.audience, audience) &&
      setEquals(other.body, body);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(audience),
    Object.hashAllUnordered(body),
  );
}

@immutable
class Domain with Tracked {
  final String id;
  final L title;

  /// Optional gentler title for tracks A and B (for example d12, whose full
  /// title names pornography, a word the 9-12 lessons deliberately avoid).
  final L? youngTitle;
  final L tagline;
  final List<int> unesco;
  @override
  final List<Track> tracks;
  final bool sensitive;
  const Domain({
    required this.id,
    required this.title,
    this.youngTitle,
    required this.tagline,
    required this.unesco,
    required this.tracks,
    required this.sensitive,
  });
  factory Domain.fromJson(Map<String, dynamic> j) => Domain(
    id: '${j['id']}',
    title: L.from(j['title']),
    youngTitle: j['title_young'] == null ? null : L.from(j['title_young']),
    tagline: L.from(j['tagline']),
    unesco: [for (final u in (j['unesco'] as List? ?? [])) (u as num).toInt()],
    tracks: _tracks(j['tracks']),
    sensitive: j['sensitive'] == true,
  );
  int get number => int.tryParse(id.substring(1)) ?? 0;

  /// The title a learner on [track] sees.
  L titleFor(Track track) =>
      (track == Track.a || track == Track.b) && youngTitle != null
      ? youngTitle!
      : title;
}

@immutable
class RefEntry {
  final String id;
  final String title;
  final String publisher;
  final String category;
  final String url;

  /// Date the URL was last checked by the build pipeline (not a content review).
  final String checked;

  /// Whether the URL resolved from the build machine on [checked].
  final bool reachable;
  const RefEntry(
    this.id,
    this.title,
    this.publisher,
    this.category,
    this.url, {
    this.checked = '',
    this.reachable = true,
  });
  factory RefEntry.fromJson(Map<String, dynamic> j) => RefEntry(
    '${j['id']}',
    '${j['title']}',
    '${j['publisher']}',
    '${j['category']}',
    '${j['url']}',
    checked: '${j['checked'] ?? ''}',
    reachable: j['reachable'] != false,
  );
}

enum QuizType { mcq, tf, scenario }

@immutable
class QuizQ with Tracked, Topical {
  final String id;
  final String domain;
  final QuizType type;
  final L q;
  final List<L> options;
  final int answer;
  final L explain;
  @override
  final List<Track> tracks;
  @override
  final List<Audience> audience;
  @override
  final List<BodyTopic> body;
  const QuizQ({
    required this.id,
    required this.domain,
    required this.type,
    required this.q,
    required this.options,
    required this.answer,
    required this.explain,
    required this.tracks,
    this.audience = const [Audience.everyone],
    this.body = const [],
  });

  /// Quiz questions inside a lesson inherit the lesson's tracks and topic tags.
  factory QuizQ.fromJson(
    Map<String, dynamic> j, {
    String? domain,
    List<Track>? tracks,
    List<Audience>? audience,
    List<BodyTopic>? body,
  }) => QuizQ(
    id: '${j['id']}',
    domain: domain ?? '${j['domain']}',
    type: QuizType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => QuizType.mcq,
    ),
    q: L.from(j['q']),
    options: _ls(j['options']),
    answer: (j['answer'] as num?)?.toInt() ?? -1,
    explain: L.from(j['explain']),
    tracks: tracks ?? _tracks(j['tracks']),
    audience: audience ?? _audience(j['audience']),
    body: body ?? _body(j['body']),
  );
  bool get isValid =>
      options.length >= 2 && answer >= 0 && answer < options.length;
  bool isCorrect(int pick) => pick == answer;
}

@immutable
class LessonSection {
  final L h;
  final L body;
  const LessonSection(this.h, this.body);
}

@immutable
class Lesson with Tracked, Topical {
  final String id;
  final String domain;
  @override
  final List<Track> tracks;
  @override
  final List<Audience> audience;
  @override
  final List<BodyTopic> body;

  /// Names of the laws a lesson explains (shown in its legal-information box).
  final List<L> laws;
  final int difficulty;
  final int minutes;
  final List<int> unesco;
  final L title;
  final L subtitle;
  final L hook;
  final List<L> objectives;
  final List<String> prereqs;
  final List<LessonSection> sections;
  final L mythClaim;
  final L mythFact;
  final List<L> takeaways;
  final L activity;
  final String? interactive;
  final List<QuizQ> quiz;
  final List<String> refs;
  final L? warning;
  final bool sensitive;
  final String review;
  final String revised;

  const Lesson({
    required this.id,
    required this.domain,
    required this.tracks,
    this.audience = const [Audience.everyone],
    this.body = const [],
    this.laws = const [],
    required this.difficulty,
    required this.minutes,
    required this.unesco,
    required this.title,
    required this.subtitle,
    required this.hook,
    required this.objectives,
    required this.prereqs,
    required this.sections,
    required this.mythClaim,
    required this.mythFact,
    required this.takeaways,
    required this.activity,
    required this.interactive,
    required this.quiz,
    required this.refs,
    required this.warning,
    required this.sensitive,
    required this.review,
    required this.revised,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) {
    final tracks = _tracks(j['tracks']);
    final domain = '${j['domain']}';
    final myth = (j['myth'] as Map?)?.cast<String, dynamic>() ?? const {};
    final audience = _audience(j['audience']);
    final body = _body(j['body']);
    return Lesson(
      id: '${j['id']}',
      domain: domain,
      tracks: tracks,
      audience: audience,
      body: body,
      laws: _ls(j['laws']),
      difficulty: (j['difficulty'] as num?)?.toInt() ?? 1,
      minutes: (j['minutes'] as num?)?.toInt() ?? 5,
      unesco: [
        for (final u in (j['unesco'] as List? ?? [])) (u as num).toInt(),
      ],
      title: L.from(j['title']),
      subtitle: L.from(j['subtitle']),
      hook: L.from(j['hook']),
      objectives: _ls(j['objectives']),
      prereqs: _strs(j['prereqs']),
      sections: [
        for (final s in _maps(j['sections']))
          LessonSection(L.from(s['h']), L.from(s['body'])),
      ],
      mythClaim: L.from(myth['claim']),
      mythFact: L.from(myth['fact']),
      takeaways: _ls(j['takeaways']),
      activity: L.from(j['activity']),
      interactive: j['interactive'] as String?,
      quiz: [
        for (final q in _maps(j['quiz']))
          QuizQ.fromJson(
            q,
            domain: domain,
            tracks: tracks,
            audience: audience,
            body: body,
          ),
      ],
      refs: _strs(j['refs']),
      warning: j['warning'] == null ? null : L.from(j['warning']),
      sensitive: j['sensitive'] == true,
      review: '${j['review'] ?? 'pending_expert_review'}',
      revised: '${j['revised'] ?? ''}',
    );
  }
}

@immutable
class Faq with Tracked, Topical {
  final String id;
  final String domain;
  @override
  final List<Track> tracks;
  @override
  final List<Audience> audience;
  @override
  final List<BodyTopic> body;
  final L q;
  final L a;
  final List<String> keywords;
  final List<String> refs;
  final bool urgent;
  final String? lesson;
  const Faq({
    required this.id,
    required this.domain,
    required this.tracks,
    this.audience = const [Audience.everyone],
    this.body = const [],
    required this.q,
    required this.a,
    required this.keywords,
    required this.refs,
    required this.urgent,
    required this.lesson,
  });
  factory Faq.fromJson(Map<String, dynamic> j) => Faq(
    id: '${j['id']}',
    domain: '${j['domain']}',
    tracks: _tracks(j['tracks']),
    q: L.from(j['q']),
    a: L.from(j['a']),
    keywords: _strs(j['keywords']),
    refs: _strs(j['refs']),
    urgent: j['urgent'] == true,
    lesson: j['lesson'] as String?,
    audience: _audience(j['audience']),
    body: _body(j['body']),
  );
}

enum Verdict { myth, fact, partly }

@immutable
class MythCard with Tracked, Topical {
  final String id;
  final String domain;
  @override
  final List<Track> tracks;
  @override
  final List<Audience> audience;
  @override
  final List<BodyTopic> body;
  final L claim;
  final Verdict verdict;
  final L fact;
  final L why;
  final List<String> refs;
  final String? lesson;
  const MythCard({
    required this.id,
    required this.domain,
    required this.tracks,
    this.audience = const [Audience.everyone],
    this.body = const [],
    required this.claim,
    required this.verdict,
    required this.fact,
    required this.why,
    required this.refs,
    required this.lesson,
  });
  factory MythCard.fromJson(Map<String, dynamic> j) => MythCard(
    id: '${j['id']}',
    domain: '${j['domain']}',
    tracks: _tracks(j['tracks']),
    claim: L.from(j['claim']),
    verdict: Verdict.values.firstWhere(
      (v) => v.name == j['verdict'],
      orElse: () => Verdict.myth,
    ),
    fact: L.from(j['fact']),
    why: L.from(j['why']),
    refs: _strs(j['refs']),
    lesson: j['lesson'] as String?,
    audience: _audience(j['audience']),
    body: _body(j['body']),
  );
}

@immutable
class GlossaryTerm {
  final L term;
  final L def;
  const GlossaryTerm(this.term, this.def);
}

@immutable
class GlossarySet with Tracked {
  final String id;
  final String domain;
  @override
  final List<Track> tracks;
  final L title;
  final List<GlossaryTerm> terms;
  const GlossarySet(this.id, this.domain, this.tracks, this.title, this.terms);
  factory GlossarySet.fromJson(Map<String, dynamic> j) => GlossarySet(
    '${j['id']}',
    '${j['domain']}',
    _tracks(j['tracks']),
    L.from(j['title']),
    [
      for (final t in _maps(j['terms']))
        GlossaryTerm(L.from(t['term']), L.from(t['def'])),
    ],
  );
}

enum Tone { good, okay, risky }

@immutable
class ScenarioChoice {
  final L label;
  final Tone tone;
  final L feedback;
  final String? next;
  const ScenarioChoice(this.label, this.tone, this.feedback, this.next);
}

@immutable
class ScenarioNode {
  final L text;
  final List<ScenarioChoice> choices;
  const ScenarioNode(this.text, this.choices);
}

@immutable
class Scenario with Tracked {
  final String id;
  final String domain;
  final String module;
  @override
  final List<Track> tracks;
  final L title;
  final L intro;
  final bool sensitive;
  final String start;
  final Map<String, ScenarioNode> nodes;
  final L debrief;
  final List<String> refs;
  const Scenario({
    required this.id,
    required this.domain,
    required this.module,
    required this.tracks,
    required this.title,
    required this.intro,
    required this.sensitive,
    required this.start,
    required this.nodes,
    required this.debrief,
    required this.refs,
  });
  factory Scenario.fromJson(Map<String, dynamic> j) {
    final raw = (j['nodes'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Scenario(
      id: '${j['id']}',
      domain: '${j['domain']}',
      module: '${j['module']}',
      tracks: _tracks(j['tracks']),
      title: L.from(j['title']),
      intro: L.from(j['intro']),
      sensitive: j['sensitive'] == true,
      start: '${j['start']}',
      nodes: {
        for (final e in raw.entries)
          e.key: ScenarioNode(L.from((e.value as Map)['text']), [
            for (final c in _maps((e.value as Map)['choices']))
              ScenarioChoice(
                L.from(c['label']),
                Tone.values.firstWhere(
                  (t) => t.name == c['tone'],
                  orElse: () => Tone.okay,
                ),
                L.from(c['feedback']),
                c['next'] as String?,
              ),
          ]),
      },
      debrief: L.from(j['debrief']),
      refs: _strs(j['refs']),
    );
  }
}

// ───────────────────────── Lab data ─────────────────────────

@immutable
class BodyPart with Tracked {
  final String id;
  final String diagram;
  @override
  final List<Track> tracks;
  final L name;
  final L what;
  final L more;
  const BodyPart(
    this.id,
    this.diagram,
    this.tracks,
    this.name,
    this.what,
    this.more,
  );
  factory BodyPart.fromJson(Map<String, dynamic> j) => BodyPart(
    '${j['id']}',
    '${j['diagram']}',
    _tracks(j['tracks']),
    L.from(j['name']),
    L.from(j['what']),
    L.from(j['more']),
  );
}

@immutable
class PubertyChange {
  final String id;
  final String group; // f | m | all
  final double from;
  final double to;
  final L name;
  final L desc;
  const PubertyChange(
    this.id,
    this.group,
    this.from,
    this.to,
    this.name,
    this.desc,
  );
  factory PubertyChange.fromJson(Map<String, dynamic> j) => PubertyChange(
    '${j['id']}',
    '${j['group']}',
    (j['from'] as num?)?.toDouble() ?? 8,
    (j['to'] as num?)?.toDouble() ?? 16,
    L.from(j['name']),
    L.from(j['desc']),
  );
}

@immutable
class CyclePhase {
  final String id;
  final L name;
  final L days;
  final L desc;
  final L hormones;
  final L feel;
  const CyclePhase(
    this.id,
    this.name,
    this.days,
    this.desc,
    this.hormones,
    this.feel,
  );
  factory CyclePhase.fromJson(Map<String, dynamic> j) => CyclePhase(
    '${j['id']}',
    L.from(j['name']),
    L.from(j['days']),
    L.from(j['desc']),
    L.from(j['hormones']),
    L.from(j['feel']),
  );
}

@immutable
class Method {
  final String id;
  final L name;
  final L how;
  final double? typical;
  final double? perfect;
  final bool sti;
  final L lasts;
  final L access;
  final L note;
  const Method({
    required this.id,
    required this.name,
    required this.how,
    required this.typical,
    required this.perfect,
    required this.sti,
    required this.lasts,
    required this.access,
    required this.note,
  });
  factory Method.fromJson(Map<String, dynamic> j) => Method(
    id: '${j['id']}',
    name: L.from(j['name']),
    how: L.from(j['how']),
    typical: (j['typical'] as num?)?.toDouble(),
    perfect: (j['perfect'] as num?)?.toDouble(),
    sti: j['sti'] == true,
    lasts: L.from(j['lasts']),
    access: L.from(j['access']),
    note: L.from(j['note']),
  );
}

@immutable
class PreventionCard with Tracked {
  final String id;
  final String group;
  @override
  final List<Track> tracks;
  final L title;
  final L body;
  const PreventionCard(this.id, this.group, this.tracks, this.title, this.body);
  factory PreventionCard.fromJson(Map<String, dynamic> j) => PreventionCard(
    '${j['id']}',
    '${j['group']}',
    _tracks(j['tracks']),
    L.from(j['title']),
    L.from(j['body']),
  );
}

@immutable
class StiInfo {
  final String id;
  final L name;
  final L type;
  final L clue;
  final L prevention;
  final L testing;
  final L myth;
  const StiInfo(
    this.id,
    this.name,
    this.type,
    this.clue,
    this.prevention,
    this.testing,
    this.myth,
  );
  factory StiInfo.fromJson(Map<String, dynamic> j) => StiInfo(
    '${j['id']}',
    L.from(j['name']),
    L.from(j['type']),
    L.from(j['clue']),
    L.from(j['prevention']),
    L.from(j['testing']),
    L.from(j['myth']),
  );
}

// ───────────────────────── Social / support data ─────────────────────────

@immutable
class DailyFact with Tracked {
  final String id;
  @override
  final List<Track> tracks;
  final L text;
  final String ref;
  const DailyFact(this.id, this.tracks, this.text, this.ref);
  factory DailyFact.fromJson(Map<String, dynamic> j) => DailyFact(
    '${j['id']}',
    _tracks(j['tracks']),
    L.from(j['text']),
    '${j['ref'] ?? ''}',
  );
}

@immutable
class Signal with Tracked {
  final String id;
  @override
  final List<Track> tracks;
  final L text;
  final String category; // healthy | concerning | harmful
  final L note;
  const Signal(this.id, this.tracks, this.text, this.category, this.note);
  factory Signal.fromJson(Map<String, dynamic> j) => Signal(
    '${j['id']}',
    _tracks(j['tracks']),
    L.from(j['text']),
    '${j['category']}',
    L.from(j['note']),
  );
}

@immutable
class DigitalItem with Tracked {
  final String id;
  @override
  final List<Track> tracks;
  final L from;
  final L message;
  final bool safe;
  final L action;
  final L why;
  const DigitalItem(
    this.id,
    this.tracks,
    this.from,
    this.message,
    this.safe,
    this.action,
    this.why,
  );
  factory DigitalItem.fromJson(Map<String, dynamic> j) => DigitalItem(
    '${j['id']}',
    _tracks(j['tracks']),
    L.from(j['from']),
    L.from(j['message']),
    j['safe'] == true,
    L.from(j['action']),
    L.from(j['why']),
  );
}

@immutable
class SupportItem with Tracked {
  final String id;
  @override
  final List<Track> tracks;
  final String kind;
  final L title;
  final L desc;
  final L examples;
  const SupportItem(
    this.id,
    this.tracks,
    this.kind,
    this.title,
    this.desc,
    this.examples,
  );
  factory SupportItem.fromJson(Map<String, dynamic> j) => SupportItem(
    '${j['id']}',
    _tracks(j['tracks']),
    '${j['kind']}',
    L.from(j['title']),
    L.from(j['desc']),
    L.from(j['examples']),
  );
}

@immutable
class GuideSection {
  final String id;
  final L title;
  final List<L> points;
  const GuideSection(this.id, this.title, this.points);
  factory GuideSection.fromJson(Map<String, dynamic> j) =>
      GuideSection('${j['id']}', L.from(j['title']), _ls(j['points']));
}

@immutable
class TeacherNote {
  final String domain;
  final L notes;
  final List<L> prompts;
  final L caution;
  const TeacherNote(this.domain, this.notes, this.prompts, this.caution);
  factory TeacherNote.fromJson(Map<String, dynamic> j) => TeacherNote(
    '${j['domain']}',
    L.from(j['notes']),
    _ls(j['prompts']),
    L.from(j['caution']),
  );
}

@immutable
class SafetyGuide with Tracked {
  final String id;
  @override
  final List<Track> tracks;
  final L title;
  final List<L> steps;
  const SafetyGuide(this.id, this.tracks, this.title, this.steps);
  factory SafetyGuide.fromJson(Map<String, dynamic> j) => SafetyGuide(
    '${j['id']}',
    _tracks(j['tracks']),
    L.from(j['title']),
    _ls(j['steps']),
  );
}

// ───────────────────────── Visual explainers and images ─────────────────────────

@immutable
class VisualItem {
  final String icon;
  final L label;
  final L text;
  const VisualItem(this.icon, this.label, this.text);
}

@immutable
class VisualSide {
  final L title;
  final String tone; // good | bad | neutral
  final String icon;
  final List<L> points;
  const VisualSide(this.title, this.tone, this.icon, this.points);
  factory VisualSide.fromJson(Map<String, dynamic> j) => VisualSide(
    L.from(j['title']),
    '${j['tone'] ?? 'neutral'}',
    '${j['icon'] ?? 'info'}',
    _ls(j['points']),
  );
}

/// An "at a glance" infographic for one lesson: ordered steps, a grid of key
/// facts, or a two-sided comparison. It only restates facts from the lesson.
@immutable
class LessonVisual {
  final String lesson;
  final String type; // steps | grid | compare
  final L title;
  final List<VisualItem> items;
  final VisualSide? left;
  final VisualSide? right;
  const LessonVisual({
    required this.lesson,
    required this.type,
    required this.title,
    this.items = const [],
    this.left,
    this.right,
  });
  factory LessonVisual.fromJson(Map<String, dynamic> j) => LessonVisual(
    lesson: '${j['lesson']}',
    type: '${j['type']}',
    title: L.from(j['title']),
    items: [
      for (final i in _maps(j['items']))
        VisualItem(
          '${i['icon'] ?? 'info'}',
          L.from(i['label']),
          L.from(i['text']),
        ),
    ],
    left: j['left'] is Map
        ? VisualSide.fromJson((j['left'] as Map).cast<String, dynamic>())
        : null,
    right: j['right'] is Map
        ? VisualSide.fromJson((j['right'] as Map).cast<String, dynamic>())
        : null,
  );
  bool get isValid => switch (type) {
    'compare' => left != null && right != null,
    'steps' || 'grid' => items.length >= 3,
    _ => false,
  };
}

/// A bundled picture with a trilingual caption and alt text.
@immutable
class ContentImage with Tracked {
  final String id;
  final String file; // path under assets/images/
  final L caption;
  final L alt;
  @override
  final List<Track> tracks;
  final List<String> lessons;
  final List<String> domains;
  final List<String> labs;
  final List<String> screens;

  /// True for pictures made with an AI image generator (labelled in the app).
  final bool generated;
  const ContentImage({
    required this.id,
    required this.file,
    required this.caption,
    required this.alt,
    required this.tracks,
    this.lessons = const [],
    this.domains = const [],
    this.labs = const [],
    this.screens = const [],
    this.generated = true,
  });
  factory ContentImage.fromJson(Map<String, dynamic> j) => ContentImage(
    id: '${j['id']}',
    file: '${j['file']}',
    caption: L.from(j['caption']),
    alt: L.from(j['alt']),
    tracks: _tracks(j['tracks']),
    lessons: _strs(j['lessons']),
    domains: _strs(j['domains']),
    labs: _strs(j['labs']),
    screens: _strs(j['screens']),
    generated: j['generated'] != false,
  );
  String get asset => 'assets/images/$file';
}

/// A verified support line shown in the Safety Center.
@immutable
class Helpline {
  final String id;
  final String number;
  final String? url;
  final String ref;
  final bool forKids;
  const Helpline(
    this.id,
    this.number,
    this.ref, {
    this.url,
    this.forKids = false,
  });

  static const all = <Helpline>[
    Helpline('emergency', '112', 'mha-erss', forKids: true),
    Helpline('child', '1098', 'wcd-childline', forKids: true),
    Helpline('women', '181', 'wcd-mission-shakti'),
    Helpline(
      'cyber',
      '1930',
      'cybercrime-portal',
      url: 'https://cybercrime.gov.in',
    ),
    Helpline('mind', '14416', 'tele-manas', forKids: true),
    Helpline('hiv', '1097', 'naco'),
  ];
}

List<Map<String, dynamic>> jsonMaps(dynamic j) => _maps(j);
List<L> jsonLs(dynamic j) => _ls(j);

/// One newsprint poster, stored as `assets/images/posters/{id}_{lang}.webp`.
@immutable
class Poster {
  final String id;
  final String type;
  final L kicker;
  final L title;
  final String source;
  const Poster(this.id, this.type, this.kicker, this.title, this.source);

  factory Poster.fromJson(Map<String, dynamic> j) => Poster(
    '${j['id']}',
    '${j['type']}',
    L.from(j['kicker']),
    L.from(j['title']),
    '${j['source'] ?? ''}',
  );

  String asset(Lang lang) => 'assets/images/posters/${id}_${lang.name}.webp';
}
