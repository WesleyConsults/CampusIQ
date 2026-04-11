import 'package:flutter/material.dart';

class QuestionTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const QuestionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'mcq',
          label: Text('Multiple Choice'),
          icon: Icon(Icons.list_alt, size: 16),
        ),
        ButtonSegment(
          value: 'short',
          label: Text('Short Answer'),
          icon: Icon(Icons.edit_note, size: 16),
        ),
        ButtonSegment(
          value: 'flash',
          label: Text('Flash Cards'),
          icon: Icon(Icons.flip, size: 16),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
