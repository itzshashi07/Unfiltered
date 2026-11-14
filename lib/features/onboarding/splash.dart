import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';

/// The brand wordmark, drawn with text so it stays crisp at any size.
class Wordmark extends StatelessWidget {
  final double size;
  final Color? color;
  const Wordmark({super.key, this.size = 30, this.color});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: kFont,
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -size * 0.03,
      height: 1,
      color: color ?? context.c.ink,
    );
    return Semantics(
      label: 'UNFILTERED',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'UN',
                style: style.copyWith(color: Palette.coral),
              ),
              TextSpan(text: 'FILTERED', style: style),
            ],
          ),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = context.reducedMotion;
    if (reduced) {
      _c.value = 1;
    } else {
      _c.forward();
    }
    _timer = Timer(Duration(milliseconds: reduced ? 350 : 1700), _go);
  }

  void _go() {
    if (!mounted) return;
    final s = ref.read(settingsProvider);
    context.go(s.onboarded && s.track != null ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.dark,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _timer?.cancel();
          _go();
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final pop = Curves.elasticOut.transform(_c.value.clamp(0.0, 1.0));
              final fade = Curves.easeOut.transform(
                ((_c.value - 0.35) / 0.65).clamp(0.0, 1.0),
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.4 + 0.6 * pop,
                    child: const Mascot(size: 132, mood: Mood.happy),
                  ),
                  const SizedBox(height: 22),
                  Opacity(
                    opacity: fade,
                    child: Transform.translate(
                      offset: Offset(0, (1 - fade) * 14),
                      child: Column(
                        children: [
                          const Wordmark(size: 40, color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            context.t('brand.tagline'),
                            style: context.tx.titleMedium?.copyWith(
                              color: Palette.mint,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
