import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pos/core/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../assets/assets.gen.dart';
import '../constants/colors.dart';
import 'spaces.dart';

class ImagePickerWidget extends StatefulWidget {
  final String label;
  final void Function(File? file) onChanged;
  final bool showLabel;
  final double? width;
  final double? height;
  final String? initialImage;

  const ImagePickerWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.showLabel = true,
    this.width,
    this.height,
    this.initialImage,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
  return status.isGranted;
}

Future<bool> checkStoragePermission() async {
  if (await Permission.storage.isRestricted) {
    return true;
  }

  var status = await Permission.storage.status;
  if (status.isDenied) {
    status = await Permission.storage.request();
  }
  return status.isGranted;
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _imageFile = File(widget.initialImage!);
    }
  }

  Future<void> _getImageFromCamera() async {
    try {
      final hasPermission = await checkCameraPermission();
      if (hasPermission) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          _updateImage(File(image.path));
        }
      }
    } catch (e) {
      _showError('Tidak dapat mengakses kamera: $e');
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      final hasPermission = await checkStoragePermission();
      if (hasPermission) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          _updateImage(File(image.path));
        }
      }
    } catch (e) {
      _showError('Tidak dapat mengakses galeri: $e');
    }
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
      widget.onChanged(null);
    });
  }

  void _updateImage(File file) {
    setState(() {
      _imageFile = file;
      widget.onChanged(file);
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    SnackbarUtils(
      text: message,
      backgroundColor: Colors.red,
    ).showErrorSnackBar(context);
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomSheetOption(
                  Icons.camera_alt,
                  'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromCamera();
                  },
                ),
                _buildBottomSheetOption(
                  Icons.photo_library,
                  'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromGallery();
                  },
                ),
                if (_imageFile != null)
                  _buildBottomSheetOption(
                    Icons.delete,
                    'Hapus',
                    onTap: () {
                      Navigator.pop(context);
                      _deleteImage();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xffE4E4E7),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SpaceHeight(12.0),
        ],
        GestureDetector(
          onTap: _showImageSourceModal,
          child: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: widget.width ?? 80.0,
                  height: widget.height ?? 80.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            padding: const EdgeInsets.all(16.0),
                            color: AppColors.black.withValues(alpha: 0.05),
                            child: Assets.icons.image.svg(),
                          ),
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.camera_alt,
                      color: AppColors.primary, size: 28),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
