import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:site_project_tracker/core/services/local_storage_service.dart';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();
  final LocalStorageService _localStorageService;

  ProfileImageService(this._localStorageService);

  Future<String?> pickAndCropImage(BuildContext context, String userId) async {
    try {
      // 1. Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // 2. Crop the user image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      if (croppedFile == null) return null;

      // 3. Save to local documents directory
      final appDir = await getApplicationDocumentsDirectory();

      // Use timestamp to prevent caching issues if same filename
      final fileName =
          'profile_img_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(path.join(appDir.path, fileName));

      await File(croppedFile.path).copy(savedImage.path);

      // 4. Update the path in LocalStorageService
      await _localStorageService.setProfileImagePath(userId, savedImage.path);

      return savedImage.path;
    } catch (e) {
      debugPrint('Error picking and cropping image: $e');
      return null;
    }
  }
}
