import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

double shellOverlayBottomPadding(
  BuildContext context, {
  required bool hasActiveSession,
  double extraSpacing = AppSpacing.sm,
}) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  const navHeight = 72.0;
  const navBottomMargin = 14.0;
  const aiFabSize = 58.0;
  const timerEstimatedHeight = 64.0;
  const timerGap = 12.0;

  final navReserve = bottomInset + navBottomMargin + navHeight;
  final aiReserve = navReserve + AppSpacing.md + aiFabSize;
  final timerReserve = hasActiveSession
      ? navReserve + AppSpacing.md + timerGap + timerEstimatedHeight
      : 0.0;

  return math.max(aiReserve, timerReserve) + extraSpacing;
}
