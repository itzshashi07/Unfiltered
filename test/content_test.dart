import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/models.dart';
import 'package:unfiltered/features/labs/body_lab.dart';
import 'package:unfiltered/features/labs/visual_explainers.dart';
import 'package:unfiltered/ui/illustrations.dart';

import 'helpers.dart';

final _deva = RegExp(r'[ऀ-ॿ]');

void expectL(L l, String where, {bool allowEmpty = false}) {
  if (allowEmpty && l.isEmpty) return;
  expect(l.isComplete, isTrue, reason: '$where is missing a translation');
  expect(
    _deva.hasMatch(l.hg) || _deva.hasMatch(l.en),
    isFalse,
    reason: '$where: contains Devanagari (Hindi was removed)',
  );
}

void main() {
  late ContentRepository c;
  setUpAll(() async => c = await loadContent());

  group('content repository validation', () {
    test('every content file loads', () {
      expect(c.loadIssues, isEmpty);
    });

    test('meets the curriculum size targets (real counts)', () {
      final n = c.counts;
      // ignore: avoid_print
      print('CONTENT COUNTS: $n');
      expect(n['domains'], 18);
      expect(n['lessons'], greaterThanOrEqualTo(96));
      expect(n['faqs'], greaterThanOrEqualTo(200));
      expect(n['quiz'], greaterThanOrEqualTo(200));
      expect(n['myths'], greaterThanOrEqualTo(120));
      expect(n['scenarios'], greaterThanOrEqualTo(24));
      expect(n['glossarySets'], greaterThanOrEqualTo(30));
    });

    test('ids are unique across the curriculum', () {
      final ids = <String>[
        ...c.lessons.map((l) => l.id),
        ...c.lessons.expand((l) => l.quiz.map((q) => q.id)),
        ...c.faqs.map((f) => f.id),
        ...c.myths.map((m) => m.id),
        ...c.quizBank.map((q) => q.id),
        ...c.glossary.map((g) => g.id),
        ...c.scenarios.map((s) => s.id),
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('every lesson is substantive, translated and well-formed', () {
      for (final l in c.lessons) {
        expect(
          c.domain(l.domain),
          isNotNull,
          reason: '${l.id} has an unknown domain',
        );
        expect(l.tracks, isNotEmpty, reason: l.id);
        expect(
          l.tracks.every(c.domain(l.domain)!.tracks.contains),
          isTrue,
          reason: '${l.id} track not allowed in domain',
        );
        expect(l.sections.length, greaterThanOrEqualTo(3), reason: l.id);
        expect(l.takeaways.length, 3, reason: l.id);
        expect(l.objectives.length, inInclusiveRange(2, 3), reason: l.id);
        expect(l.review, 'pending_expert_review', reason: l.id);
        for (final t in [
          l.title,
          l.subtitle,
          l.hook,
          l.activity,
          l.mythClaim,
          l.mythFact,
          ...l.objectives,
          ...l.takeaways,
        ]) {
          expectL(t, l.id);
        }
        for (final s in l.sections) {
          expectL(s.h, l.id);
          expectL(s.body, l.id);
          expect(
            s.body.en.split(' ').length,
            greaterThanOrEqualTo(20),
            reason: '${l.id} has a thin section',
          );
        }
        if (l.warning != null) expectL(l.warning!, l.id);
      }
    });

    test('lesson prerequisites exist and share a track', () {
      for (final l in c.lessons) {
        for (final p in l.prereqs) {
          final pre = c.lesson(p);
          expect(pre, isNotNull, reason: '${l.id} -> missing prerequisite $p');
          expect(
            pre!.tracks.any(l.tracks.contains),
            isTrue,
            reason: '${l.id} -> $p never visible together',
          );
        }
      }
    });

    test('quiz answer keys are valid and translated', () {
      final all = [...c.quizBank, ...c.lessons.expand((l) => l.quiz)];
      for (final q in all) {
        expect(q.isValid, isTrue, reason: '${q.id} answer key out of range');
        expectL(q.q, q.id);
        expectL(q.explain, q.id);
        for (final o in q.options) {
          expectL(o, q.id);
        }
        if (q.type == QuizType.tf) expect(q.options.length, 2, reason: q.id);
      }
    });

    test('every cited source resolves to a reference entry', () {
      final cited = <String, String>{
        for (final l in c.lessons)
          for (final r in l.refs) r: l.id,
        for (final f in c.faqs)
          for (final r in f.refs) r: f.id,
        for (final m in c.myths)
          for (final r in m.refs) r: m.id,
        for (final s in c.scenarios)
          for (final r in s.refs) r: s.id,
        for (final f in c.dailyFacts) f.ref: f.id,
        for (final h in Helpline.all) h.ref: h.id,
      };
      cited.forEach(
        (ref, where) => expect(
          c.ref(ref),
          isNotNull,
          reason: '$where cites unknown source $ref',
        ),
      );
      for (final l in c.lessons) {
        expect(l.refs, isNotEmpty, reason: '${l.id} has no source');
      }
      for (final r in c.refs.values) {
        expect(r.url, startsWith('https://'), reason: r.id);
      }
    });

    test('faqs, myths, glossary and scenarios are translated and linked', () {
      for (final f in c.faqs) {
        expectL(f.q, f.id);
        expectL(f.a, f.id);
        expect(f.keywords.length, greaterThanOrEqualTo(6), reason: f.id);
        if (f.lesson != null) {
          expect(c.lesson(f.lesson!), isNotNull, reason: f.id);
        }
      }
      for (final m in c.myths) {
        expectL(m.claim, m.id);
        expectL(m.fact, m.id);
        expectL(m.why, m.id);
        expect(m.refs, isNotEmpty, reason: m.id);
      }
      for (final g in c.glossary) {
        expectL(g.title, g.id);
        for (final t in g.terms) {
          expectL(t.term, g.id);
          expectL(t.def, g.id);
        }
      }
      for (final s in c.scenarios) {
        expect(kScenarioModules, contains(s.module), reason: s.id);
        expect(s.nodes[s.start], isNotNull, reason: s.id);
        expectL(s.debrief, s.id);
        for (final n in s.nodes.values) {
          expectL(n.text, s.id);
          expect(n.choices, isNotEmpty, reason: s.id);
          for (final ch in n.choices) {
            expectL(ch.label, s.id);
            expectL(ch.feedback, s.id);
            if (ch.next != null) {
              expect(
                s.nodes[ch.next],
                isNotNull,
                reason: '${s.id} dead branch',
              );
            }
          }
        }
      }
    });

    test('lab and support data is complete and translated', () {
      expect(c.pubertyChanges.length, greaterThanOrEqualTo(10));
      expect(c.cyclePhases.length, 4);
      expect(c.methods.length, greaterThanOrEqualTo(10));
      expect(c.stiMatch.length, 8);
      expect(c.dailyFacts.length, greaterThanOrEqualTo(30));
      expect(c.signals.length, greaterThanOrEqualTo(24));
      expect(c.digitalChallenge.length, greaterThanOrEqualTo(16));
      expect(c.parentGuide.length, 7);
      expect(c.safetyGuidance.length, greaterThanOrEqualTo(7));
      expect(c.groundRules, isNotEmpty);
      expect(c.safeguarding, isNotEmpty);
      for (final d in kDomainIds) {
        expect(c.teacherNotes[d], isNotNull, reason: 'no teacher notes for $d');
      }
      for (final b in c.bodyParts) {
        expectL(b.name, b.id);
        expectL(b.what, b.id);
        expectL(b.more, b.id);
        expect(
          kHotspots[b.diagram]?[b.id],
          isNotNull,
          reason: '${b.id} has no hotspot on ${b.diagram}',
        );
      }
      for (final e in kHotspots.entries) {
        for (final id in e.value.keys) {
          expect(
            c.bodyParts.any((b) => b.id == id && b.diagram == e.key),
            isTrue,
            reason: 'hotspot $id has no text',
          );
        }
      }
      for (final m in c.methods) {
        expectL(m.name, m.id);
        expectL(m.how, m.id);
      }
      for (final t in Track.values) {
        expect(
          c.factOfTheDay(t, DateTime(2026, 11, 14)),
          isNotNull,
          reason: 'no daily fact for ${t.code}',
        );
        expect(
          c.visible(c.safetyGuidance, t),
          isNotEmpty,
          reason: 'no safety guidance for ${t.code}',
        );
        expect(
          c.visible(c.supportCircle, t),
          isNotEmpty,
          reason: 'no support circle for ${t.code}',
        );
      }
    });
  });

  group('curriculum mapping', () {
    test('all 18 domains have substantive coverage', () {
      for (final d in c.domains) {
        expect(
          c.lessons.where((l) => l.domain == d.id).length,
          greaterThanOrEqualTo(5),
          reason: d.id,
        );
        expect(
          c.faqs.where((f) => f.domain == d.id).length,
          greaterThanOrEqualTo(12),
          reason: d.id,
        );
        expect(
          c.myths.where((m) => m.domain == d.id).length,
          greaterThanOrEqualTo(7),
          reason: d.id,
        );
        expectL(d.title, d.id);
        expectL(d.tagline, d.id);
      }
    });

    test('every UNESCO key concept (1-8) is covered by lessons', () {
      for (final u in kUnescoConcepts) {
        expect(
          c.lessons.any((l) => l.unesco.contains(u)),
          isTrue,
          reason: 'concept $u',
        );
        expect(Strings.has('unesco.$u'), isTrue);
      }
      for (final l in c.lessons) {
        expect(l.unesco, isNotEmpty, reason: l.id);
        expect(l.unesco.every(kUnescoConcepts.contains), isTrue, reason: l.id);
      }
    });

    test('every track has a real curriculum', () {
      for (final t in Track.values) {
        expect(
          c.lessonsFor(t).length,
          greaterThanOrEqualTo(9),
          reason: 'track ${t.code}',
        );
        expect(c.domainsFor(t), isNotEmpty);
        expect(c.faqsFor(t), isNotEmpty);
        expect(c.mythsFor(t), isNotEmpty);
        expect(c.quizFor(t).length, greaterThanOrEqualTo(10));
      }
    });
  });

  group('lesson eligibility by age', () {
    const adultOnlyDomains = ['d07', 'd08', 'd09'];

    test('a track only ever sees items that list it', () {
      for (final t in Track.values) {
        expect(c.lessonsFor(t).every((l) => l.tracks.contains(t)), isTrue);
        expect(c.faqsFor(t).every((f) => f.tracks.contains(t)), isTrue);
        expect(c.mythsFor(t).every((m) => m.tracks.contains(t)), isTrue);
        expect(c.quizFor(t).every((q) => q.tracks.contains(t)), isTrue);
        expect(c.scenariosFor(t).every((s) => s.tracks.contains(t)), isTrue);
        expect(c.glossaryFor(t).every((g) => g.tracks.contains(t)), isTrue);
      }
    });

    test(
      'children (5-8, 9-12) never get contraception, pregnancy or STI domains',
      () {
        for (final t in [Track.a, Track.b]) {
          for (final d in adultOnlyDomains) {
            expect(
              c.lessonsFor(t, domain: d),
              isEmpty,
              reason: '${t.code} sees $d lessons',
            );
            expect(
              c.faqsFor(t, domain: d),
              isEmpty,
              reason: '${t.code} sees $d FAQs',
            );
            expect(
              c.mythsFor(t, domain: d),
              isEmpty,
              reason: '${t.code} sees $d myths',
            );
            expect(
              c.quizFor(t, domain: d),
              isEmpty,
              reason: '${t.code} sees $d quiz',
            );
          }
          expect(
            c.domainsFor(t).map((d) => d.id),
            isNot(containsAll(adultOnlyDomains)),
          );
        }
        // The youngest track is limited to the body-safety domains.
        expect(c.domainsFor(Track.a).map((d) => d.id).toSet(), {
          'd01',
          'd05',
          'd06',
          'd11',
          'd13',
          'd14',
          'd17',
          'd18',
        });
      },
    );

    test('adult-only lessons cannot be opened on minor tracks', () {
      final adultOnly = c.lessons.where(
        (l) => l.tracks.length == 1 && l.tracks.first == Track.e,
      );
      expect(adultOnly, isNotEmpty);
      for (final l in adultOnly) {
        for (final t in [Track.a, Track.b, Track.c, Track.d]) {
          expect(
            c.canOpenLesson(l.id, t),
            isFalse,
            reason: '${l.id} opens on ${t.code}',
          );
        }
        expect(c.canOpenLesson(l.id, Track.e), isTrue);
      }
      expect(c.canOpenLesson('does-not-exist', Track.e), isFalse);
    });

    test('labs and diagrams are gated by track', () {
      expect(c.diagramsFor(Track.a), ['kid']);
      expect(c.diagramsFor(Track.b), ['internal_f', 'internal_m']);
      expect(c.diagramsFor(Track.c), [
        'internal_f',
        'internal_m',
        'external_f',
      ]);
      final a = c.labsFor(Track.a);
      for (final lab in [
        'puberty_lab',
        'period_lab',
        'protection_lab',
        'sti_match',
      ]) {
        expect(a, isNot(contains(lab)), reason: 'track A sees $lab');
      }
      expect(c.labsFor(Track.b), isNot(contains('protection_lab')));
      expect(c.labsFor(Track.b), isNot(contains('sti_match')));
      expect(
        c.labsFor(Track.e),
        containsAll([
          'body_lab',
          'period_lab',
          'protection_lab',
          'sti_match',
          'myth_buster',
        ]),
      );
      expect(c.visible(c.preventionCards, Track.b), isEmpty);
      // Every lab a lesson links to exists for at least one of that lesson's tracks.
      for (final l in c.lessons.where(
        (l) => l.interactive != null && l.interactive != 'ask',
      )) {
        expect(
          l.tracks.any((t) => c.labsFor(t).contains(l.interactive)),
          isTrue,
          reason: '${l.id} -> ${l.interactive}',
        );
      }
    });

    test('recommendations respect prerequisites and track', () {
      for (final t in Track.values) {
        final recs = c.recommended(t, {});
        expect(recs, isNotEmpty);
        // Nothing is suggested before a prerequisite the learner could still take.
        expect(
          recs.every(
            (l) =>
                l.visibleTo(t) &&
                l.prereqs.every((p) => !c.canOpenLesson(p, t)),
          ),
          isTrue,
        );
        final all = c.lessonsFor(t).map((l) => l.id).toSet();
        expect(c.recommended(t, all), isEmpty);
      }
    });
  });

  group('illustrations', () {
    const scenes = {
      'family',
      'doctor',
      'phone',
      'stop',
      'circle',
      'think',
      'law',
      'couple',
      'mirror',
      'grow',
      'period',
      'media',
      'class',
      'friends',
    };
    test(
      'every lesson gets a known scene; couples only where every viewer is 16+',
      () {
        for (final l in c.lessons) {
          final s = sceneFor(l);
          expect(scenes, contains(s), reason: l.id);
          if (s == 'couple') {
            expect(
              l.tracks.every((t) => t.index >= Track.d.index),
              isTrue,
              reason: l.id,
            );
          }
        }
      },
    );
    test('every contraceptive method has its own object drawing', () {
      for (final m in c.methods.where((m) => m.id != 'none')) {
        expect(objectForMethod(m.id), isNot('question'), reason: m.id);
      }
    });
    test(
      'explainer lessons exist and the pregnancy animation is for ages 13+',
      () {
        for (final id in kFertilizationLessons) {
          expect(c.lesson(id), isNotNull, reason: id);
          expect(
            c.lesson(id)!.tracks.every((t) => t.index >= Track.c.index),
            isTrue,
            reason: id,
          );
        }
        for (final id in kPeriodProductLessons) {
          expect(c.lesson(id), isNotNull, reason: id);
        }
      },
    );
  });

  test('the Python validator agrees (tools/validate_content.py)', () async {
    final r = await Process.run('python3', ['tools/validate_content.py']);
    expect(r.exitCode, 0, reason: '${r.stdout}');
  });
}
