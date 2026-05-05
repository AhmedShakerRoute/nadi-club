import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const gold     = Color(0xFFC9A84C);
  static const goldL    = Color(0xFFE8C87A);
  static const ok       = Color(0xFF27AE60);
  static const err      = Color(0xFFE74C3C);
  static const warn     = Color(0xFFF39C12);
  static const info     = Color(0xFF2980B9);
  static const pending  = Color(0xFFE67E22);
  // Dark
  static const dBg   = Color(0xFF07101E);
  static const dSurf = Color(0xFF0C1929);
  static const dCard = Color(0xFF112038);
  static const dBdr  = Color(0xFF1B3050);
  static const dTx   = Color(0xFFEDE8DC);
  static const dMu   = Color(0xFF7A9BBF);
  // Light
  static const lBg   = Color(0xFFF0F4F8);
  static const lSurf = Color(0xFFFFFFFF);
  static const lCard = Color(0xFFFFFFFF);
  static const lBdr  = Color(0xFFDDE3EE);
  static const lTx   = Color(0xFF1A202C);
  static const lMu   = Color(0xFF718096);
}

TextTheme _tt(Color c) => GoogleFonts.tajawalTextTheme().apply(bodyColor: c, displayColor: c);

OutlineInputBorder _ib(Color bc, [double w = 1]) =>
    OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bc, width: w));

ElevatedButtonThemeData _eb(Color fg) => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: C.gold, foregroundColor: fg,
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 16),
    elevation: 2,
  ),
);

ThemeData darkTheme() => ThemeData(
  useMaterial3: true, brightness: Brightness.dark,
  scaffoldBackgroundColor: C.dBg,
  textTheme: _tt(C.dTx),
  colorScheme: const ColorScheme.dark(primary: C.gold, secondary: C.goldL, surface: C.dCard, error: C.err),
  appBarTheme: AppBarTheme(backgroundColor: C.dSurf, elevation: 0, titleTextStyle: GoogleFonts.tajawal(color: C.gold, fontSize: 19, fontWeight: FontWeight.w700), iconTheme: const IconThemeData(color: C.dTx)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: C.dSurf, selectedItemColor: C.gold, unselectedItemColor: C.dMu, type: BottomNavigationBarType.fixed, elevation: 0),
  cardTheme: CardThemeData(color: C.dCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.dBdr, width: .8))),
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: C.dSurf, border: _ib(C.dBdr), enabledBorder: _ib(C.dBdr), focusedBorder: _ib(C.gold, 2), labelStyle: const TextStyle(color: C.dMu), hintStyle: const TextStyle(color: C.dMu)),
  elevatedButtonTheme: _eb(C.dBg), dividerColor: C.dBdr,
  switchTheme: const SwitchThemeData(thumbColor: WidgetStatePropertyAll(C.gold), trackColor: WidgetStatePropertyAll(Color(0xFF3A2A00))),
);

ThemeData lightTheme() => ThemeData(
  useMaterial3: true, brightness: Brightness.light,
  scaffoldBackgroundColor: C.lBg,
  textTheme: _tt(C.lTx),
  colorScheme: const ColorScheme.light(primary: C.gold, secondary: C.goldL, surface: C.lCard, error: C.err),
  appBarTheme: AppBarTheme(backgroundColor: C.lSurf, elevation: 0, shadowColor: C.lBdr, titleTextStyle: GoogleFonts.tajawal(color: C.gold, fontSize: 19, fontWeight: FontWeight.w700), iconTheme: const IconThemeData(color: C.lTx)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: C.lSurf, selectedItemColor: C.gold, unselectedItemColor: C.lMu, type: BottomNavigationBarType.fixed, elevation: 8),
  cardTheme: CardThemeData(color: C.lCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.lBdr, width: .8))),
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: C.lBg, border: _ib(C.lBdr), enabledBorder: _ib(C.lBdr), focusedBorder: _ib(C.gold, 2), labelStyle: const TextStyle(color: C.lMu), hintStyle: const TextStyle(color: C.lMu)),
  elevatedButtonTheme: _eb(Colors.white), dividerColor: C.lBdr,
  switchTheme: const SwitchThemeData(thumbColor: WidgetStatePropertyAll(C.gold), trackColor: WidgetStatePropertyAll(Color(0xFFEED98A))),
);
