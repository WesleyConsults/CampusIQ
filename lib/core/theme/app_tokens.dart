import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF14213D);
  static const Color navySoft = Color(0xFF24385B);
  static const Color gold = Color(0xFFC7A44B);
  static const Color goldSoft = Color(0xFFF3E7BF);
  static const Color background = Color(0xFFF6F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFBF9F4);
  static const Color border = Color(0xFFE8E2D8);
  static const Color divider = Color(0xFFF0EBE2);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF6C7486);
  static const Color success = Color(0xFF2F8F6B);
  static const Color warning = Color(0xFFD2674A);
  static const Color info = Color(0xFF7288A8);
  static const Color shadow = Color(0x120E1A2B);
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(lg);
}

class AppRadii {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 28;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];
}
