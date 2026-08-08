import 'package:flutter/material.dart';

/// Acento em latão/âmbar — remete para o ponteiro e os números de um
/// cronómetro analógico, distinto do "cinzento roxo" habitual em apps novas.
const _accent = Color(0xFF96691F);

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFEFF2F0),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFEFF2F0),
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF121815),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121815),
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}

/// Paleta fixa de cores à escolha do utilizador ao criar/editar um hobby.
const List<Color> hobbyColorPalette = [
  Color(0xFF96691F), // latão
  Color(0xFF2F6F5C), // verde-azulado
  Color(0xFF3E5C9A), // azul
  Color(0xFF8A3B2B), // terracota
  Color(0xFF6B4E9A), // roxo
  Color(0xFF4A7A2E), // verde
  Color(0xFFB0433A), // vermelho
  Color(0xFF3A6E8A), // petróleo
];

/// Pequeno conjunto de ícones representativos de hobbies comuns; o
/// utilizador escolhe um destes em vez de navegar num seletor genérico.
const List<IconData> hobbyIconChoices = [
  Icons.piano,
  Icons.music_note,
  Icons.brush,
  Icons.menu_book,
  Icons.directions_run,
  Icons.fitness_center,
  Icons.self_improvement,
  Icons.code,
  Icons.language,
  Icons.camera_alt,
  Icons.sports_esports,
  Icons.restaurant,
  Icons.pets,
  Icons.park,
  Icons.palette,
  Icons.star,
];
