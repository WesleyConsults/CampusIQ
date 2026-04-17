import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:intl/intl.dart';

// Matches $$...$$ (display) OR $...$ (inline), single-line only.
// Multi-line display math is handled by _DisplayMathBlockSyntax below.
class _MathInlineSyntax extends md.InlineSyntax {
  _MathInlineSyntax() : super(r'\$\$(.+?)\$\$|\$([^\$\n]+?)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final isDisplay = match[1] != null;
    final tex = (match[1] ?? match[2])!.trim();
    parser.addNode(md.Element.text(isDisplay ? 'displaymath' : 'inlinemath', tex));
    return true;
  }
}

// Handles fenced display math:
//   $$
//   \begin{pmatrix}...\end{pmatrix}
//   $$
class _DisplayMathBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\$\$\s*$');

  @override
  md.Node? parse(md.BlockParser parser) {
    final lines = <String>[];
    parser.advance(); // skip opening $$
    while (!parser.isDone) {
      final line = parser.current.content;
      if (line.trim() == r'$$') {
        parser.advance(); // skip closing $$
        break;
      }
      lines.add(line);
      parser.advance();
    }
    return md.Element.text('displaymath', lines.join('\n').trim());
  }
}

class _MathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final isDisplay = element.tag == 'displaymath';
    final tex = element.textContent;
    return Padding(
      padding: isDisplay
          ? const EdgeInsets.symmetric(vertical: 6)
          : EdgeInsets.zero,
      child: Math.tex(
        tex,
        mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
        textStyle: (preferredStyle ?? const TextStyle(fontSize: 14))
            .copyWith(color: Colors.black87),
        onErrorFallback: (_) => SelectableText(
          tex,
          style: const TextStyle(
              fontFamily: 'monospace', fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}

class AiMessageBubble extends StatelessWidget {
  final AiMessageModel message;

  const AiMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: !isUser
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: Colors.black87, fontSize: 14, height: 1.4),
                        strong: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        em: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                        listBullet: const TextStyle(
                            color: Colors.black87, fontSize: 14),
                        code: TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                          backgroundColor: Colors.grey.shade100,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      builders: {
                        'inlinemath': _MathBuilder(),
                        'displaymath': _MathBuilder(),
                      },
                      extensionSet: md.ExtensionSet(
                        [
                          _DisplayMathBlockSyntax(),
                          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        ],
                        [
                          _MathInlineSyntax(),
                          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
