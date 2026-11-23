import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import 'content.dart';
import 'knowledge.dart';
import 'models.dart';

/// Bump when the persisted shape changes; see [AppStore.migrate].
const kSchemaVersion = 2;

/// Build-time edition: `full` (default), `school` (tracks A-D) or `adult` (track E).
/// Set with `--dart-define=EDITION=school`.
const kEdition = String.fromEnvironment('EDITION', defaultValue: 'full');

List<Track> get editionTracks => switch (kEdition) {
  'school' => const [Track.a, Track.b, Track.c, Track.d],
  'adult' => const [Track.e],
  _ => Track.values,
};

@immutable
class AppSettings {
  final Lang lang;
  final Track? track;
  final ThemeMode theme;
  final double textScale;
  final bool reducedMotion;
  final bool highContrast;
  final bool onboarded;
  final List<String> interests;

  /// Educator lock: hash of a PIN that protects track changes. Null = unlocked.
  final String? pinHash;

  /// Tracks an educator has allowed on this device (school-managed setup).
  final List<Track> allowedTracks;

  /// Optional "Topics I want to explore" chips. Empty = show all. Stored only
  /// on this device; it is a topic preference, not an identity record.
  final TopicFilter topics;

  const AppSettings({
    this.lang = Lang.hg,
    this.track,
    this.theme = ThemeMode.system,
    this.textScale = 1.0,
    this.reducedMotion = false,
    this.highContrast = false,
    this.onboarded = false,
    this.interests = const [],
    this.pinHash,
    this.allowedTracks = Track.values,
    this.topics = TopicFilter.all,
  });

  bool get locked => pinHash != null;

  /// Tracks this device may switch to (edition ∩ educator allow-list).
  List<Track> get selectableTracks => [
    for (final t in editionTracks)
      if (allowedTracks.contains(t)) t,
  ];

  AppSettings copyWith({
    Lang? lang,
    Track? track,
    ThemeMode? theme,
    double? textScale,
    bool? reducedMotion,
    bool? highContrast,
    bool? onboarded,
    List<String>? interests,
    String? pinHash,
    bool clearPin = false,
    List<Track>? allowedTracks,
    TopicFilter? topics,
  }) => AppSettings(
    lang: lang ?? this.lang,
    track: track ?? this.track,
    theme: theme ?? this.theme,
    textScale: textScale ?? this.textScale,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    highContrast: highContrast ?? this.highContrast,
    onboarded: onboarded ?? this.onboarded,
    interests: interests ?? this.interests,
    pinHash: clearPin ? null : (pinHash ?? this.pinHash),
    allowedTracks: allowedTracks ?? this.allowedTracks,
    topics: topics ?? this.topics,
  );

  Map<String, dynamic> toJson() => {
    'lang': lang.name,
    'track': track?.name,
    'theme': theme.name,
    'textScale': textScale,
    'reducedMotion': reducedMotion,
    'highContrast': highContrast,
    'onboarded': onboarded,
    'interests': interests,
    'pinHash': pinHash,
    'allowedTracks': [for (final t in allowedTracks) t.name],
    'topicAudience': [
      for (final a in Audience.values)
        if (topics.audience.contains(a)) a.key,
    ],
    'topicBody': [
      for (final b in BodyTopic.values)
        if (topics.body.contains(b)) b.key,
    ],
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    final allowed = [
      for (final t in (j['allowedTracks'] as List? ?? const []))
        if (TrackX.parse('$t') != null) TrackX.parse('$t')!,
    ];
    return AppSettings(
      lang: LangX.parse(j['lang'] as String?),
      track: TrackX.parse(j['track'] as String?),
      theme: ThemeMode.values.firstWhere(
        (m) => m.name == j['theme'],
        orElse: () => ThemeMode.system,
      ),
      textScale: ((j['textScale'] as num?)?.toDouble() ?? 1.0).clamp(0.85, 1.6),
      reducedMotion: j['reducedMotion'] == true,
      highContrast: j['highContrast'] == true,
      onboarded: j['onboarded'] == true,
      interests: [for (final s in (j['interests'] as List? ?? const [])) '$s'],
      pinHash: j['pinHash'] as String?,
      allowedTracks: allowed.isEmpty ? Track.values : allowed,
      topics: TopicFilter(
        audience: {
          for (final a in (j['topicAudience'] as List? ?? const []))
            if (AudienceX.parse('$a') != null) AudienceX.parse('$a')!,
        },
        body: {
          for (final b in (j['topicBody'] as List? ?? const []))
            if (BodyTopicX.parse('$b') != null) BodyTopicX.parse('$b')!,
        },
      ),
    );
  }
}

