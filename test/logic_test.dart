import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/achievements.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/models.dart';
import 'package:unfiltered/data/search.dart';
import 'package:unfiltered/data/store.dart';
import 'package:unfiltered/features/labs/period_lab.dart';
import 'package:unfiltered/features/labs/protection_lab.dart';
import 'package:unfiltered/features/quiz/quiz_runner.dart';
import 'package:unfiltered/features/quiz/quiz_screens.dart';
import 'package:unfiltered/features/settings/legal.dart';

import 'helpers.dart';

QuizQ _q(String id, int answer, {int options = 4}) => QuizQ(
  id: id,
  domain: 'd01',
  type: QuizType.mcq,
  q: const L('q', 'प्र', 'q'),
  options: [for (var i = 0; i < options; i++) L('o$i', 'वि$i', 'o$i')],
  answer: answer,
  explain: const L('e', 'व', 'e'),
  tracks: const [Track.c],
);

Future<ProviderContainer> _container([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final store = AppStore(await SharedPreferences.getInstance());
  await store.migrate();
  final c = ProviderContainer(
    overrides: [storeProvider.overrideWithValue(store)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  late ContentRepository content;
  setUpAll(() async => content = await loadContent());

  group('quiz scoring and question evaluation', () {
    test('counts only correct answers and locks each answer', () {
      final s = QuizSession([_q('a', 1), _q('b', 0), _q('c', 3)]);
      expect(s.finished, isFalse);
      expect(s.answer(0, 1), isTrue); // correct
      expect(s.answer(0, 2), isFalse); // already answered: ignored
      expect(s.answer(1, 2), isTrue); // wrong
      expect(s.answer(2, 9), isFalse); // not an option
      expect(s.answer(2, 3), isTrue); // correct
      expect(s.finished, isTrue);
      expect(s.correct, 2);
      expect(s.percent, 67);
      s.reset();
      expect(s.answered, 0);
      expect(s.correct, 0);
    });

    test('percent rounding and empty quiz', () {
      expect(quizPercent(0, 0), 0);
      expect(quizPercent(1, 3), 33);
      expect(quizPercent(5, 5), 100);
      expect(QuizSession(const []).finished, isFalse);
    });

    test('an invalid answer key is rejected as invalid', () {
      expect(_q('x', 4).isValid, isFalse);
      expect(_q('x', -1).isValid, isFalse);
      expect(_q('x', 0, options: 1).isValid, isFalse);
      expect(_q('x', 3).isValid, isTrue);
    });

    test('quiz builder only uses questions visible to the track', () {
      for (final t in Track.values) {
        final d = content.domainsFor(t).first.id;
        final qs = buildQuiz(
          content,
          t,
          kind: 'domain',
          id: d,
          random: Random(1),
        );
        expect(qs, isNotEmpty);
        expect(qs.length, lessThanOrEqualTo(10));
        expect(qs.every((q) => q.visibleTo(t) && q.domain == d), isTrue);
        final fin = buildQuiz(
          content,
          t,
          kind: 'final',
          id: 'all',
          random: Random(2),
        );
        expect(fin.every((q) => q.visibleTo(t)), isTrue);
        expect(fin.map((q) => q.id).toSet().length, fin.length);
      }
      final adult = content.lessons.firstWhere(
        (l) => l.tracks.length == 1 && l.tracks.first == Track.e,
      );
      expect(
        buildQuiz(content, Track.b, kind: 'lesson', id: adult.id),
        isEmpty,
      );
      expect(
        buildQuiz(content, Track.e, kind: 'lesson', id: adult.id),
        isNotEmpty,
      );
    });

    test(
      'final challenge draws from completed lessons once there are enough',
      () {
        final done = content
            .lessonsFor(Track.c)
            .take(4)
            .map((l) => l.id)
            .toSet();
        final qs = buildQuiz(
          content,
          Track.c,
          kind: 'final',
          id: 'all',
          completed: done,
          random: Random(3),
        );
        final allowed = content.lessons
            .where((l) => done.contains(l.id))
            .expand((l) => l.quiz.map((q) => q.id))
            .toSet();
        expect(qs.every((q) => allowed.contains(q.id)), isTrue);
      },
    );
  });

  group('offline question search', () {
    late SearchEngine engine;
    setUpAll(
      () => engine = SearchEngine(
        faqs: content.faqs,
        myths: content.myths,
        glossary: content.glossary,
      ),
    );

    test('normalises and canonicalises English, Hinglish and Hindi', () {
      expect(
        SearchEngine.tokens('Are PERIODS painful?'),
        containsAll(['period', 'pain']),
      );
      expect(
        SearchEngine.tokens('mahina late kyun hota hai'),
        contains('period'),
      );
      expect(
        SearchEngine.tokens('माहवारी में दर्द क्यों होता है'),
        containsAll(['period', 'pain']),
      );
      expect(SearchEngine.tokens('night fall kya hai'), contains('wetdream'));
      expect(SearchEngine.tokens('kya hai yeh'), isNot(contains('kya')));
    });

    test('finds curated answers in all three languages', () {
      bool c(Faq f) => f.visibleTo(Track.c);
      bool d(Faq f) => f.visibleTo(Track.d);
      final a = engine.search('kya masturbation se kamzori aati hai', where: c);
      expect(a, isNotEmpty);
      expect(a.first.domain, anyOf('d04', 'd15'));
      expect(engine.search('are periods impure', where: c), isNotEmpty);
      expect(
        engine.search('क्या माहवारी में नहाना चाहिए', where: c),
        isNotEmpty,
      );
      final h = engine.search('how does HIV spread', where: d);
      expect(h, isNotEmpty);
      expect(h.first.domain, 'd09');
      expect(
        engine.search('emergency pill kab leni chahiye', where: d),
        isNotEmpty,
      );
    });

    test('returns nothing rather than inventing an answer', () {
      expect(engine.search('xyzzy plugh quux'), isEmpty);
      expect(engine.search(''), isEmpty);
      expect(engine.search('   ?? !!'), isEmpty);
      expect(engine.search('the is of and'), isEmpty);
      expect(engine.search('cricket world cup final score'), isEmpty);
    });

    test('results respect the age track filter', () {
      for (final q in [
        'condom',
        'pregnancy test',
        'hiv',
        'orgasm',
        'erection problem',
      ]) {
        final hits = engine.search(q, where: (f) => f.visibleTo(Track.a));
        expect(hits.every((f) => f.tracks.contains(Track.a)), isTrue);
        expect(
          hits.where((f) => ['d07', 'd08', 'd09'].contains(f.domain)),
          isEmpty,
        );
      }
      expect(
        engine.searchMyths(
          'masturbation weakness',
          where: (m) => m.visibleTo(Track.a),
        ),
        isEmpty,
      );
    });

    test('flags questions that suggest someone is unsafe', () {
      for (final q in [
        'my uncle touched me',
        'someone is blackmailing me with my photos',
        'I want to die',
        'usne zabardasti ki',
        'वह मुझे धमकी दे रहा है',
        'mujhe dhamki de raha hai',
      ]) {
        expect(SearchEngine.isUrgent(q), isTrue, reason: q);
      }
      for (final q in [
        'what is puberty',
        'periods kab aate hain',
        'how do vaccines work',
      ]) {
        expect(SearchEngine.isUrgent(q), isFalse, reason: q);
      }
    });

    test('glossary terms can be looked up', () {
      final term = content.glossary.first.terms.first;
      expect(engine.searchTerms(term.term.en), isNotEmpty);
      expect(engine.searchTerms('q'), isEmpty);
    });
  });

  group('progress persistence and privacy', () {
    test('settings and progress survive a restart', () async {
      final c1 = await _container();
      c1.read(settingsProvider.notifier)
        ..setLang(Lang.hi)
        ..setTrack(Track.d)
        ..setTheme(ThemeMode.dark)
        ..setTextScale(1.3)
        ..setInterests(['d03'])
        ..completeOnboarding();
      c1.read(progressProvider.notifier)
        ..completeLesson('d03-l01', now: DateTime(2026, 11, 14))
        ..recordQuiz('domain:d03', 4, 5)
        ..recordQuiz(
          'domain:d03',
          2,
          5,
        ) // lower score must not overwrite the best
        ..toggleBookmark('d03-l02')
        ..seeMyth('d03-m01')
        ..finishScenario('d05-s1')
        ..visitLab('period_lab')
        ..toggleSupport('sup01')
        ..addNote(
          '  remember to ask the doctor  ',
          now: DateTime(2026, 11, 14, 10),
        );

      // "Restart": a fresh store + container over the same saved preferences.
      final store = AppStore(await SharedPreferences.getInstance());
      final c2 = ProviderContainer(
        overrides: [storeProvider.overrideWithValue(store)],
      );
      addTearDown(c2.dispose);
      final s = c2.read(settingsProvider);
      final p = c2.read(progressProvider);
      expect(s.lang, Lang.hi);
      expect(s.track, Track.d);
      expect(s.theme, ThemeMode.dark);
      expect(s.textScale, 1.3);
      expect(s.onboarded, isTrue);
      expect(s.interests, ['d03']);
      expect(p.completed, {'d03-l01': '2026-11-14'});
      expect(p.quizBest['domain:d03'], 80);
      expect(p.bookmarks, {'d03-l02'});
      expect(p.mythsSeen, {'d03-m01'});
      expect(p.scenariosDone, {'d05-s1'});
      expect(p.labsVisited, {'period_lab'});
      expect(p.support, {'sup01'});
      expect(p.notes.single.text, 'remember to ask the doctor');
      expect(p.lastLesson, 'd03-l01');
    });

    test(
      'older saved data (schema v1) is migrated, corrupt data is ignored',
      () async {
        final c = await _container({
          'uf.progress': jsonEncode({
            'completed': ['d01-l01', 'd01-l02'],
          }),
        });
        expect(c.read(progressProvider).completedIds, {'d01-l01', 'd01-l02'});
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('uf.schema'), kSchemaVersion);
        expect(
          jsonDecode(prefs.getString('uf.progress')!)['completed'],
          isA<Map>(),
        );

        final bad = await _container({
          'uf.progress': '{not json',
          'uf.settings': '[]',
        });
        expect(bad.read(progressProvider).isEmpty, isTrue);
        expect(bad.read(settingsProvider).onboarded, isFalse);
      },
    );

    test('delete-all wipes every key the app wrote and nothing else', () async {
      final c = await _container({'someone.elses.key': 'keep'});
      c.read(settingsProvider.notifier).completeOnboarding();
      c.read(progressProvider.notifier)
        ..completeLesson('d01-l01')
        ..addNote('private thought');
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((k) => k.startsWith(AppStore.prefix)),
        isNotEmpty,
      );
      await c.read(storeProvider).deleteAll();
      expect(
        prefs.getKeys().where((k) => k.startsWith(AppStore.prefix)),
        isEmpty,
      );
      expect(prefs.getString('someone.elses.key'), 'keep');
      expect(c.read(storeProvider).readProgress().isEmpty, isTrue);
      expect(c.read(storeProvider).readSettings().onboarded, isFalse);
    });

    test('notes can be deleted one by one or all at once', () async {
      final c = await _container();
      final n = c.read(progressProvider.notifier)
        ..addNote('one', now: DateTime(2026, 1, 1, 1))
        ..addNote('two', now: DateTime(2026, 1, 1, 2))
        ..addNote('   ');
      expect(c.read(progressProvider).notes.map((x) => x.text), ['two', 'one']);
      n.deleteNote(c.read(progressProvider).notes.first.id);
      expect(c.read(progressProvider).notes.single.text, 'one');
      n.deleteAllNotes();
      expect(c.read(progressProvider).notes, isEmpty);
    });

    test(
      'the export never contains the educator PIN and search is never stored',
      () async {
        final c = await _container();
        c.read(settingsProvider.notifier).lock('4321', [Track.b, Track.c]);
        final out = c.read(storeProvider).exportJson();
        expect(out, isNot(contains('pinHash')));
        expect(out, isNot(contains('4321')));
        expect(jsonDecode(out)['app'], 'UNFILTERED');
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getKeys(), {'uf.schema', 'uf.settings'});
      },
    );
  });

  group('content filtering by educator lock', () {
    test(
      'the lock restricts tracks and needs the PIN to change them',
      () async {
        final c = await _container();
        final n = c.read(settingsProvider.notifier);
        expect(n.setTrack(Track.e), isTrue);
        n.lock('2468', [Track.b, Track.c]);
        var s = c.read(settingsProvider);
        expect(s.locked, isTrue);
        expect(s.selectableTracks, [Track.b, Track.c]);
        expect(
          s.track,
          Track.b,
          reason: 'moved off the now-disallowed adult track',
        );
        expect(n.setTrack(Track.c), isFalse, reason: 'no PIN');
        expect(n.setTrack(Track.c, pin: '0000'), isFalse, reason: 'wrong PIN');
        expect(
          n.setTrack(Track.e, pin: '2468'),
          isFalse,
          reason: 'track not allowed',
        );
        expect(n.setTrack(Track.c, pin: '2468'), isTrue);
        expect(n.unlock('1111'), isFalse);
        expect(n.unlock('2468'), isTrue);
        s = c.read(settingsProvider);
        expect(s.locked, isFalse);
        expect(s.selectableTracks, Track.values);
      },
    );

    test(
      'a saved track outside the allow-list is corrected on start',
      () async {
        final c = await _container({
          'uf.settings': jsonEncode(
            const AppSettings(
              track: Track.e,
              onboarded: true,
              allowedTracks: [Track.a, Track.b],
            ).toJson(),
          ),
        });
        expect(c.read(settingsProvider).track, Track.a);
      },
    );

    test('PIN hash is stable and not the PIN itself', () {
      expect(hashPin('1234'), hashPin('1234'));
      expect(hashPin('1234'), isNot(hashPin('1235')));
      expect(hashPin('1234'), isNot(contains('1234')));
    });
  });

  group('achievements', () {
    test('milestones follow real progress', () {
      const none = Progress();
      expect(kBadges.where((b) => b.earned(none, content, Track.c)), isEmpty);
      final all = {
        for (final l in content.lessonsFor(Track.c)) l.id: '2026-11-14',
      };
      final p = Progress(
        completed: all,
        quizBest: const {'final': 90},
        mythsSeen: {for (var i = 0; i < 30; i++) 'm$i'},
      );
      final earned = kBadges
          .where((b) => b.earned(p, content, Track.c))
          .map((b) => b.id);
      expect(
        earned,
        containsAll([
          'first',
          'five',
          'fifteen',
          'domain',
          'domains3',
          'myth10',
          'myth30',
          'quiz80',
          'final',
        ]),
      );
      for (final b in kBadges) {
        expect(
          Strings.has(b.titleKey) && Strings.has(b.descKey),
          isTrue,
          reason: b.id,
        );
        expect(b.value(p, content, Track.c), lessThanOrEqualTo(b.goal));
      }
    });
  });

  group('lab models', () {
    test('cycle phases cover every day for every cycle length', () {
      for (var len = 21; len <= 35; len++) {
        final phases = [for (var d = 1; d <= len; d++) cyclePhaseIndex(d, len)];
        expect(phases.first, 0);
        expect(phases.last, 3);
        expect(
          phases.where((p) => p == 2).length,
          1,
          reason: 'one modelled ovulation day',
        );
        expect(phases.indexOf(2) + 1, len - 14);
        for (var i = 1; i < phases.length; i++) {
          expect(
            phases[i],
            greaterThanOrEqualTo(phases[i - 1]),
            reason: 'phases only move forward',
          );
        }
        for (var d = 1; d <= len; d++) {
          for (var h = 0; h < 4; h++) {
            expect(
              hormoneLevel(h, d.toDouble(), len),
              inInclusiveRange(0.0, 1.3),
            );
          }
          expect(liningLevel(d.toDouble(), len), inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('method rates are displayed honestly', () {
      expect(rateLabel(0), '0');
      expect(rateLabel(0.1), '<1');
      expect(rateLabel(7), '7');
      expect(rateLabel(85), '85');
      final by = {for (final m in content.methods) m.id: m};
      expect(by['external_condom']!.sti, isTrue);
      expect(by['pill']!.sti, isFalse);
      expect(by['calendar']!.typical, greaterThan(by['pill']!.typical!));
      expect(by['emergency']!.typical, isNull);
      for (final m in content.methods.where((m) => m.typical != null)) {
        expect(m.perfect, lessThanOrEqualTo(m.typical!), reason: m.id);
      }
    });
  });

  group('localization', () {
    test('every UI string exists in English, Hindi and Hinglish', () {
      final deva = RegExp(r'[ऀ-ॿ]');
      Strings.table.forEach((k, v) {
        expect(v.length, 3, reason: k);
        expect(v.every((s) => s.trim().isNotEmpty), isTrue, reason: k);
        expect(
          deva.hasMatch(v[2]),
          isFalse,
          reason: '$k Hinglish has Devanagari',
        );
        expect(
          deva.hasMatch(v[0]),
          isFalse,
          reason: '$k English has Devanagari',
        );
      });
      expect(
        Strings.get('quiz.count', Lang.en, {'n': 2, 'total': 5}),
        '2 of 5',
      );
      expect(Strings.get('nav.home', Lang.hi), 'होम');
      expect(Strings.get('missing.key', Lang.en), 'missing.key');
    });

    test('every string key used in the code is defined', () {
      final used = <String>{};
      final call = RegExp(r"""\.t\(\s*'([a-zA-Z0-9_.\-]+)'""");
      final literal = RegExp(r"""'((?:[a-z]+)\.[a-zA-Z0-9_.\-]+)'""");
      final prefixes = Strings.table.keys
          .map((k) => k.split('.').first)
          .toSet();
      for (final f in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart') || f.path.endsWith('strings.dart')) {
          continue;
        }
        final src = f.readAsStringSync();
        used.addAll(call.allMatches(src).map((m) => m.group(1)!));
        for (final m in literal.allMatches(src)) {
          final k = m.group(1)!;
          // ternaries like t(a ? 'x.y' : 'x.z') and key constants
          if (prefixes.contains(k.split('.').first) &&
              Strings.table.keys.any((t) => t == k || t.startsWith('$k.'))) {
            used.add(k);
          }
        }
      }
      expect(used.length, greaterThan(250));
      final missing = used
          .where(
            (k) =>
                !Strings.has(k) &&
                !Strings.table.keys.any((t) => t.startsWith('$k.')),
          )
          .toList();
      expect(missing, isEmpty);
    });

    test('dynamically built keys are all defined', () {
      final keys = <String>[
        for (final t in Track.values) ...[t.nameKey, t.descKey],
        for (final d in ['kid', 'internal_f', 'internal_m', 'external_f']) ...[
          'body.diagram.$d',
          'body.alt.$d',
        ],
        for (final f in ['all', 'repro', 'urinary']) 'body.focus.$f',
        for (final d in [1, 2, 3]) 'difficulty.$d',
        for (final k in ['quick', 'lab', 'deep', 'unread']) 'explore.kind.$k',
        for (final h in Helpline.all) ...[
          'help.${h.id}.name',
          'help.${h.id}.desc',
        ],
        for (final l in [
          'body_lab',
          'puberty_lab',
          'period_lab',
          'myth_buster',
          'consent_sim',
          'relationship_radar', //
          'protection_lab',
          'digital_safety',
          'sti_match',
          'support_circle',
          'communication',
          'quiz',
          'final', 'signals', 'digital_challenge',
        ]) ...['lab.$l.title', 'lab.$l.sub'],
        for (final e in LegalScreen.sections.entries) ...[
          'legal.${e.key}.title',
          for (var i = 1; i <= e.value; i++) ...[
            'legal.${e.key}.$i.h',
            'legal.${e.key}.$i.b',
          ],
        ],
        for (final l in ['high', 'mid', 'low']) 'period.level.$l',
        for (var i = 1; i <= 4; i++) 'fert.$i',
        for (final k in ['pad', 'tampon', 'cup', 'cloth']) 'visual.$k',
        'body.where.inside',
        'body.where.outside',
        for (final g in ['methods', 'sti', 'vaccine', 'testing', 'care'])
          'prot.tab.$g',
        for (final g in ['all', 'f', 'm']) 'puberty.group.$g',
        for (final r in content.refs.values) 'refs.cat.${r.category}',
        for (final k in [
          'lessons',
          'faqs',
          'myths',
          'quiz',
          'scenarios',
          'glossaryTerms',
          'references',
        ])
          'refs.count.$k',
        for (final m in kScenarioModules) 'scen.$m.intro',
        for (final t in Tone.values) 'scen.tone.${t.name}',
        for (final e in ['full', 'school', 'adult']) 'settings.edition.$e',
        for (final s in ['healthy', 'concerning', 'harmful']) 'signals.$s',
        for (final t in ['curriculum', 'rules', 'safeguarding', 'coverage'])
          'teacher.tab.$t',
        for (final v in Verdict.values) 'verdict.${v.name}',
        for (final m in [
          'achievements',
          'bookmarks',
          'notes',
          'glossary',
          'safety',
          'teacher',
          'parents',
          'references',
          'settings',
        ]) ...['me.$m.title', 'me.$m.sub'],
        for (final p in content.preventionCards) 'prot.tab.${p.group}',
        for (final s in content.signals) 'signals.${s.category}',
      ];
      expect(keys.where((k) => !Strings.has(k)).toList(), isEmpty);
    });
  });
}
