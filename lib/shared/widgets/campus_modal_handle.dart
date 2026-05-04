import 'package:flutter/material.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class CampusModalHandle extends StatelessWidget {
  const CampusModalHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: AppRadii.pill,
        ),
      ),
    );
  }
}