@immutable
class Note {
  final String id;
  final String text;
  final String created;
  const Note(this.id, this.text, this.created);
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'created': created};
  factory Note.fromJson(Map<String, dynamic> j) =>
      Note('${j['id']}', '${j['text']}', '${j['created']}');
}

@immutable
class Progress {
  /// lessonId -> ISO date of completion.
  final Map<String, String> completed;

  /// quiz key (`lesson:<id>`, `domain:<id>`, `final`) -> best percent.
  final Map<String, int> quizBest;
  final Set<String> bookmarks;
  final Set<String> mythsSeen;
  final Set<String> scenariosDone;
  final Set<String> labsVisited;
  final Set<String> support;
  final List<Note> notes;
  final String? lastLesson;

  const Progress({
    this.completed = const {},
    this.quizBest = const {},
    this.bookmarks = const {},
    this.mythsSeen = const {},
    this.scenariosDone = const {},
    this.labsVisited = const {},
    this.support = const {},
    this.notes = const [],
    this.lastLesson,
  });

  bool get isEmpty =>
      completed.isEmpty &&
      quizBest.isEmpty &&
      bookmarks.isEmpty &&
      mythsSeen.isEmpty &&
      scenariosDone.isEmpty &&
      labsVisited.isEmpty &&
      support.isEmpty &&
      notes.isEmpty &&
      lastLesson == null;

  Set<String> get completedIds => completed.keys.toSet();

  Progress copyWith({
    Map<String, String>? completed,
    Map<String, int>? quizBest,
    Set<String>? bookmarks,
    Set<String>? mythsSeen,
    Set<String>? scenariosDone,
    Set<String>? labsVisited,
    Set<String>? support,
    List<Note>? notes,
    String? lastLesson,
  }) => Progress(
    completed: completed ?? this.completed,
    quizBest: quizBest ?? this.quizBest,
    bookmarks: bookmarks ?? this.bookmarks,
    mythsSeen: mythsSeen ?? this.mythsSeen,
    scenariosDone: scenariosDone ?? this.scenariosDone,
    labsVisited: labsVisited ?? this.labsVisited,
    support: support ?? this.support,
    notes: notes ?? this.notes,
    lastLesson: lastLesson ?? this.lastLesson,
  );

  Map<String, dynamic> toJson() => {
    'completed': completed,
    'quizBest': quizBest,
    'bookmarks': bookmarks.toList(),
    'mythsSeen': mythsSeen.toList(),
    'scenariosDone': scenariosDone.toList(),
    'labsVisited': labsVisited.toList(),
    'support': support.toList(),
    'notes': [for (final n in notes) n.toJson()],
    'lastLesson': lastLesson,
  };

  factory Progress.fromJson(Map<String, dynamic> j) {
    Set<String> set(String k) => {
      for (final s in (j[k] as List? ?? const [])) '$s',
    };
    final c = j['completed'];
    return Progress(
      // v1 stored a plain list of ids; v2 stores id -> date.
      completed: c is Map
          ? {for (final e in c.entries) '${e.key}': '${e.value}'}
          : {for (final id in (c as List? ?? const [])) '$id': ''},
      quizBest: {
        for (final e in ((j['quizBest'] as Map?) ?? const {}).entries)
          '${e.key}': (e.value as num).toInt(),
      },
      bookmarks: set('bookmarks'),
      mythsSeen: set('mythsSeen'),
      scenariosDone: set('scenariosDone'),
      labsVisited: set('labsVisited'),
      support: set('support'),
      notes: [
        for (final n in (j['notes'] as List? ?? const []))
          if (n is Map) Note.fromJson(n.cast<String, dynamic>()),
      ],
      lastLesson: j['lastLesson'] as String?,
    );
  }
}

