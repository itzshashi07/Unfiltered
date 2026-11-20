import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n.dart';

/// Brand palette. Widgets should use [AppColors] semantic tokens, not these.
class Palette {
  static const dark = Color(0xFF111127);
  static const purple = Color(0xFF765BFF);
  static const coral = Color(0xFFFF677B);
  static const lavender = Color(0xFFF0EBFF);
  static const mint = Color(0xFFA9EBD4);
  static const cream = Color(0xFFFFF9F1);
  static const blue = Color(0xFF80B9FF);
  static const sun = Color(0xFFFFC95C);
  static const deepMint = Color(0xFF1FA67A);
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkSoft;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color coral;
  final Color mint;
  final Color blue;
  final Color sun;
  final Color outline;
  final Color success;
  final Color warning;
  final Color danger;
  final Color hero; // always-dark hero surface
  final Color onHero;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.coral,
    required this.mint,
    required this.blue,
    required this.sun,
    required this.outline,
    required this.success,
    required this.warning,
    required this.danger,
    required this.hero,
    required this.onHero,
  });

  static AppColors light({bool highContrast = false}) => AppColors(
    bg: Palette.cream,
    surface: Colors.white,
    surfaceAlt: Palette.lavender,
    ink: Palette.dark,
    inkSoft: highContrast ? const Color(0xFF2A2A45) : const Color(0xFF5B5B78),
    primary: highContrast ? const Color(0xFF4A2FE0) : Palette.purple,
    onPrimary: Colors.white,
    primarySoft: const Color(0xFFE4DCFF),
    coral: highContrast ? const Color(0xFFD42B45) : Palette.coral,
    mint: Palette.mint,
    blue: Palette.blue,
    sun: Palette.sun,
    outline: highContrast ? const Color(0xFF111127) : const Color(0xFFE6E0F5),
    success: const Color(0xFF12855F),
    warning: const Color(0xFFB36A00),
    danger: const Color(0xFFC62F47),
    hero: Palette.dark,
    onHero: Colors.white,
  );

  static AppColors dark({bool highContrast = false}) => AppColors(
    bg: const Color(0xFF0B0B1A),
    surface: const Color(0xFF191932),
    surfaceAlt: const Color(0xFF23234A),
    ink: Colors.white,
    inkSoft: highContrast ? const Color(0xFFE2E2F5) : const Color(0xFFA9A9C8),
    primary: highContrast ? const Color(0xFFB8A8FF) : const Color(0xFF9580FF),
    onPrimary: highContrast ? Palette.dark : Colors.white,
    primarySoft: const Color(0xFF2E2863),
    coral: const Color(0xFFFF8090),
    mint: const Color(0xFF7FDDBD),
    blue: const Color(0xFF8FC2FF),
    sun: const Color(0xFFFFD27A),
    outline: highContrast ? Colors.white : const Color(0xFF30305A),
    success: const Color(0xFF5BE0B0),
    warning: const Color(0xFFFFC66B),
    danger: const Color(0xFFFF8A9A),
    hero: const Color(0xFF1D1D42),
    onHero: Colors.white,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      other is AppColors && t > 0.5 ? other : this;
}

extension ThemeContext on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
  TextTheme get tx => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

const kFont = 'PlusJakartaSans';

ThemeData buildTheme({
  required bool dark,
  required bool highContrast,
  required Lang lang,
}) {
  final c = dark
      ? AppColors.dark(highContrast: highContrast)
      : AppColors.light(highContrast: highContrast);
  const family = kFont;
  const lh = 1.35;

  TextStyle s(
    double size,
    FontWeight w, {
    double? height,
    double? ls,
    Color? color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: w,
    height: height ?? lh,
    letterSpacing: ls,
    color: color ?? c.ink,
  );

  final text = TextTheme(
    displayLarge: s(40, FontWeight.w800, height: 1.1, ls: -1),
    displayMedium: s(32, FontWeight.w800, height: 1.15, ls: -0.8),
    displaySmall: s(27, FontWeight.w800, height: 1.18, ls: -0.5),
    headlineMedium: s(23, FontWeight.w800, height: 1.22, ls: -0.3),
    headlineSmall: s(20, FontWeight.w700, height: 1.25, ls: -0.2),
    titleLarge: s(18, FontWeight.w700, height: 1.3),
    titleMedium: s(16, FontWeight.w700, height: 1.3),
    titleSmall: s(14, FontWeight.w700, height: 1.3),
    bodyLarge: s(16.5, FontWeight.w500, height: 1.55),
    bodyMedium: s(14.5, FontWeight.w500, height: 1.5),
    bodySmall: s(12.5, FontWeight.w500, height: 1.45, color: c.inkSoft),
    labelLarge: s(15, FontWeight.w700, height: 1.2),
    labelMedium: s(12.5, FontWeight.w700, height: 1.2, ls: 0.2),
    labelSmall: s(11, FontWeight.w700, height: 1.2, ls: 0.6, color: c.inkSoft),
  );

  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.coral,
    onSecondary: Colors.white,
    error: c.danger,
    onError: Colors.white,
    surface: c.surface,
    onSurface: c.ink,
    surfaceContainerHighest: c.surfaceAlt,
    outline: c.outline,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    textTheme: text,
    fontFamily: family,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: text.titleLarge,
    ),
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: c.ink),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.hero,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.onHero),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      hintStyle: text.bodyMedium?.copyWith(color: c.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.outline, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.primarySoft,
      thumbColor: c.primary,
      overlayColor: c.primary.withValues(alpha: 0.12),
      trackHeight: 6,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.inkSoft,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceAlt,
      ),
      trackOutlineColor: WidgetStateProperty.all(c.outline),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}

