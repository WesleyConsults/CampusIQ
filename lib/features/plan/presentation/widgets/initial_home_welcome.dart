import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InitialHomeWelcome extends StatefulWidget {
  final double bottomPadding;
  final bool animateEntrance;
  final VoidCallback onGetStarted;
  final VoidCallback onCalculateCwa;
  final VoidCallback onFocusSession;
  final VoidCallback onExploreTimetable;

  const InitialHomeWelcome({
    super.key,
    required this.bottomPadding,
    required this.animateEntrance,
    required this.onGetStarted,
    required this.onCalculateCwa,
    required this.onFocusSession,
    required this.onExploreTimetable,
  });

  @override
  State<InitialHomeWelcome> createState() => _InitialHomeWelcomeState();
}

class _InitialHomeWelcomeState extends State<InitialHomeWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: widget.animateEntrance ? 0 : 1,
    );
    if (widget.animateEntrance) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animation = disableAnimations
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    return CustomScrollView(
      key: const ValueKey('initial-home-welcome'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _Entrance(
                animation: animation,
                interval: const Interval(0, 0.58),
                child: _WelcomeHeroCard(
                  onGetStarted: widget.onGetStarted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Entrance(
                animation: animation,
                interval: const Interval(0.34, 1),
                child: _HomeQuickActions(
                  onCalculateCwa: widget.onCalculateCwa,
                  onFocusSession: widget.onFocusSession,
                  onExploreTimetable: widget.onExploreTimetable,
                ),
              ),
              SizedBox(height: widget.bottomPadding),
            ],
          ),
        ),
      ],
    );
  }
}

class _Entrance extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const _Entrance({
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _WelcomeHeroCard({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Welcome to UniMate',
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.xl)),
          gradient: LinearGradient(
            colors: [Color(0xFF091A36), Color(0xFF12376B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(
              top: 42,
              right: 34,
              child: _HeroAccentDots(),
            ),
            Positioned(
              right: -24,
              bottom: -8,
              child: Icon(
                LucideIcons.sparkles,
                size: 150,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 320;
                  final imageWidth = compact ? 120.0 : 154.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to UniMate',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Your academic companion for this semester.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    height: 1.42,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ExcludeSemantics(
                            child: Image.asset(
                              'assets/images/unimate_welcome_student.png',
                              width: imageWidth,
                              fit: BoxFit.contain,
                              errorBuilder: (context, _, __) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        key: const ValueKey('initial-home-get-started'),
                        onPressed: onGetStarted,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(LucideIcons.arrowRight),
                        label: const Text('Get Started'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.navy,
                          minimumSize: Size(
                            compact ? double.infinity : 168,
                            52,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadii.pill,
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAccentDots extends StatelessWidget {
  const _HeroAccentDots();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (var index = 0; index < 9; index++)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
      ],
    );
  }
}

class _HomeQuickActions extends StatelessWidget {
  final VoidCallback onCalculateCwa;
  final VoidCallback onFocusSession;
  final VoidCallback onExploreTimetable;

  const _HomeQuickActions({
    required this.onCalculateCwa,
    required this.onFocusSession,
    required this.onExploreTimetable,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _QuickActionData(
        title: 'Calculate CWA',
        icon: LucideIcons.calculator,
        color: AppColors.success,
        onTap: onCalculateCwa,
      ),
      _QuickActionData(
        title: 'Focus Session',
        icon: LucideIcons.timer,
        color: const Color(0xFF6757D8),
        onTap: onFocusSession,
      ),
      _QuickActionData(
        title: 'Explore Timetable',
        icon: LucideIcons.calendarDays,
        color: AppColors.gold,
        onTap: onExploreTimetable,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Everything you need, right at your fingertips.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < cards.length; i++)
                  SizedBox(
                    width: i == cards.length - 1
                        ? constraints.maxWidth
                        : cardWidth,
                    height: i == cards.length - 1 ? 112 : 200,
                    child: _HomeQuickActionCard(
                      data: cards[i],
                      isWide: i == cards.length - 1,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _HomeQuickActionCard extends StatelessWidget {
  final _QuickActionData data;
  final bool isWide;

  const _HomeQuickActionCard({
    required this.data,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tintedSurface = Color.alphaBlend(
      data.color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.14 : 0.08),
      colorScheme.surface,
    );
    final iconBackground = Color.alphaBlend(
      data.color.withValues(alpha: 0.92),
      colorScheme.surface,
    );

    return Container(
      decoration: BoxDecoration(
        color: tintedSurface,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: data.color.withValues(alpha: 0.16),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: isWide
                ? Row(
                    children: [
                      _QuickActionIcon(
                        icon: data.icon,
                        color: iconBackground,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _QuickActionTitle(data: data)),
                      const SizedBox(width: AppSpacing.xs),
                      _QuickActionArrow(color: data.color),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickActionIcon(
                        icon: data.icon,
                        color: iconBackground,
                      ),
                      const Spacer(),
                      _QuickActionTitle(data: data),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _QuickActionArrow(color: data.color),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _QuickActionIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: AppIconSizes.xxl,
      ),
    );
  }
}

class _QuickActionTitle extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionTitle({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      data.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        height: 1.16,
      ),
    );
  }
}

class _QuickActionArrow extends StatelessWidget {
  final Color color;

  const _QuickActionArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(
        LucideIcons.arrowRight,
        color: color,
        size: AppIconSizes.xxl,
      ),
    );
  }
}
