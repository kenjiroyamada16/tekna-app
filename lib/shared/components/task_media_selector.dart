import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/entities/task_media.dart';
import '../../style/app_colors.dart';

class TaskMediaSelector extends StatefulWidget {
  final TaskMedia? initialMedia;
  final void Function(XFile? mediaFile)? onUpdateMedia;

  const TaskMediaSelector({super.key, this.onUpdateMedia, this.initialMedia});

  @override
  State<TaskMediaSelector> createState() => _TaskMediaSelectorState();
}

class _TaskMediaSelectorState extends State<TaskMediaSelector> {
  XFile? _selectedMedia;
  TaskMedia? _initialMedia;

  @override
  void initState() {
    super.initState();
    _initialMedia = widget.initialMedia;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedMedia != null ? _selectedMedia?.name ?? '' : 'Media',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.photo_library, size: 20, color: AppColors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (_initialMedia != null || _selectedMedia != null)
          Center(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _mediaPreviewWidget,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMedia = null;
                          _initialMedia = null;
                          widget.onUpdateMedia?.call(_selectedMedia);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget get _mediaPreviewWidget {
    if (_selectedMedia != null) {
      return Image.file(
        File(_selectedMedia?.path ?? ''),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.grey.withValues(alpha: 0.3),
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppColors.grey,
            ),
          );
        },
      );
    }

    if (_initialMedia != null) {
      return CachedNetworkImage(
        imageUrl: _initialMedia?.url ?? '',
        fit: BoxFit.cover,
        progressIndicatorBuilder: (_, __, ___) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.secondaryColor),
          );
        },
        errorWidget: (_, __, ___) {
          return Container(
            color: AppColors.grey.withValues(alpha: 0.3),
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppColors.grey,
            ),
          );
        },
      );
    }

    return SizedBox.shrink();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        requestFullMetadata: false,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedMedia = pickedFile;
        });
        widget.onUpdateMedia?.call(_selectedMedia);
      }
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not upload your media'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