/// Small stable hash for the educator PIN (FNV-1a). This is a convenience
/// lock for a local setting, not a security boundary.
String hashPin(String pin) {
  var h = 0x811c9dc5;
  for (final u in 'unfiltered:$pin'.codeUnits) {
    h ^= u;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(8, '0');
}

/// On-device persistence. Nothing here ever leaves the device.
class AppStore {
  final SharedPreferences prefs;
  AppStore(this.prefs);

  static const prefix = 'uf.';
  static const _kSettings = '${prefix}settings';
  static const _kProgress = '${prefix}progress';
  static const _kSchema = '${prefix}schema';

  static Future<AppStore> open() async {
    final store = AppStore(await SharedPreferences.getInstance());
    await store.migrate();
    return store;
  }

  /// Upgrades older saved data in place. v1 -> v2: `completed` list became a
  /// map of id -> date (handled by [Progress.fromJson]) and is re-saved.
  Future<void> migrate() async {
    final v =
        prefs.getInt(_kSchema) ??
        (prefs.containsKey(_kProgress) ? 1 : kSchemaVersion);
    if (v < kSchemaVersion) {
      await writeProgress(readProgress());
    }
    await prefs.setInt(_kSchema, kSchemaVersion);
  }

  Map<String, dynamic>? _read(String key) {
    final s = prefs.getString(key);
    if (s == null) return null;
    try {
      return (jsonDecode(s) as Map).cast<String, dynamic>();
    } catch (_) {
      return null; // corrupted data is treated as empty, never a crash
    }
  }

  AppSettings readSettings() {
    final j = _read(_kSettings);
    return j == null ? const AppSettings() : AppSettings.fromJson(j);
  }

  Future<void> writeSettings(AppSettings s) =>
      prefs.setString(_kSettings, jsonEncode(s.toJson()));

  Progress readProgress() {
    final j = _read(_kProgress);
    return j == null ? const Progress() : Progress.fromJson(j);
  }

  Future<void> writeProgress(Progress p) =>
      prefs.setString(_kProgress, jsonEncode(p.toJson()));

  /// Removes every key this app has written.
  Future<void> deleteAll() async {
    for (final k
        in prefs.getKeys().where((k) => k.startsWith(prefix)).toList()) {
      await prefs.remove(k);
    }
  }

  /// Everything stored on this device, for the learner's own export.
  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'app': 'UNFILTERED',
    'schema': kSchemaVersion,
    'settings': readSettings().toJson()..remove('pinHash'),
    'progress': readProgress().toJson(),
  });
}

