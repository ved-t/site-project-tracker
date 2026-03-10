import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/features/auth/presentation/controllers/auth_provider.dart';
import 'package:site_project_tracker/features/auth/presentation/screens/upgrade_account_page.dart';
import 'package:site_project_tracker/features/profile/presentation/screens/profile_page.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      final localStorageService = LocalStorageService();
      final path = await localStorageService.getProfileImagePath(
        auth.user!.uid,
      );
      if (mounted) {
        setState(() {
          _imagePath = path;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// PROFILE HEADER
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                child: _isLoading || _imagePath != null
                    ? null
                    : Text(
                        user?.email?.isNotEmpty == true
                            ? user!.email!.substring(0, 1).toUpperCase()
                            : "G",
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
              accountName: Text(
                user?.isAnonymous == true ? "Guest User" : user?.email ?? "",
              ),
              accountEmail: Text(
                user?.isAnonymous == true
                    ? "Limited Access"
                    : "Authenticated Account",
              ),
            ),

            /// PROFILE
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ).then((_) {
                  // Reload image when returning from ProfilePage just in case it was updated
                  _loadImage();
                });
              },
            ),

            /// SETTINGS //Temporarily disabled
            // ListTile(
            //   leading: const Icon(Icons.settings_outlined),
            //   title: const Text("Settings"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Navigate to settings page
            //   },
            // ),
            const Divider(),

            if (user?.isAnonymous == true)
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text("Upgrade Account"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpgradeAccountPage(),
                    ),
                  );
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    if (context.mounted) Navigator.pop(context); // Close drawer
                    await auth.logout();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
