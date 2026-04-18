import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/course_hub/data/models/course_file_model.dart';
import 'package:campusiq/features/course_hub/domain/course_pdf_extractor.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_file_provider.dart';
import 'package:campusiq/features/course_hub/presentation/widgets/file_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class HubFilesTab extends ConsumerStatefulWidget {
  final String courseCode;

  const HubFilesTab({super.key, required this.courseCode});

  @override
  ConsumerState<HubFilesTab> createState() => _HubFilesTabState();
}

class _HubFilesTabState extends ConsumerState<HubFilesTab> {
  bool _isAttaching = false;
  String _attachLabel = 'Attach File';
  final _extractor = CoursePdfExtractor();

  Future<String> _copyFileToAppDir(
      String sourcePath, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final courseDir =
        Directory('${appDir.path}/course_files/${widget.courseCode}');
    if (!await courseDir.exists()) {
      await courseDir.create(recursive: true);
    }
    // Avoid name collisions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = '${timestamp}_$fileName';
    final dest = File('${courseDir.path}/$safeName');
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  Future<void> _attachFile() async {
    setState(() {
      _isAttaching = true;
      _attachLabel = 'Attach File';
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final ext = result.files.single.extension?.toLowerCase() ?? '';
        final fileType = ext == 'pdf' ? 'pdf' : 'image';

        final destPath = await _copyFileToAppDir(sourcePath, fileName);

        String? extractedText;
        bool isTextExtractable = false;

        if (ext == 'pdf') {
          if (mounted) setState(() => _attachLabel = 'Reading PDF...');
          final extraction = await _extractor.extract(destPath);
          extractedText = extraction.isExtractable ? extraction.text : null;
          isTextExtractable = extraction.isExtractable;
        }

        final repo = ref.read(courseFileRepositoryProvider);
        if (repo != null) {
          final fileModel = CourseFileModel()
            ..courseCode = widget.courseCode
            ..fileName = fileName
            ..filePath = destPath
            ..fileType = fileType
            ..extractedText = extractedText
            ..isTextExtractable = isTextExtractable
            ..addedAt = DateTime.now();
          await repo.saveFile(fileModel);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAttaching = false;
          _attachLabel = 'Attach File';
        });
      }
    }
  }

  Future<void> _openFile(CourseFileModel file) async {
    final result = await OpenFilex.open(file.filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open file. Is a viewer installed?')),
      );
    }
  }

  Future<void> _deleteFile(CourseFileModel file) async {
    final repo = ref.read(courseFileRepositoryProvider);
    await repo?.deleteFile(file.id);
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(courseFilesProvider(widget.courseCode));

    return filesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (files) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isAttaching ? null : _attachFile,
                  icon: _isAttaching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file, size: 18),
                  label: Text(_attachLabel),
                ),
              ),
            ),
            Expanded(
              child: files.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open_outlined,
                                size: 48, color: AppTheme.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              'No files attached',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Attach PDFs or images related to this course.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return FileTile(
                          file: file,
                          onTap: () => _openFile(file),
                          onDelete: () => _deleteFile(file),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
