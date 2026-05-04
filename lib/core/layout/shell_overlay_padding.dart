import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

double shellOverlayBottomPadding(
  BuildContext context, {
  required bool hasActiveSession,
  double extraSpacing = AppSpacing.sm,
}) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  const navHeight = AppSpacing.navHeight;
  const navBottomMargin = AppSpacing.navBottomMargin;
  const aiFabSize = AppSpacing.fabSize;
  const timerEstimatedHeight = AppSpacing.timerHeight;
  const timerGap = AppSpacing.timerGap;

  final navReserve = bottomInset + navBottomMargin + navHeight;
  final aiReserve = navReserve + AppSpacing.md + aiFabSize;
  final timerReserve = hasActiveSession
      ? navReserve + AppSpacing.md + timerGap + timerEstimatedHeight
      : 0.0;

  return math.max(aiReserve, timerReserve) + extraSpacing;
}
