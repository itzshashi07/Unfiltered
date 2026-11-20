import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfiltered/app.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/magazine.dart';
import 'package:unfiltered/data/store.dart';

ContentRepository? _content;

/// Loads the real bundled curriculum straight from `assets/content/`.
Future<ContentRepository> loadContent() async {
  _loadMagazineFiles();
  return _content ??= await ContentRepository.load((p) async {
    final f = File('assets/content/$p');
    return f.existsSync() ? f.readAsString() : null;
  });
}

/// Magazine files, read once up front: real file IO cannot run inside
/// testWidgets' fake async zone, so the app reads them from memory.
final magazineFiles = <String, String>{};
void _loadMagazineFiles() {
  if (magazineFiles.isNotEmpty) return;
  final root = Directory('assets/content/magazine');
  if (!root.existsSync()) return;
  for (final f in root.listSync(recursive: true).whereType<File>()) {
    final rel = f.path.replaceFirst('assets/content/', '');
    magazineFiles[rel] = f.readAsStringSync();
  }
}

Future<String?> readMagazineFile(String p) async => magazineFiles[p];

/// Registers the real fonts so layout in widget tests matches the device.
Future<void> loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      final bytes = File('assets/fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await family('PlusJakartaSans', [
    for (final w in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$w.ttf',
  ]);
}

/// Settings for an already-onboarded learner. Reduced motion keeps looping
/// animations from blocking `pumpAndSettle`.
AppSettings onboarded({Track track = Track.c, Lang lang = Lang.en}) =>
    AppSettings(lang: lang, track: track, onboarded: true, reducedMotion: true);

class TestApp {
  final ProviderContainer container;
  final SharedPreferences prefs;
  TestApp(this.container, this.prefs);

  void go(String route) => container.read(routerProvider).go(route);
  void push(String route) => container.read(routerProvider).push(route);
  AppSettings get settings => container.read(settingsProvider);
  Progress get progress => container.read(progressProvider);
}

/// Pumps the whole app on a phone-sized screen.
/// Pass [keepPrefs] to simulate an app restart with the same saved data.
Future<TestApp> pumpApp(
  WidgetTester tester, {
  AppSettings? settings,
  Progress? progress,
  bool keepPrefs = false,
  Size size = const Size(390, 844),
}) async {
  // The OS "remove animations" setting: stops looping decorative animations so
  // pumpAndSettle can finish. The app treats it the same as its own setting.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  if (!keepPrefs) {
    SharedPreferences.setMockInitialValues({
      if (settings != null) 'uf.settings': jsonEncode(settings.toJson()),
      if (progress != null) 'uf.progress': jsonEncode(progress.toJson()),
    });
  }
  final prefs = await SharedPreferences.getInstance();
  final store = AppStore(prefs);
  await store.migrate();
  final content = await loadContent();
  final container = ProviderContainer(
    overrides: [
      storeProvider.overrideWithValue(store),
      contentProvider.overrideWithValue(content),
      magazineReaderProvider.overrideWithValue(readMagazineFile),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const UnfilteredApp(),
    ),
  );
  // Let the splash hand over to onboarding / home.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
  return TestApp(container, prefs);
}

/// The vertical scrollable of the page currently on top.
Finder get pageScroll => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

/// Scrolls the visible page until [finder] is built and on screen.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.drag(pageScroll, const Offset(0, -350));
    await tester.pumpAndSettle();
  }
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Scrolls until [finder] is visible, then taps it.
Future<void> scrollTap(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
