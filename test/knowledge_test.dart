import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/knowledge.dart';
import 'package:unfiltered/data/store.dart';
import 'package:unfiltered/features/quiz/knowledge_test.dart';

import 'helpers.dart';

final _deva = RegExp(r'[ऀ-ॿ]');

void main() {
  late KnowledgeBank bank;
  setUpAll(() async {
    await loadFonts();
    await loadContent();
    bank = KnowledgeBank.parse(
      File('assets/content/knowledge/bank.json').readAsStringSync(),
    );
  });

  group('Test Your Knowledge bank (exported from the website)', () {
    test(
      'ships 1,000+ valid questions in English and Hinglish, all 12 topics',
      () {
        expect(bank.all.length, greaterThanOrEqualTo(1000));
        expect(
          {for (final q in bank.all) q.cat},
          {for (final c in kCats) c.key},
        );
        final ids = <String>{};
        for (final k in bank.all) {
          final q = k.quiz;
          expect(ids.add(q.id), isTrue, reason: 'duplicate ${q.id}');
          expect(q.options.length, inInclusiveRange(3, 4), reason: q.id);
          expect(
            q.answer,
            inInclusiveRange(0, q.options.length - 1),
            reason: q.id,
          );
          expect(q.tracks, isNotEmpty, reason: q.id);
          expect(k.level, inInclusiveRange(1, 3), reason: q.id);
          for (final l in [q.q, q.explain, ...q.options]) {
            expect(l.isComplete, isTrue, reason: q.id);
            expect(_deva.hasMatch(l.hg), isFalse, reason: q.id);
          }
        }
      },
    );

    test('a test only ever uses questions for the learner\'s age group', () {
      for (final track in Track.values) {
        for (final mode in KMode.values) {
          final List<String?> cats = mode == KMode.topic
              ? [for (final c in kCats) c.key]
              : [null];
          for (final cat in cats) {
            final qs = buildKnowledgeTest(
              bank,
              track,
              mode: mode,
              cat: cat,
              length: 30,
              random: Random(1),
            );
            for (final q in qs) {
              expect(
                q.tracks,
                contains(track),
                reason: '${q.id} in $mode/$cat for $track',
              );
            }
          }
        }
      }
      // young children have topics, but not contraception
      expect(bank.catsFor(Track.a).map((c) => c.key), contains('safety'));
      expect(
        bank.catsFor(Track.a).map((c) => c.key),
        isNot(contains('contraception')),
      );
    });

    test('shuffling options keeps the right answer right', () {
      final rnd = Random(7);
      for (final k in bank.all.take(200)) {
        final s = shuffleOptions(k.quiz, rnd);
        expect(s.options[s.answer].en, k.quiz.options[k.quiz.answer].en);
      }
    });

    test(
      'the daily challenge is the same set all day; mega spreads topics',
      () {
        final a = buildKnowledgeTest(bank, Track.e, mode: KMode.daily);
        final b = buildKnowledgeTest(bank, Track.e, mode: KMode.daily);
        expect(a, hasLength(10));
        expect([for (final q in a) q.id], [for (final q in b) q.id]);
        final mega = buildKnowledgeTest(bank, Track.e, mode: KMode.mega);
        expect(mega, hasLength(25));
        expect(
          {for (final q in mega) q.domain}.length,
          greaterThanOrEqualTo(12),
        );
      },
    );

    test('every Test Your Knowledge string exists in both languages', () {
      final keys = Strings.table.keys.where((k) => k.startsWith('kt.'));
      expect(keys.length, greaterThan(30));
      for (final k in keys) {
        for (final v in Strings.table[k]!) {
          expect(v, isNotEmpty, reason: k);
        }
      }
    });

    test('the challenge link carries the score for the website test', () {
      final u = challengeLink(Lang.hg, 'consent', 'Riya', 8, 10);
      expect(
        u,
        startsWith('https://theunfiltered.in/hinglish/test/consent/?ch='),
      );
      expect(Uri.parse(u).queryParameters['ch'], isNot(contains('=')));
    });
  });

  group('scores', () {
    test(
      'best score, daily result and seen ids are saved under uf. and wiped',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = AppStore(await SharedPreferences.getInstance());
        final c = ProviderContainer(
          overrides: [storeProvider.overrideWithValue(store)],
        );
        addTearDown(c.dispose);
        c.read(kScoresProvider.notifier).record('consent', 7, 10, ['a', 'b']);
        c.read(kScoresProvider.notifier).record('consent', 5, 10, ['c']);
        c.read(kScoresProvider.notifier).record('daily', 9, 10, [
          'd',
        ], daily: true);
        final s = c.read(kScoresProvider);
        expect(s.best['consent'], [7, 10]);
        expect(s.daily[istDay()], [9, 10]);
        expect(s.seen, containsAll(['a', 'b', 'c', 'd']));
        expect(s.dayStreak, 1);
        expect(store.prefs.getString('uf.kt'), isNotNull);
        await store.deleteAll();
        expect(store.prefs.getString('uf.kt'), isNull);
      },
    );
  });

  group('screens', () {
    testWidgets('hub -> daily challenge -> score poster', (t) async {
      final app = await pumpApp(
        t,
        settings: onboarded(track: Track.d),
        size: const Size(390, 1200),
      );
      Future<void> tapKey(String k) async {
        final f = find.byKey(Key(k));
        await t.ensureVisible(f);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      app.push('/test');
      await t.pumpAndSettle();
      expect(find.byKey(const Key('kt-daily')), findsOneWidget);
      expect(find.byKey(const Key('kt-mega')), findsOneWidget);
      await t.scrollUntilVisible(find.byKey(const Key('kt-cat-consent')), 300);
      expect(find.byKey(const Key('kt-cat-contraception')), findsOneWidget);

      app.push('/test/daily');
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('kt-start')));
      await t.pumpAndSettle();
      for (var i = 0; i < 10; i++) {
        await tapKey('quiz-opt-0');
        await tapKey('quiz-next');
      }
      expect(find.byKey(const Key('quiz-score')), findsOneWidget);
      final saved = app.container.read(kScoresProvider);
      expect(saved.daily[istDay()]?[1], 10);

      await tapKey('quiz-done');
      expect(find.byKey(const Key('kt-share')), findsOneWidget);
      await t.enterText(find.byKey(const Key('kt-name')), 'Riya');
      await t.enterText(find.byKey(const Key('kt-age')), '15');
      await t.pumpAndSettle();
      expect(find.text('Riya'), findsWidgets);
      expect(find.text(Strings.get('kt.share.kids', Lang.en)), findsOneWidget);
    });

    testWidgets('a 5-8 learner never sees the contraception test', (t) async {
      final app = await pumpApp(t, settings: onboarded(track: Track.a));
      app.push('/test');
      await t.pumpAndSettle();
      expect(find.byKey(const Key('kt-cat-contraception')), findsNothing);
      app.push('/test/contraception');
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('kt-start')));
      await t.pumpAndSettle();
      expect(find.text(Strings.get('kt.noneForAge', Lang.en)), findsOneWidget);
    });
  });
}