/// Visual identity of each of the 18 curriculum domains.
class DomainStyle {
  final Color a;
  final Color b;
  final IconData icon;
  const DomainStyle(this.a, this.b, this.icon);

  static const _styles = <String, DomainStyle>{
    'd01': DomainStyle(
      Color(0xFF765BFF),
      Color(0xFFB5A4FF),
      Icons.accessibility_new_rounded,
    ),
    'd02': DomainStyle(
      Color(0xFFFF8A5B),
      Color(0xFFFFC95C),
      Icons.auto_awesome_rounded,
    ),
    'd03': DomainStyle(
      Color(0xFFFF677B),
      Color(0xFFFFA6B2),
      Icons.water_drop_rounded,
    ),
    'd04': DomainStyle(
      Color(0xFFE255A1),
      Color(0xFFFF9FD0),
      Icons.favorite_rounded,
    ),
    'd05': DomainStyle(
      Color(0xFF12A37A),
      Color(0xFFA9EBD4),
      Icons.back_hand_rounded,
    ),
    'd06': DomainStyle(
      Color(0xFF3D8BFF),
      Color(0xFF80B9FF),
      Icons.diversity_1_rounded,
    ),
    'd07': DomainStyle(
      Color(0xFF5B6BFF),
      Color(0xFF9DB0FF),
      Icons.shield_rounded,
    ),
    'd08': DomainStyle(
      Color(0xFFB45BFF),
      Color(0xFFDDB0FF),
      Icons.child_friendly_rounded,
    ),
    'd09': DomainStyle(
      Color(0xFF00A3B4),
      Color(0xFF8BE3EC),
      Icons.coronavirus_rounded,
    ),
    'd10': DomainStyle(
      Color(0xFF2FB36B),
      Color(0xFFA5E8C2),
      Icons.health_and_safety_rounded,
    ),
    'd11': DomainStyle(
      Color(0xFFFF6B4A),
      Color(0xFFFFC95C),
      Icons.diversity_3_rounded,
    ),
    'd12': DomainStyle(
      Color(0xFF4A4A8F),
      Color(0xFF9D9DE0),
      Icons.smart_display_rounded,
    ),
    'd13': DomainStyle(
      Color(0xFF2F6BFF),
      Color(0xFF7FD4FF),
      Icons.phonelink_lock_rounded,
    ),
    'd14': DomainStyle(
      Color(0xFF3A3A6E),
      Color(0xFF8C8CD0),
      Icons.volunteer_activism_rounded,
    ),
    'd15': DomainStyle(
      Color(0xFFE8862E),
      Color(0xFFFFD28A),
      Icons.fact_check_rounded,
    ),
    'd16': DomainStyle(
      Color(0xFF5E5A8C),
      Color(0xFFB7B3E6),
      Icons.gavel_rounded,
    ),
    'd17': DomainStyle(
      Color(0xFF2BAE9E),
      Color(0xFFA9EBD4),
      Icons.self_improvement_rounded,
    ),
    'd18': DomainStyle(
      Color(0xFFEF5DA8),
      Color(0xFFFFB3D9),
      Icons.record_voice_over_rounded,
    ),
  };

  static DomainStyle of(String id) =>
      _styles[id] ??
      const DomainStyle(Palette.purple, Palette.lavender, Icons.school_rounded);
}
