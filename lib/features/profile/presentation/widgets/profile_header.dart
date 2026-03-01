import 'dart:io';
import 'package:flutter/material.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';
import 'package:site_project_tracker/features/profile/data/services/profile_image_service.dart';

class ProfileHeader extends StatefulWidget {
  final dynamic user;

  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? _imagePath;
  bool _isLoading = true;
  late final LocalStorageService _localStorageService;
  late final ProfileImageService _profileImageService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _profileImageService = ProfileImageService(_localStorageService);
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = await _localStorageService.getProfileImagePath(
      widget.user.uid,
    );
    if (mounted) {
      setState(() {
        _imagePath = path;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final newPath = await _profileImageService.pickAndCropImage(
      context,
      widget.user.uid,
    );
    if (newPath != null && mounted) {
      setState(() {
        _imagePath = newPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                child: _isLoading || _imagePath != null
                    ? null
                    : Text(
                        widget.user.email?.substring(0, 1).toUpperCase() ?? "G",
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.email ?? "Guest User",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(
            widget.user.isAnonymous ? "Guest Account" : "Verified Account",
          ),
          backgroundColor: widget.user.isAnonymous
              ? Colors.orange.shade100
              : Colors.green.shade100,
        ),
      ],
    );
  }
}
