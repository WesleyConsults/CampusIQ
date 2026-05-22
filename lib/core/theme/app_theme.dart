import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_tokens.dart';

class AppTheme {
  static const Color primary = AppColors.navy;
  static const Color accent = AppColors.gold;
  static const Color surface = AppColors.background;
  static const Color cardBg = AppColors.surface;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color border = AppColors.border;

  static InputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadii.button,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.15,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.25,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.2,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.35,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: primary,
      error: warning,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      primaryContainer: Color(0xFFE6EBF5),
      onPrimaryContainer: primary,
      secondaryContainer: AppColors.goldSoft,
      onSecondaryContainer: primary,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE6ECF4),
      onTertiaryContainer: textPrimary,
      surfaceContainerHighest: AppColors.surfaceMuted,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadow,
      scrim: Color(0x660E1A2B),
      inverseSurface: primary,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFFB8C7E3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      cardColor: cardBg,
      textTheme: baseTextTheme,
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 20,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseTextTheme.titleLarge,
        iconTheme:
            const IconThemeData(color: textPrimary, size: AppIconSizes.xxl),
      ),
      cardTheme: const CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      dividerColor: AppColors.divider,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        iconColor: textSecondary,
        textColor: textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary.withValues(alpha: 0.8),
        ),
        border: _inputBorder(border),
        enabledBorder: _inputBorder(border),
        focusedBorder: _inputBorder(primary, width: 1.4),
        errorBorder: _inputBorder(warning),
        focusedErrorBorder: _inputBorder(warning, width: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
          textStyle: baseTextTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: primary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.goldSoft,
        disabledColor: AppColors.divider,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: baseTextTheme.labelMedium!,
        secondaryLabelStyle: baseTextTheme.labelMedium!,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      extensions: const [
        AppLucideTheme(
          home: LucideIcons.house,
          homeFilled: LucideIcons.house,
          analytics: LucideIcons.chartColumn,
          analyticsFilled: LucideIcons.chartColumn,
          timetable: LucideIcons.calendarDays,
          timetableFilled: LucideIcons.calendarDays,
          sessions: LucideIcons.timer,
          sessionsFilled: LucideIcons.timer,
          ai: LucideIcons.sparkles,
        ),
      ],
    );
  }

  // ── Dark palette ─────────────────────────────────────────────────────────

  static const Color _darkPrimary = Color(0xFF7B9AD4);
  static const Color _darkSurface = Color(0xFF1E2030);
  static const Color _darkBackground = Color(0xFF15171E);
  static const Color _darkSurfaceMuted = Color(0xFF262835);
  static const Color _darkTextPrimary = Color(0xFFEDEEF2);
  static const Color _darkTextSecondary = Color(0xFF9BA0B0);
  static const Color _darkBorder = Color(0xFF323540);
  static const Color _darkDivider = Color(0xFF2B2E38);
  static const Color _darkGold = Color(0xFFD4B55C);
  static const Color _darkGoldSoft = Color(0xFF3D3520);
  static const Color _darkWarning = Color(0xFFE07B5F);
  static const Color _darkInfo = Color(0xFF8CA0BC);

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _darkTextPrimary,
        height: 1.15,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _darkTextPrimary,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _darkTextPrimary,
        height: 1.25,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _darkTextPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _darkTextSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _darkPrimary,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _darkTextSecondary,
        height: 1.2,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _darkTextSecondary,
        height: 1.35,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
        height: 1.3,
      ),
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Color(0xFF14213D),
      secondary: _darkGold,
      onSecondary: Color(0xFF14213D),
      error: _darkWarning,
      onError: Color(0xFF1A1A1A),
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      primaryContainer: Color(0xFF2A3A5C),
      onPrimaryContainer: Color(0xFFD0D9F0),
      secondaryContainer: _darkGoldSoft,
      onSecondaryContainer: _darkGold,
      tertiary: _darkInfo,
      onTertiary: Color(0xFF1A1A1A),
      tertiaryContainer: Color(0xFF2A3345),
      onTertiaryContainer: _darkTextPrimary,
      surfaceContainerHighest: _darkSurfaceMuted,
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkBorder,
      outlineVariant: _darkDivider,
      shadow: Color(0x1A000000),
      scrim: Color(0x99000000),
      inverseSurface: _darkTextPrimary,
      onInverseSurface: Color(0xFF14213D),
      inversePrimary: Color(0xFF14213D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      canvasColor: _darkBackground,
      cardColor: _darkSurface,
      textTheme: baseTextTheme,
      iconTheme: const IconThemeData(
        color: _darkTextSecondary,
        size: 20,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseTextTheme.titleLarge,
        iconTheme: const IconThemeData(
            color: _darkTextPrimary, size: AppIconSizes.xxl),
      ),
      cardTheme: const CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      dividerColor: _darkDivider,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        iconColor: _darkTextSecondary,
        textColor: _darkTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: _darkTextSecondary.withValues(alpha: 0.8),
        ),
        border: _inputBorder(_darkBorder),
        enabledBorder: _inputBorder(_darkBorder),
        focusedBorder: _inputBorder(_darkPrimary, width: 1.4),
        errorBorder: _inputBorder(_darkWarning),
        focusedErrorBorder: _inputBorder(_darkWarning, width: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: _darkPrimary,
          foregroundColor: const Color(0xFF14213D),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
          textStyle: baseTextTheme.labelLarge
              ?.copyWith(color: const Color(0xFF14213D)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkBorder),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceMuted,
        selectedColor: _darkGoldSoft,
        disabledColor: _darkDivider,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: baseTextTheme.labelMedium!,
        secondaryLabelStyle: baseTextTheme.labelMedium!,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurface,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: _darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkGold,
        foregroundColor: Color(0xFF14213D),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      extensions: const [
        AppLucideTheme(
          home: LucideIcons.house,
          homeFilled: LucideIcons.house,
          analytics: LucideIcons.chartColumn,
          analyticsFilled: LucideIcons.chartColumn,
          timetable: LucideIcons.calendarDays,
          timetableFilled: LucideIcons.calendarDays,
          sessions: LucideIcons.timer,
          sessionsFilled: LucideIcons.timer,
          ai: LucideIcons.sparkles,
        ),
      ],
    );
  }
}

