import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Card d'upload de document (photo ou galerie).
/// Affiche une prévisualisation si un fichier est sélectionné.
class UploadDocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? filePath;      // null = rien sélectionné
  final bool isRequired;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const UploadDocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.filePath,
    this.isRequired = false,
    this.isLoading = false,
    this.onRemove,
  });

  bool get _hasFile => filePath != null && filePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hasFile ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hasFile
              ? AppColors.statusGreenLight
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasFile ? AppColors.primary : AppColors.border,
            width: _hasFile ? 2 : 1,
          ),
        ),
        child: _hasFile
            ? _FilePreview(
                filePath: filePath!,
                title: title,
                onRemove: onRemove,
                onReplace: onTap,
              )
            : _EmptyState(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isRequired: isRequired,
                isLoading: isLoading,
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;
  final bool isLoading;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRequired,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  )
                : Icon(icon, color: AppColors.textSecondary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusRedLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Requis',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline,
              color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final String filePath;
  final String title;
  final VoidCallback? onRemove;
  final VoidCallback onReplace;

  const _FilePreview({
    required this.filePath,
    required this.title,
    required this.onReplace,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Miniature
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(filePath),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.border,
                child: const Icon(Icons.insert_drive_file_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('Document ajouté',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onReplace,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.statusRedLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Utilitaire pour ouvrir la caméra ou la galerie
class DocumentUploadHelper {
  static Future<String?> pick(BuildContext context) async {
    // Simulate upload (delay + dummy path)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop(); // close loader
    return 'simulated_path.jpg';
  }
}
