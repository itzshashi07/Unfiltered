import 'package:flutter/widgets.dart';

import 'strings.dart';

/// App languages. Hinglish is the default experience.
enum Lang { hg, en }

extension LangX on Lang {
  String get label => switch (this) {
    Lang.hg => 'Hinglish',
    Lang.en => 'English',
  };

  /// Unknown or retired values (such as the old `hi` Hindi setting) open in Hinglish.
  static Lang parse(String? s) =>
      Lang.values.firstWhere((l) => l.name == s, orElse: () => Lang.hg);
}

/// Age-banded learning tracks. No birth date is ever collected.
enum Track { a, b, c, d, e }

extension TrackX on Track {
  String get code => name.toUpperCase();
  String get ages => const ['5–8', '9–12', '13–15', '16–17', '18+'][index];
  String get nameKey => 'track.$name.name';
  String get descKey => 'track.$name.desc';
  bool get isChild => this == Track.a || this == Track.b;
  bool get isMinor => this != Track.e;

  static Track? parse(String? s) {
    if (s == null) return null;
    for (final t in Track.values) {
      if (t.name == s.toLowerCase()) return t;
    }
    return null;
  }
}

/// A localized string in the two app languages.
@immutable
class L {
  final String en;
  final String hg;
  const L(this.en, this.hg);
  static const empty = L('', '');

  factory L.from(dynamic j) {
    if (j is Map) return L('${j['en'] ?? ''}', '${j['hg'] ?? ''}');
    if (j is String) return L(j, j);
    return empty;
  }

  String of(Lang l) {
    final v = switch (l) {
      Lang.en => en,
      Lang.hg => hg,
    };
    return v.isNotEmpty ? v : en;
  }

  bool get isEmpty => en.isEmpty && hg.isEmpty;
  bool get isComplete => en.isNotEmpty && hg.isNotEmpty;
  List<String> get all => [en, hg];
}

/// Makes language, track and motion preferences available to every widget.
class AppScope extends InheritedWidget {
  final Lang lang;
  final Track track;
  final bool reducedMotion;
  const AppScope({
    super.key,
    required this.lang,
    required this.track,
    required this.reducedMotion,
    required super.child,
  });

  static AppScope? maybeOf(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope old) =>
      old.lang != lang ||
      old.track != track ||
      old.reducedMotion != reducedMotion;
}

extension AppContext on BuildContext {
  Lang get lang => AppScope.maybeOf(this)?.lang ?? Lang.hg;
  Track get track => AppScope.maybeOf(this)?.track ?? Track.c;
  bool get reducedMotion =>
      (AppScope.maybeOf(this)?.reducedMotion ?? false) ||
      (MediaQuery.maybeDisableAnimationsOf(this) ?? false);

  /// UI string lookup. `{name}` placeholders are replaced from [args].
  String t(String key, [Map<String, Object>? args]) =>
      Strings.get(key, lang, args);

  /// Localized content lookup.
  String lx(L l) => l.of(lang);
}