@immutable
class AppLucideTheme extends ThemeExtension<AppLucideTheme> {
  final IconData home;
  final IconData homeFilled;
  final IconData analytics;
  final IconData analyticsFilled;
  final IconData timetable;
  final IconData timetableFilled;
  final IconData sessions;
  final IconData sessionsFilled;
  final IconData ai;

  const AppLucideTheme({
    required this.home,
    required this.homeFilled,
    required this.analytics,
    required this.analyticsFilled,
    required this.timetable,
    required this.timetableFilled,
    required this.sessions,
    required this.sessionsFilled,
    required this.ai,
  });

  @override
  ThemeExtension<AppLucideTheme> copyWith({
    IconData? home,
    IconData? homeFilled,
    IconData? analytics,
    IconData? analyticsFilled,
    IconData? timetable,
    IconData? timetableFilled,
    IconData? sessions,
    IconData? sessionsFilled,
    IconData? ai,
  }) {
    return AppLucideTheme(
      home: home ?? this.home,
      homeFilled: homeFilled ?? this.homeFilled,
      analytics: analytics ?? this.analytics,
      analyticsFilled: analyticsFilled ?? this.analyticsFilled,
      timetable: timetable ?? this.timetable,
      timetableFilled: timetableFilled ?? this.timetableFilled,
      sessions: sessions ?? this.sessions,
      sessionsFilled: sessionsFilled ?? this.sessionsFilled,
      ai: ai ?? this.ai,
    );
  }

  @override
  ThemeExtension<AppLucideTheme> lerp(
    covariant ThemeExtension<AppLucideTheme>? other,
    double t,
  ) {
    return this;
  }
}
