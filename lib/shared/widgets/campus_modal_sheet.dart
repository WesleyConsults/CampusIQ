import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/shared/widgets/campus_modal_handle.dart';
import 'package:campusiq/shared/widgets/campus_modal_header.dart';

class CampusModalSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottomBar;
  final EdgeInsetsGeometry? padding;
  final bool showHandle;
  final bool scrollable;
  final bool expandBody;
  final bool dismissOnBackdropTap;
  final double maxHeightFactor;

  const CampusModalSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottomBar,
    this.padding,
    this.showHandle = true,
    this.scrollable = false,
    this.expandBody = false,
    this.dismissOnBackdropTap = false,
    this.maxHeightFactor = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomSafeArea = mediaQuery.padding.bottom;
    final resolvedPadding = padding?.resolve(Directionality.of(context)) ??
        const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
        );

    final body = _buildBody();
    final isFlexibleLayout = scrollable || expandBody;

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final sheet = Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * maxHeightFactor,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.bottomSheetTheme.backgroundColor ??
                      theme.colorScheme.surface,
                  borderRadius: AppRadii.sheet,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.colorScheme.brightness == Brightness.dark
                            ? 0.30
                            : 0.07,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      resolvedPadding.left,
                      resolvedPadding.top,
                      resolvedPadding.right,
                      resolvedPadding.bottom +
                          math.max(bottomSafeArea, AppSpacing.xs),
                    ),
                    child: Column(
                      mainAxisSize: isFlexibleLayout
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHandle) ...[
                          const CampusModalHandle(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (title != null ||
                            subtitle != null ||
                            leading != null ||
                            trailing != null) ...[
                          CampusModalHeader(
                            title: title ?? '',
                            subtitle: subtitle,
                            leading: leading,
                            trailing: trailing,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        body,
                        if (bottomBar != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          bottomBar!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        return AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: dismissOnBackdropTap
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: sheet,
                )
              : sheet,
        );
      },
    );
  }

  Widget _buildBody() {
    if (scrollable) {
      return Expanded(
        child: SingleChildScrollView(
          child: child,
        ),
      );
    }

    if (expandBody) {
      return Expanded(child: child);
    }

    return child;
  }
}
