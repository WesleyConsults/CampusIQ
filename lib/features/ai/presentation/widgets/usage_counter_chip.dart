import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UsageCounterChip extends StatelessWidget {
  final int remaining;
  final int limit;

  const UsageCounterChip({
    required this.remaining,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return const SizedBox.shrink();
    Color chipColor;
    String label;

    if (remaining > 1) {
      chipColor = Colors.green;
      label = '$remaining messages left today';
    } else if (remaining == 1) {
      chipColor = Colors.amber;
      label = '1 message left today';
    } else {
      chipColor = Colors.red;
      label = '0 messages left — upgrade for unlimited';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: remaining == 0
          ? GestureDetector(
              onTap: () => context.push('/subscribe'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.1),
                border: Border.all(color: chipColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(color: chipColor, fontSize: 12),
              ),
            ),
    );
  }
}
