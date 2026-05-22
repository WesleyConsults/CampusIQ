import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/domain/university_defaults.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingUniversityScreen extends ConsumerStatefulWidget {
  const OnboardingUniversityScreen({super.key});

  @override
  ConsumerState<OnboardingUniversityScreen> createState() =>
      _OnboardingUniversityScreenState();
}

class _OnboardingUniversityScreenState
    extends ConsumerState<OnboardingUniversityScreen> {
  final _searchController = TextEditingController();
  final _programmeController = TextEditingController();
  String _query = '';

  List<University> get _filtered {
    if (_query.trim().isEmpty) return universityPickerOptions;
    final q = _query.toLowerCase().trim();
    return universityPickerOptions.where((u) {
      return u.name.toLowerCase().contains(q) ||
          (u.shortName?.toLowerCase().contains(q) ?? false) ||
          (u.location?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  String _systemSummary(String gradingSystemId) {
    final gs = GradingSystem.byId(gradingSystemId);
    return '${gs.plannerTitle} · ${gs.minScore.toStringAsFixed(0)}-${gs.maxScore.toStringAsFixed(0)}${gs.scoreUnit == '%' ? '%' : ' pts'}';
  }

  Widget _universityLogo(
    BuildContext context,
    University university, {
    required bool isSelected,
    required bool isOther,
  }) {
    const logoSize = 48.0;
    final colorScheme = Theme.of(context).colorScheme;
    final hasLogo = university.logoAssetPath != null;
    final backgroundColor = isOther
        ? colorScheme.outlineVariant.withValues(alpha: 0.55)
        : university.logoNeedsDarkBackground
            ? AppColors.navy
            : colorScheme.surface;

    Widget fallbackIcon() {
      return Icon(
        isOther ? LucideIcons.ellipsis : LucideIcons.building,
        color: isOther ? colorScheme.onSurfaceVariant : colorScheme.primary,
        size: AppIconSizes.xxl,
      );
    }

    return Container(
      width: logoSize,
      height: logoSize,
      padding: EdgeInsets.all(hasLogo ? AppSpacing.xxs2 : 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Center(
        child: hasLogo
            ? Image.asset(
                university.logoAssetPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallbackIcon(),
              )
            : fallbackIcon(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _programmeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    if (_programmeController.text != state.programme) {
      _programmeController.value = TextEditingValue(
        text: state.programme,
        selection: TextSelection.collapsed(offset: state.programme.length),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(currentStep: state.step),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        ref.read(onboardingProvider.notifier).goBack(),
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Where do you study?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding:
                    const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.xs),
                child: Text(
                  'We\'ll set your grading system automatically. Programme is optional.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.university != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.circleCheck,
                        color: colorScheme.primary,
                        size: AppIconSizes.xl,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${state.university!.shortName ?? state.university!.name} · ${state.gradingSystem.plannerTitle}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              TextField(
                controller: _programmeController,
                onChanged: (v) =>
                    ref.read(onboardingProvider.notifier).setProgramme(v),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Programme (optional)',
                  hintText: 'e.g. Computer Science',
                  prefixIcon: const Icon(LucideIcons.bookOpen),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search universities...',
                  prefixIcon: const Icon(LucideIcons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    final uni = _filtered[index];
                    final isSelected = state.university?.name == uni.name;
                    final isOther = uni.name == 'Other';

                    return ListTile(
                      leading: _universityLogo(
                        context,
                        uni,
                        isSelected: isSelected,
                        isOther: isOther,
                      ),
                      title: Text(
                        uni.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        isOther
                            ? 'My university isn\'t listed'
                            : [
                                if (uni.shortName != null) uni.shortName!,
                                if (uni.location != null) uni.location!,
                                _systemSummary(uni.gradingSystemId),
                              ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(LucideIcons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setUniversity(uni);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: state.canAdvance
                      ? () => ref.read(onboardingProvider.notifier).goNext()
                      : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
