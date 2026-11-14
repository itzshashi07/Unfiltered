import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/content.dart';
import 'data/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Everything is local: saved settings/progress and the bundled curriculum.
  final store = await AppStore.open();
  final content = await ContentRepository.fromBundle(rootBundle);
  runApp(
    ProviderScope(
      overrides: [
        storeProvider.overrideWithValue(store),
        contentProvider.overrideWithValue(content),
      ],
      child: const UnfilteredApp(),
    ),
  );
}
