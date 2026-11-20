import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/l10n.dart';
import 'models.dart';

const kContentRoot = 'assets/content';
const kDomainIds = [
  'd01', 'd02', 'd03', 'd04', 'd05', 'd06', 'd07', 'd08', 'd09', //
  'd10', 'd11', 'd12', 'd13', 'd14', 'd15', 'd16', 'd17', 'd18',
];
const kScenarioModules = [
  'consent',
  'relationship',
  'digital',
  'communication',
];

/// Topics that stay one tap away whatever topic filter is active: consent,
/// relationships, digital safety, personal safety and communication.
const kEssentialDomains = ['d05', 'd06', 'd13', 'd14', 'd18'];

/// UNESCO ITGSE key concepts (1-8). Titles are localized in strings.dart.
const kUnescoConcepts = [1, 2, 3, 4, 5, 6, 7, 8];

/// Reads a content file by its path relative to `assets/content/`.
/// Returns null when the file does not exist.
typedef ContentReader = Future<String?> Function(String relativePath);

/// The whole offline curriculum, parsed into immutable typed models.
class ContentRepository {
  final List<Domain> domains;
  final Map<String, RefEntry> refs;
  final List<Lesson> lessons;
  final List<Faq> faqs;
  final List<MythCard> myths;
  final List<QuizQ> quizBank;
  final List<GlossarySet> glossary;
  final List<Scenario> scenarios;
  final List<BodyPart> bodyParts;
  final List<PubertyChange> pubertyChanges;
  final List<L> pubertyNotes;
  final List<CyclePhase> cyclePhases;
  final List<L> cycleNotes;
  final List<Method> methods;
  final List<PreventionCard> preventionCards;
  final List<StiInfo> stiMatch;
  final List<DailyFact> dailyFacts;
  final List<Signal> signals;
  final List<DigitalItem> digitalChallenge;
  final List<SupportItem> supportCircle;
  final List<GuideSection> parentGuide;
  final Map<String, TeacherNote> teacherNotes;
  final List<L> groundRules;
  final List<L> safeguarding;
  final L questionBox;
  final List<SafetyGuide> safetyGuidance;
  final List<Poster> posters;

  /// "At a glance" infographic per lesson id.
  final Map<String, LessonVisual> visuals;
  final List<ContentImage> images;

  /// Date (yyyy-mm-dd) legal content was last checked against official sources
  /// by the automated web check, or null if it never was. Not a lawyer's review.
  final String? legalChecked;

  /// Files that were missing or unreadable at load time.
  final List<String> loadIssues;

  late final Map<String, Lesson> _lessonById = {
    for (final l in lessons) l.id: l,
  };
  late final Map<String, Domain> _domainById = {
    for (final d in domains) d.id: d,
  };

  ContentRepository({
    required this.domains,
    required this.refs,
    required this.lessons,
    required this.faqs,
    required this.myths,
    required this.quizBank,
    required this.glossary,
    required this.scenarios,
    this.bodyParts = const [],
    this.pubertyChanges = const [],
    this.pubertyNotes = const [],
    this.cyclePhases = const [],
    this.cycleNotes = const [],
    this.methods = const [],
    this.preventionCards = const [],
    this.stiMatch = const [],
    this.dailyFacts = const [],
    this.signals = const [],
    this.digitalChallenge = const [],
    this.supportCircle = const [],
    this.parentGuide = const [],
    this.teacherNotes = const {},
    this.groundRules = const [],
    this.safeguarding = const [],
    this.questionBox = L.empty,
    this.safetyGuidance = const [],
    this.posters = const [],
    this.visuals = const {},
    this.images = const [],
    this.legalChecked,
    this.loadIssues = const [],
  });

  static Future<ContentRepository> fromBundle(AssetBundle bundle) =>
      load((p) async {
        try {
          return await bundle.loadString('$kContentRoot/$p');
        } catch (_) {
          return null;
        }
      });

