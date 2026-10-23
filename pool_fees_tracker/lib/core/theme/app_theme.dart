import 'package:flutter/material.dart';

/// Paleta de cores da app, dependente do tema (dark/light) — lida via
/// `AppPalette.of(context)`. Nasceu como uma classe `AppColors` de
/// constantes fixas (só dark); passou a `ThemeExtension` para suportar
/// tema claro sem duplicar toda a árvore de widgets.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color positive;
  final Color negative;
  final Color warning;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.positive,
    required this.negative,
    required this.warning,
  });

  /// Fundo quase preto, acento rosa (nod à marca Uniswap), verde/âmbar
  /// para variações positivas/estado de atenção — o visual "trading app"
  /// original da app.
  factory AppPalette.dark() => const AppPalette(
    background: Color(0xFF0A0B0D),
    surface: Color(0xFF15171B),
    surfaceAlt: Color(0xFF1C1F24),
    border: Color(0xFF1F2227),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFF8A8F98),
    textTertiary: Color(0xFF5B6168),
    accent: Color(0xFFFF4FA3),
    positive: Color(0xFF33D17A),
    negative: Color(0xFFFF5C5C),
    warning: Color(0xFFFFB020),
  );

  /// Mesma identidade (acento rosa, verde/âmbar/vermelho com o mesmo
  /// significado), fundo claro — contraste de texto verificado para
  /// WCAG AA (4.5:1) sobre `surface`/`background`.
  factory AppPalette.light() => const AppPalette(
    background: Color(0xFFFAFAFB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F1F3),
    border: Color(0xFFE2E4E8),
    textPrimary: Color(0xFF14151A),
    textSecondary: Color(0xFF5B6168),
    textTertiary: Color(0xFF80858C),
    accent: Color(0xFFD6267F),
    positive: Color(0xFF1C9A5B),
    negative: Color(0xFFD63B3B),
    warning: Color(0xFFB8740A),
  );

  /// Variante do tema escuro pedida pelo utilizador: "algo moderno", com
  /// degradê de cima para baixo. `background` fica transparente de
  /// propósito — o degradê real é pintado uma só vez, por trás de toda a
  /// app, em `PoolFeesTrackerApp` (ver `extraDarkBackgroundGradient`
  /// abaixo); se `background` fosse uma cor sólida aqui, o Scaffold do
  /// ecrã de detalhe (e o tema dos AppBars) pintava por cima e escondia-o.
  factory AppPalette.extraDark() => const AppPalette(
    background: Colors.transparent,
    surface: Color(0xFF191225),
    surfaceAlt: Color(0xFF221A33),
    border: Color(0xFF2E2440),
    textPrimary: Color(0xFFF2F0F8),
    textSecondary: Color(0xFF9D94B5),
    textTertiary: Color(0xFF6B6285),
    accent: Color(0xFFFF4FA3),
    positive: Color(0xFF33D17A),
    negative: Color(0xFFFF5C5C),
    warning: Color(0xFFFFB020),
  );

  /// Degradê pintado por trás de toda a app quando o tema é
  /// `AppThemeMode.extraDark` — do roxo quase preto no topo a um preto
  /// puro no fundo, "algo moderno" em vez de uma cor lisa.
  static const extraDarkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF130E1C), Color(0xFF07060A)],
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? AppPalette.dark();

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? positive,
    Color? negative,
    Color? warning,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

class AppTheme {
  static ThemeData dark() => _build(AppPalette.dark(), Brightness.dark);

  static ThemeData light() => _build(AppPalette.light(), Brightness.light);

  static ThemeData extraDark() =>
      _build(AppPalette.extraDark(), Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
    ).copyWith(surface: palette.surface, primary: palette.accent);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: 'Roboto',
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.accent.withValues(alpha: 0.16),
      ),
      textTheme: TextTheme(bodyMedium: TextStyle(color: palette.textPrimary))
          .apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          ),
    );
  }
}
