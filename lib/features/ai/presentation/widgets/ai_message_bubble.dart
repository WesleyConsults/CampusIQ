import 'package:flutter/material.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:intl/intl.dart';

class AiMessageBubble extends StatelessWidget {
  final AiMessageModel message;

  const AiMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: !isUser
                    ? Border.all(color: Colors.grey.shade300, width: 1)
                    : null,
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
