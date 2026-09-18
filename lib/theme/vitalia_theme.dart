import 'package:flutter/material.dart';
import 'package:vitalia/theme/palette.dart';

ThemeData vitaliaTheme() {
  const ink = VitaliaPalette.ink;
  const paper = VitaliaPalette.paper;
  const sage = VitaliaPalette.sage;
  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      fontSize: 56,
      height: 1.05,
      color: ink,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      fontSize: 40,
      height: 1.1,
      color: ink,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      fontSize: 32,
      height: 1.15,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      fontSize: 26,
      height: 1.2,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      fontSize: 22,
      height: 1.25,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.3,
      color: ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.45,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.45,
      color: VitaliaPalette.inkSoft,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.2,
      color: ink,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.8,
      color: sage,
    ),
  );

  const scheme = ColorScheme.light(
    primary: sage,
    onPrimary: paper,
    secondary: sage,
    onSecondary: paper,
    surface: paper,
    onSurface: ink,
    error: Color(0xFF9B4030),
    onError: paper,
    outline: VitaliaPalette.line,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: paper,
    canvasColor: paper,
    textTheme: textTheme,
    fontFamily: 'Outfit',
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Fraunces',
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: paper,
      elevation: 0,
      height: 72,
      indicatorColor: VitaliaPalette.sageMist,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Outfit',
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12,
          color: selected ? sage : VitaliaPalette.inkSoft,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? sage : VitaliaPalette.inkSoft,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VitaliaPalette.paperDeep,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: sage, width: 1.4),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Outfit',
        color: VitaliaPalette.inkSoft,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return paper;
        return VitaliaPalette.inkSoft;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return sage;
        return VitaliaPalette.line;
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: sage,
        foregroundColor: paper,
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: sage,
        side: const BorderSide(color: sage),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: sage,
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      titleTextStyle: const TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 15,
        color: VitaliaPalette.inkSoft,
        height: 1.4,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: sage,
      contentTextStyle: const TextStyle(fontFamily: 'Outfit', color: paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: paper,
      dialHandColor: sage,
      hourMinuteTextColor: ink,
      dayPeriodColor: VitaliaPalette.sageMist,
    ),
  );
}
