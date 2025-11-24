import 'package:flutter/material.dart';

// Ancoras de cor para o projeto.
// Se precisar ajustar a marca, altere só aqui.
class AppColors {
  // Base
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);

  // Paleta principal (ajuste conforme a paleta do FMABC)
  static const Color brandGreen  = Color.fromRGBO(56, 133, 59, 1); // "Acessar ATLAS"
  static const Color brandGray90 = Color.fromRGBO(43, 43, 43, 1); // "LOGIN"
  static const Color brandYellow = Color.fromRGBO(245, 160, 0, 1); // sublinhado menu
  static const Color textPrimary = Color.fromRGBO(17, 17, 17, 1);
  static const Color textMuted   = Color.fromRGBO(90, 90, 90, 1);

  // Superficies
  static const Color surface     = white;
  static const Color divider     = Color.fromRGBO(0, 0, 0, 0.067);
}

// Tema global
ThemeData buildAppTheme() {
  final seed = AppColors.brandGreen;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed).copyWith(
      primary: AppColors.brandGreen,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
    ),
  );
}