  static Future<ContentRepository> load(ContentReader read) async {
    final issues = <String>[];
    Future<dynamic> j(String path, {bool optional = false}) async {
      final s = await read(path);
      if (s == null) {
        if (!optional) issues.add(path);
        return null;
      }
      try {
        return jsonDecode(s);
      } catch (_) {
        issues.add('$path (invalid JSON)');
        return null;
      }
    }

    Future<List<T>> perDomain<T>(
      String dir,
      T Function(Map<String, dynamic>) parse, {
      bool optional = false,
    }) async {
      final out = <T>[];
      for (final d in kDomainIds) {
        for (final m in jsonMaps(await j('$dir/$d.json', optional: optional))) {
          try {
            out.add(parse(m));
          } catch (_) {
            issues.add('$dir/$d.json (bad item ${m['id']})');
          }
        }
      }
      return out;
    }

    final labs =
        (await j('extras/labs.json') as Map?)?.cast<String, dynamic>() ??
        const {};
    final social =
        (await j('extras/social.json') as Map?)?.cast<String, dynamic>() ??
        const {};
    final tg =
        (social['teacher_general'] as Map?)?.cast<String, dynamic>() ??
        const {};
    final meta =
        (await j('extras/meta.json', optional: true) as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    final visuals = await perDomain(
      'visuals',
      LessonVisual.fromJson,
      optional: true,
    );

    return ContentRepository(
      domains: [
        for (final m in jsonMaps(await j('domains.json'))) Domain.fromJson(m),
      ],
      refs: {
        for (final m in jsonMaps(await j('references.json')))
          '${m['id']}': RefEntry.fromJson(m),
      },
      lessons: await perDomain('lessons', Lesson.fromJson),
      faqs: await perDomain('faqs', Faq.fromJson),
      myths: await perDomain('myths', MythCard.fromJson),
      quizBank: await perDomain('quiz', QuizQ.fromJson),
      glossary: await perDomain('glossary', GlossarySet.fromJson),
      scenarios: await perDomain(
        'scenarios',
        Scenario.fromJson,
        optional: true,
      ),
      bodyParts: [
        for (final m in jsonMaps(labs['body_parts'])) BodyPart.fromJson(m),
      ],
      pubertyChanges: [
        for (final m in jsonMaps(labs['puberty_changes']))
          PubertyChange.fromJson(m),
      ],
      pubertyNotes: jsonLs(labs['puberty_notes']),
      cyclePhases: [
        for (final m in jsonMaps(labs['cycle_phases'])) CyclePhase.fromJson(m),
      ],
      cycleNotes: jsonLs(labs['cycle_notes']),
      methods: [for (final m in jsonMaps(labs['methods'])) Method.fromJson(m)],
      preventionCards: [
        for (final m in jsonMaps(labs['prevention_cards']))
          PreventionCard.fromJson(m),
      ],
      stiMatch: [
        for (final m in jsonMaps(labs['sti_match'])) StiInfo.fromJson(m),
      ],
      dailyFacts: [
        for (final m in jsonMaps(social['daily_facts'])) DailyFact.fromJson(m),
      ],
      signals: [
        for (final m in jsonMaps(social['signals'])) Signal.fromJson(m),
      ],
      digitalChallenge: [
        for (final m in jsonMaps(social['digital_challenge']))
          DigitalItem.fromJson(m),
      ],
      supportCircle: [
        for (final m in jsonMaps(social['support_circle']))
          SupportItem.fromJson(m),
      ],
      parentGuide: [
        for (final m in jsonMaps(social['parent_guide']))
          GuideSection.fromJson(m),
      ],
      teacherNotes: {
        for (final m in jsonMaps(social['teacher_notes']))
          '${m['domain']}': TeacherNote.fromJson(m),
      },
      groundRules: jsonLs(tg['ground_rules']),
      safeguarding: jsonLs(tg['safeguarding']),
      questionBox: L.from(tg['question_box']),
      safetyGuidance: [
        for (final m in jsonMaps(social['safety_guidance']))
          SafetyGuide.fromJson(m),
      ],
      posters: [
        for (final m in jsonMaps(
          await j('extras/posters.json', optional: true),
        ))
          Poster.fromJson(m),
      ],
      visuals: {
        for (final v in visuals)
          if (v.isValid) v.lesson: v,
      },
      images: [
        for (final m in jsonMaps(await j('extras/images.json', optional: true)))
          ContentImage.fromJson(m),
      ],
      legalChecked: meta['legal_checked'] as String?,
      loadIssues: issues,
    );
  }

  // ───────────── lookups ─────────────

  Lesson? lesson(String id) => _lessonById[id];
  Domain? domain(String id) => _domainById[id];
  RefEntry? ref(String id) => refs[id];

  // ───────────── age-track eligibility (single source of truth) ─────────────

  /// A lesson can be opened on [track] only if it lists that track.
  bool canOpenLesson(String id, Track track) =>
      lesson(id)?.visibleTo(track) ?? false;

  /// Domains that have at least one lesson for [track], in curriculum order.
  List<Domain> domainsFor(Track track) => [
    for (final d in domains)
      if (d.visibleTo(track) &&
          lessons.any((l) => l.domain == d.id && l.visibleTo(track)))
        d,
  ];

  // The optional [filter] ("Topics I want to explore") only ever narrows what
  // the age track already allows. It can never add an item from another track.

  List<Lesson> lessonsFor(
    Track track, {
    String? domain,
    TopicFilter filter = TopicFilter.all,
  }) => [
    for (final l in lessons)
      if (l.visibleTo(track) &&
          (domain == null || l.domain == domain) &&
          filter.matches(l))
        l,
  ];

  List<Faq> faqsFor(
    Track track, {
    String? domain,
    TopicFilter filter = TopicFilter.all,
  }) => [
    for (final f in faqs)
      if (f.visibleTo(track) &&
          (domain == null || f.domain == domain) &&
          filter.matches(f))
        f,
  ];

  List<MythCard> mythsFor(
    Track track, {
    String? domain,
    TopicFilter filter = TopicFilter.all,
  }) => [
    for (final m in myths)
      if (m.visibleTo(track) &&
          (domain == null || m.domain == domain) &&
          filter.matches(m))
        m,
  ];

  /// Lesson quiz questions plus quiz-bank questions visible to [track].
  List<QuizQ> quizFor(
    Track track, {
    String? domain,
    Set<String>? lessonIds,
    TopicFilter filter = TopicFilter.all,
  }) => [
    for (final l in lessonsFor(track, domain: domain, filter: filter))
      if (lessonIds == null || lessonIds.contains(l.id))
        ...l.quiz.where((q) => q.isValid),
    if (lessonIds == null)
      for (final q in quizBank)
        if (q.isValid &&
            q.visibleTo(track) &&
            (domain == null || q.domain == domain) &&
            filter.matches(q))
          q,
  ];

  /// Consent, relationships, safety and communication topics for [track]:
  /// shown alongside any filtered result so they stay discoverable for everyone.
  List<Domain> essentialDomainsFor(Track track) => [
    for (final d in domainsFor(track))
      if (kEssentialDomains.contains(d.id)) d,
  ];

  LessonVisual? visualFor(String lessonId) => visuals[lessonId];

  /// The picture for a lesson: one assigned to that lesson, else one assigned
  /// to its domain. Only pictures cleared for [track] are ever returned.
  ContentImage? imageForLesson(Lesson l, Track track) {
    final ok = [
      for (final i in images)
        if (i.visibleTo(track)) i,
    ];
    for (final i in ok) {
      if (i.lessons.contains(l.id)) return i;
    }
    for (final i in ok) {
      if (i.domains.contains(l.domain)) return i;
    }
    return null;
  }

  ContentImage? imageFor(
    Track track, {
    String? domain,
    String? lab,
    String? screen,
  }) {
    for (final i in images) {
      if (!i.visibleTo(track)) continue;
      if (domain != null && i.domains.contains(domain)) return i;
      if (lab != null && i.labs.contains(lab)) return i;
      if (screen != null && i.screens.contains(screen)) return i;
    }
    return null;
  }

  List<GlossarySet> glossaryFor(Track track) => [
    for (final g in glossary)
      if (g.visibleTo(track)) g,
  ];

  List<Scenario> scenariosFor(Track track, {String? module}) => [
    for (final s in scenarios)
      if (s.visibleTo(track) && (module == null || s.module == module)) s,
  ];

  List<BodyPart> bodyPartsFor(Track track, String diagram) => [
    for (final b in bodyParts)
      if (b.diagram == diagram && b.visibleTo(track)) b,
  ];

  /// Body Lab diagrams available to a track, simplest first.
  List<String> diagramsFor(Track track) => [
    for (final d in const ['kid', 'internal_f', 'internal_m', 'external_f'])
      if (bodyParts.any((b) => b.diagram == d && b.visibleTo(track))) d,
  ];

  List<T> visible<T extends Tracked>(List<T> items, Track track) => [
    for (final i in items)
      if (i.visibleTo(track)) i,
  ];

  /// Labs available on a track. Keys match `Lesson.interactive`.
  List<String> labsFor(Track track) => [
    if (diagramsFor(track).isNotEmpty) 'body_lab',
    if (track != Track.a && pubertyChanges.isNotEmpty) 'puberty_lab',
    if (track != Track.a && cyclePhases.isNotEmpty) 'period_lab',
    if (mythsFor(track).isNotEmpty) 'myth_buster',
    if (scenariosFor(track, module: 'consent').isNotEmpty) 'consent_sim',
    if (scenariosFor(track, module: 'relationship').isNotEmpty ||
        visible(signals, track).isNotEmpty)
      'relationship_radar',
    if (track.index >= Track.c.index && methods.isNotEmpty) 'protection_lab',
    if (scenariosFor(track, module: 'digital').isNotEmpty ||
        visible(digitalChallenge, track).isNotEmpty)
      'digital_safety',
    if (track.index >= Track.c.index && stiMatch.length >= 4) 'sti_match',
    if (visible(supportCircle, track).isNotEmpty) 'support_circle',
    // The magazine and Data Desk (website content, bundled) are for 16+.
    if (track.index >= Track.d.index) 'magazine',
    if (track.index >= Track.d.index) 'data_desk',
    if (track.index >= Track.d.index && posters.isNotEmpty) 'poster_wall',
    if (scenariosFor(track, module: 'communication').isNotEmpty)
      'communication',
  ];

  /// The next lessons a learner should take: not completed, prerequisites met,
  /// in curriculum order (body basics first), interests first.
  List<Lesson> recommended(
    Track track,
    Set<String> completed, {
    List<String> interests = const [],
    TopicFilter filter = TopicFilter.all,
  }) {
    final open = [
      for (final l in lessonsFor(track, filter: filter))
        if (!completed.contains(l.id) &&
            l.prereqs.every(
              (p) => completed.contains(p) || !canOpenLesson(p, track),
            ))
          l,
    ];
    open.sort((a, b) {
      final ia = interests.contains(a.domain) ? 0 : 1;
      final ib = interests.contains(b.domain) ? 0 : 1;
      if (ia != ib) return ia - ib;
      return a.id.compareTo(b.id);
    });
    // Spread across domains so the path is not one topic only.
    final seen = <String>{};
    final first = <Lesson>[], rest = <Lesson>[];
    for (final l in open) {
      (seen.add(l.domain) ? first : rest).add(l);
    }
    return [...first, ...rest];
  }

  /// Fraction (0-1) of a domain's lessons completed on [track].
  double domainProgress(String domain, Track track, Set<String> completed) {
    final ls = lessonsFor(track, domain: domain);
    if (ls.isEmpty) return 0;
    return ls.where((l) => completed.contains(l.id)).length / ls.length;
  }

  DailyFact? factOfTheDay(Track track, DateTime day) {
    final pool = visible(dailyFacts, track);
    if (pool.isEmpty) return null;
    final n = day.difference(DateTime(2026)).inDays.abs();
    return pool[n % pool.length];
  }

  /// Real counts, used by the coverage report and the About screen.
  Map<String, int> get counts => {
    'domains': domains.length,
    'lessons': lessons.length,
    'faqs': faqs.length,
    'myths': myths.length,
    'quiz': quizBank.length + lessons.fold(0, (n, l) => n + l.quiz.length),
    'scenarios': scenarios.length,
    'glossarySets': glossary.length,
    'glossaryTerms': glossary.fold(0, (n, g) => n + g.terms.length),
    'references': refs.length,
    'visuals': visuals.length,
    'images': images.length,
  };
}
