import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';

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

// ── Shared math renderer ─────────────────────────────────────────────────────

Widget _buildMath(String tex, {required bool display}) {
  return Math.tex(
    tex,
    mathStyle: display ? MathStyle.display : MathStyle.text,
    textStyle: const TextStyle(
      fontSize: 14,
      color: AppTheme.textPrimary,
      inherit: false,
    ),
    onErrorFallback: (_) => Text(
      tex,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: AppTheme.textSecondary,
      ),
    ),
  );
}

// ── Display-math pre-processor ───────────────────────────────────────────────
// Split the message text on $$...$$ BEFORE handing anything to MarkdownBody.
// This keeps 'displaymath' entirely out of flutter_markdown's tag machinery,
// which avoids the styleSheet.styles['displaymath'] == null crash at builder:345.

abstract class _Segment {}

class _TextSegment extends _Segment {
  final String text;
  _TextSegment(this.text);
}

class _MathSegment extends _Segment {
  final String tex;
  _MathSegment(this.tex);
}

List<_Segment> _splitByDisplayMath(String text) {
  final segments = <_Segment>[];
  final pattern = RegExp(r'\$\$([\s\S]+?)\$\$');
  int lastEnd = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > lastEnd) {
      segments.add(_TextSegment(text.substring(lastEnd, match.start)));
    }
    segments.add(_MathSegment(match.group(1)!.trim()));
    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    segments.add(_TextSegment(text.substring(lastEnd)));
  }
  if (segments.isEmpty) segments.add(_TextSegment(text));
  return segments;
}

// ── Message bubble ───────────────────────────────────────────────────────────

class AiMessageBubble extends StatelessWidget {
  final AiMessageModel message;

  const AiMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final timeStr = DateFormat('HH:mm').format(message.createdAt);
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadii.lg),
      topRight: const Radius.circular(AppRadii.lg),
      bottomLeft: Radius.circular(isUser ? AppRadii.lg : AppRadii.xs),
      bottomRight: Radius.circular(isUser ? AppRadii.xs : AppRadii.lg),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm2,
                AppSpacing.md,
                AppSpacing.sm2,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppColors.surface,
                borderRadius: bubbleRadius,
                border: !isUser
                    ? Border.all(color: AppColors.border)
                    : null,
                boxShadow: !isUser ? AppShadows.soft : null,
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    )
                  : _buildAssistantContent(context, message.content),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              timeStr,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantContent(BuildContext context, String content) {
    final segments = _splitByDisplayMath(content);

    // Fast path: no display math — skip the Column wrapper entirely.
    if (segments.length == 1 && segments[0] is _TextSegment) {
      return _buildMarkdown(context, (segments[0] as _TextSegment).text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: segments.map((seg) {
        if (seg is _MathSegment) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(child: _buildMath(seg.tex, display: true)),
          );
        }
        final text = (seg as _TextSegment).text.trim();
        if (text.isEmpty) return const SizedBox.shrink();
        return _buildMarkdown(context, text);
      }).toList(),
    );
  }

  Widget _buildMarkdown(BuildContext context, String text) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(
        Theme.of(context),
      ).copyWith(
        p: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.65,
        ),
        strong: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        listBullet: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
        blockquote: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
        code: const TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          color: AppTheme.textPrimary,
          backgroundColor: AppColors.surfaceMuted,
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.xs2),
          border: Border.all(color: AppColors.border),
        ),
      ),
      builders: {
        'inlinemath': _InlineMathBuilder(),
      },
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [
          _InlineMathSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
    );
  }
}
