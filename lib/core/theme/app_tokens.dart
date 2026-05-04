import 'package:flutter/material.dart';

/// ─── SCALE KNOBS ───────────────────────────────────────────────────────────────
/// Changing the raw values below scales the entire app uniformly.
/// Every UI dimension in the codebase should route through one of these token
/// classes — never a raw number literal.
///
/// Spacing:  xxxs(2), xxs(4), xxs2(6), xs(8), xs2(10), sm(12), sm2(14), md(16), lg(20), xl(24), xxl(32), xxxl(40)
/// Radii:    xxxs(2), xs(4), xxs(6), xs2(10), sm(12), sm2(14), md(18), md2(20), lg(24), xl(28), pill(999)
/// Icons:    xs(12), sm(14), md(16), lg(18), xl(20), xxl(22), xxxl(24), hero(32), status(36), alert(48), error(56)
/// Shell:    navHeight(72), navBottomMargin(14), navHorizontalMargin(18), timerHeight(64), timerGap(12), fabSize(58)
/// Fonts:    defined in app_theme.dart textTheme (11, 12, 13, 14, 15, 16, 18, 20, 28, 32)
///
/// ─── EXCEPTION POLICY ──────────────────────────────────────────────────────────
/// These are ALLOWED to stay as raw values outside of token files:
///   • 999 pill radius (already covered by AppRadii.pill)
///   • animation durations
///   • one-off chart math / custom paint coordinates
///   • tiny edge-case values: 0, 0.5, 1, hairline borders
///   • rare component-specific dimensions with no repeated use
///
/// Everything else — padding, gaps, common icon sizes, common radii, common text
/// sizes, repeated heights/widths — MUST use a token.
///
/// ─── SCALE PROFILES ────────────────────────────────────────────────────────────
/// Three conceptual profiles. Switch between them by changing the raw values.
///
///   compact     — ~80% of default   (dense, data-heavy, smaller device)
///   default     — current scale
///   comfortable — ~120% of default  (relaxed, accessible, larger device)
///
/// Only the spacing scale, type scale, icon scale, and selected component heights
/// change across profiles. Animation durations and border radii stay fixed unless
/// a specific radius looks wrong at the new scale.
///
/// ─── SAFETY FLOORS ─────────────────────────────────────────────────────────────
/// Hard limits that prevent scaling from producing unreadable text or unusable
/// controls. These are design constraints, not suggestions.
///
///   • Minimum readable body text:  10 px (WCAG-adjacent for mobile)
///   • Minimum caption / micro text:  8 px (badges, chart labels only)
///   • Minimum tap target:          40×40 px (platform HIG minimum)
///   • Minimum chip / control height: 28 px
///   • Minimum nav icon size:       18 px
///   • Minimum action icon size:    16 px
///
/// Tokens that scale freely:     AppSpacing, AppRadii, AppIconSizes raw scale,
///                               theme font sizes
/// Tokens protected by floors:   AppComponentSizes (chip, nav, fab, timer)
///                               AppIconSizes.nav, .fab, .chip

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
  // Raw scale
  static const double xxxs = 2;
  static const double xxs = 4;
  static const double xxs2 = 6;
  static const double xs = 8;
  static const double xs2 = 10;
  static const double sm = 12;
  static const double sm2 = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  // Shell layout
  static const double navHeight = 72;
  static const double navBottomMargin = 14;
  static const double navHorizontalMargin = 18;
  static const double timerHeight = 64;
  static const double timerGap = 12;
  static const double fabSize = 58;

  // Convenience EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(lg);
}

/// Semantic layout tokens — prefer these over raw AppSpacing values in screens.
class AppLayout {
  // Screen structure
  static const double screenGutter = AppSpacing.xl;    // 24
  static const double sectionGap = AppSpacing.lg;      // 20
  static const double cardGap = AppSpacing.md;         // 16
  static const double compactGap = AppSpacing.sm;      // 12
  static const double inlineGap = AppSpacing.xs;       // 8

  // Convenience paddings
  static const EdgeInsets screenPadding = AppSpacing.screenPadding;
  static const EdgeInsets cardPadding = AppSpacing.cardPadding;
}

/// Component-level dimensions. Shared sizes for repeated UI elements.
class AppComponentSizes {
  // Shell (aliased from AppSpacing for discoverability)
  static const double navHeight = AppSpacing.navHeight;
  static const double fabSize = AppSpacing.fabSize;
  static const double timerHeight = AppSpacing.timerHeight;

  // Chips
  static const double chipHeight = 32;
  static const double chipCompactHeight = 28;

  // Step / stepper buttons
  static const double stepButtonSize = 28;
}

class AppRadii {
  static const double xxxs = 2;
  static const double xs = 4;
  static const double xxs = 6;
  static const double xs2 = 10;
  static const double sm = 12;
  static const double sm2 = 14;
  static const double md = 18;
  static const double md2 = 20;
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

class AppIconSizes {
  // Raw scale
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 22;
  static const double xxxl = 24;
  static const double hero = 32;
  static const double status = 36;
  static const double alert = 48;
  static const double error = 56;

  // Semantic aliases — prefer these in widget code
  static const double chip = md;       // 16 — chip trailing icons
  static const double list = lg;       // 18 — list tile chevrons / leading
  static const double nav = xl;        // 20 — bottom nav destinations
  static const double appBar = xxl;    // 22 — app bar actions
  static const double feature = xxxl;  // 24 — feature cards, option tiles
  static const double fab = lg;        // 18 — floating action button
}

/// Hard safety limits. Scaling must not push values below these floors.
/// Referenced by layout code to clamp computed sizes.
class AppFloors {
  AppFloors._();

  // Text readability
  static const double minBodyFontSize = 10;
  static const double minCaptionFontSize = 8;

  // Touch / interaction
  static const double minTapTarget = 40;
  static const double minChipHeight = 28;
  static const double minControlHeight = 28;

  // Icons
  static const double minNavIconSize = 18;
  static const double minActionIconSize = 16;
}
