import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';

class FlashCardWidget extends StatefulWidget {
  final int index;
  final FlashCard card;

  const FlashCardWidget({
    super.key,
    required this.index,
    required this.card,
  });

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_showBack) {
      _controller.reverse().then((_) => setState(() => _showBack = false));
    } else {
      _controller.forward().then((_) => setState(() => _showBack = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * math.pi;
            final isFrontVisible = angle < math.pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isFrontVisible
                  ? _CardFace(
                      index: widget.index,
                      text: widget.card.front,
                      isFront: true,
                    )
                  : Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _CardFace(
                        index: widget.index,
                        text: widget.card.back,
                        isFront: false,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final int index;
  final String text;
  final bool isFront;

  const _CardFace({
    required this.index,
    required this.text,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFront ? Colors.indigo.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFront ? Colors.indigo.shade200 : Colors.amber.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isFront
                      ? Colors.indigo.shade100
                      : Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFront ? 'Card ${index + 1}' : 'Answer',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isFront
                        ? Colors.indigo.shade800
                        : Colors.amber.shade900,
                  ),
                ),
              ),
              Icon(
                Icons.flip,
                size: 14,
                color: isFront
                    ? Colors.indigo.shade400
                    : Colors.amber.shade700,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isFront
                  ? Colors.indigo.shade900
                  : Colors.amber.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isFront ? 'Tap to reveal answer' : 'Tap to flip back',
            style: TextStyle(
              fontSize: 11,
              color: isFront
                  ? Colors.indigo.shade400
                  : Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
