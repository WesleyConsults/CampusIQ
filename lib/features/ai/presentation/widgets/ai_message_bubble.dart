import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:intl/intl.dart';

// ── Inline math: $...$ ───────────────────────────────────────────────────────

class _InlineMathSyntax extends md.InlineSyntax {
  _InlineMathSyntax() : super(r'\$(?!\$)([^\$\n]+?)\$(?!\$)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('inlinemath', match[1]!.trim()));
    return true;
  }
}

class _InlineMathBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => false;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return _buildMath(element.textContent, display: false);
  }
}

// ── Display (block) math: $$ ... $$ ─────────────────────────────────────────

// Single-line $$...$$ handled as inline syntax
class _DisplayMathInlineSyntax extends md.InlineSyntax {
  _DisplayMathInlineSyntax() : super(r'\$\$(.+?)\$\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('displaymath', match[1]!.trim()));
    return true;
  }
}

// Multi-line fenced $$\n...\n$$ handled as block syntax
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

// MUST declare isBlockElement = true so flutter_markdown treats displaymath
// as a block node — otherwise it crashes accessing _inlines.last on an empty list.
class _DisplayMathBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildMath(element.textContent, display: true),
    );
  }
}

// ── Shared math renderer ─────────────────────────────────────────────────────

Widget _buildMath(String tex, {required bool display}) {
  return Math.tex(
    tex,
    mathStyle: display ? MathStyle.display : MathStyle.text,
    textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
    onErrorFallback: (_) => Text(
      tex,
      style: const TextStyle(
          fontFamily: 'monospace', fontSize: 13, color: Colors.black54),
    ),
  );
}

// ── Message bubble ───────────────────────────────────────────────────────────

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
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ).copyWith(
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
                        'inlinemath': _InlineMathBuilder(),
                        'displaymath': _DisplayMathBuilder(),
                      },
                      extensionSet: md.ExtensionSet(
                        [
                          _DisplayMathBlockSyntax(),
                          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        ],
                        [
                          _DisplayMathInlineSyntax(),
                          _InlineMathSyntax(),
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