final storeProvider = Provider<AppStore>(
  (ref) => throw UnimplementedError('storeProvider must be overridden'),
);
final contentProvider = Provider<ContentRepository>(
  (ref) => throw UnimplementedError('contentProvider must be overridden'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    var s = ref.read(storeProvider).readSettings();
    // Never leave a device on a track its edition or educator has not allowed.
    final ok = s.selectableTracks;
    if (s.track != null && ok.isNotEmpty && !ok.contains(s.track)) {
      s = s.copyWith(track: ok.first);
    }
    return s;
  }

  void _set(AppSettings s) {
    state = s;
    ref.read(storeProvider).writeSettings(s);
  }

  void setLang(Lang l) => _set(state.copyWith(lang: l));
  void setTheme(ThemeMode m) => _set(state.copyWith(theme: m));
  void setTextScale(double v) => _set(state.copyWith(textScale: v));
  void setReducedMotion(bool v) => _set(state.copyWith(reducedMotion: v));
  void setHighContrast(bool v) => _set(state.copyWith(highContrast: v));
  void setInterests(List<String> v) => _set(state.copyWith(interests: v));

  // "Topics I want to explore": optional, local, and only a way to organise.
  void setTopics(TopicFilter f) => _set(state.copyWith(topics: f));
  void toggleAudience(Audience a) => setTopics(state.topics.toggleAudience(a));
  void toggleBodyTopic(BodyTopic b) => setTopics(state.topics.toggleBody(b));
  void clearTopics() => setTopics(TopicFilter.all);
  void completeOnboarding() => _set(state.copyWith(onboarded: true));

  /// Changes the learning track. Returns false when the track is not allowed
  /// or the educator lock is on and [pin] is wrong.
  bool setTrack(Track t, {String? pin}) {
    if (!state.selectableTracks.contains(t)) return false;
    if (state.locked && state.track != null && !checkPin(pin ?? '')) {
      return false;
    }
    _set(state.copyWith(track: t));
    return true;
  }

  bool checkPin(String pin) =>
      state.pinHash != null && hashPin(pin) == state.pinHash;

  /// Turns the educator lock on with [pin] and restricts tracks to [allowed].
  void lock(String pin, List<Track> allowed) {
    final tracks = allowed.isEmpty ? Track.values : allowed;
    var s = state.copyWith(pinHash: hashPin(pin), allowedTracks: tracks);
    if (s.track != null &&
        !s.selectableTracks.contains(s.track) &&
        s.selectableTracks.isNotEmpty) {
      s = s.copyWith(track: s.selectableTracks.first);
    }
    _set(s);
  }

  bool unlock(String pin) {
    if (!checkPin(pin)) return false;
    _set(state.copyWith(clearPin: true, allowedTracks: Track.values));
    return true;
  }

  void reset() => state = const AppSettings();
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class ProgressNotifier extends Notifier<Progress> {
  @override
  Progress build() => ref.read(storeProvider).readProgress();

  void _set(Progress p) {
    state = p;
    ref.read(storeProvider).writeProgress(p);
  }

  void openLesson(String id) => _set(state.copyWith(lastLesson: id));

  void completeLesson(String id, {DateTime? now}) {
    if (state.completed.containsKey(id)) return;
    final d = (now ?? DateTime.now()).toIso8601String().substring(0, 10);
    _set(
      state.copyWith(completed: {...state.completed, id: d}, lastLesson: id),
    );
  }

  /// Saves a quiz result, keeping the best percent for [key].
  void recordQuiz(String key, int correct, int total) {
    if (total <= 0) return;
    final pct = quizPercent(correct, total);
    if (pct > (state.quizBest[key] ?? -1)) {
      _set(state.copyWith(quizBest: {...state.quizBest, key: pct}));
    }
  }

  void toggleBookmark(String id) {
    final b = {...state.bookmarks};
    b.contains(id) ? b.remove(id) : b.add(id);
    _set(state.copyWith(bookmarks: b));
  }

  void seeMyth(String id) {
    if (!state.mythsSeen.contains(id)) {
      _set(state.copyWith(mythsSeen: {...state.mythsSeen, id}));
    }
  }

  void finishScenario(String id) {
    if (!state.scenariosDone.contains(id)) {
      _set(state.copyWith(scenariosDone: {...state.scenariosDone, id}));
    }
  }

  void visitLab(String id) {
    if (!state.labsVisited.contains(id)) {
      _set(state.copyWith(labsVisited: {...state.labsVisited, id}));
    }
  }

  void toggleSupport(String id) {
    final s = {...state.support};
    s.contains(id) ? s.remove(id) : s.add(id);
    _set(state.copyWith(support: s));
  }

  void addNote(String text, {DateTime? now}) {
    final t = text.trim();
    if (t.isEmpty) return;
    final n = now ?? DateTime.now();
    _set(
      state.copyWith(
        notes: [
          Note(
            '${n.microsecondsSinceEpoch}',
            t,
            n.toIso8601String().substring(0, 10),
          ),
          ...state.notes,
        ],
      ),
    );
  }

  void deleteNote(String id) => _set(
    state.copyWith(
      notes: [
        for (final n in state.notes)
          if (n.id != id) n,
      ],
    ),
  );

  void deleteAllNotes() => _set(state.copyWith(notes: const []));

  void reset() => state = const Progress();
}

final progressProvider = NotifierProvider<ProgressNotifier, Progress>(
  ProgressNotifier.new,
);

/// Rounded percentage score for a quiz.
int quizPercent(int correct, int total) =>
    total <= 0 ? 0 : ((correct * 100) / total).round();

/// Wipes all local data and resets in-memory state.
Future<void> deleteAllLocalData(WidgetRef ref) async {
  await ref.read(storeProvider).deleteAll();
  ref.read(settingsProvider.notifier).reset();
  ref.read(progressProvider.notifier).reset();
  ref.read(kScoresProvider.notifier).reset();
}
