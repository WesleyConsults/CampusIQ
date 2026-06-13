import 'package:flutter/material.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class ImportOptionGridItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ImportOptionGridItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class ImportOptionGrid extends StatelessWidget {
  final List<ImportOptionGridItem> options;

  const ImportOptionGrid({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        mainAxisExtent: 120,
      ),
      itemBuilder: (context, index) => _ImportOptionBox(option: options[index]),
    );
  }
}

class _ImportOptionBox extends StatelessWidget {
  final ImportOptionGridItem option;

  const _ImportOptionBox({required this.option});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: option.onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadii.button,
                ),
                child: Icon(
                  option.icon,
                  color: colorScheme.primary,
                  size: AppIconSizes.xxl,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
