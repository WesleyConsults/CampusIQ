import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/course_hub/data/models/course_file_model.dart';
import 'package:intl/intl.dart';

class FileTile extends StatelessWidget {
  final CourseFileModel file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FileTile({
    super.key,
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = file.fileType == 'pdf';
    final dateLabel = DateFormat('dd MMM yyyy').format(file.addedAt);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPdf
              ? Colors.red.shade50
              : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
          size: 22,
          color: isPdf ? Colors.red.shade600 : Colors.blue.shade600,
        ),
      ),
      title: Text(
        file.fileName,
        style: const TextStyle(
            fontWeight: FontWeight.w500, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isPdf ? 'PDF' : 'Image'} · $dateLabel',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
          if (file.isTextExtractable)
            Chip(
              label: const Text('📄 Text indexed',
                  style: TextStyle(fontSize: 11)),
              backgroundColor: Colors.green.shade50,
              side: BorderSide(color: Colors.green.shade200),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          else if (isPdf)
            Chip(
              label: const Text('🖼 Visual only — AI cannot read this',
                  style: TextStyle(fontSize: 11)),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(color: Colors.grey.shade300),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline,
            size: 20, color: AppTheme.textSecondary),
        onPressed: onDelete,
        tooltip: 'Delete',
      ),
    );
  }
}
