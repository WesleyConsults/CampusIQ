import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class CoursePdfExtractor {
  static const int _minTextThreshold = 150;
  static const int _maxCharsStored = 40000;

  Future<({String text, bool isExtractable})> extract(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = sf.PdfDocument(inputBytes: bytes);
      final extractor = sf.PdfTextExtractor(document);

      final buffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (pageText.trim().isNotEmpty) {
          buffer.writeln(pageText.trim());
        }
      }

      document.dispose();

      final fullText = buffer.toString();

      if (fullText.length < _minTextThreshold) {
        return (text: '', isExtractable: false);
      }

      final capped = fullText.length > _maxCharsStored
          ? '${fullText.substring(0, _maxCharsStored)}\n[...content truncated]'
          : fullText;

      return (text: capped, isExtractable: true);
    } catch (e) {
      debugPrint('🔴 PDF extraction failed: $e');
      return (text: '', isExtractable: false);
    }
  }
}
