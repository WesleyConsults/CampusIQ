import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';

class AiChatHistoryDrawer extends ConsumerWidget {
  const AiChatHistoryDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);

    return Drawer(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(aiChatProvider.notifier).createNewChat();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: chatState.sessions.isEmpty
                ? const Center(child: Text('No previous chats.'))
                : ListView.builder(
                    itemCount: chatState.sessions.length,
                    itemBuilder: (context, index) {
                      final session = chatState.sessions[index];
                      final isSelected =
                          session.id == chatState.currentSessionId;

                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          session.title.isNotEmpty ? session.title : 'New Chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (!isSelected) {
                            ref
                                .read(aiChatProvider.notifier)
                                .switchSession(session.id);
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Chat'),
                                content: const Text(
                                    'Are you sure you want to delete this chat history?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              ref
                                  .read(aiChatProvider.notifier)
                                  .deleteSession(session.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
