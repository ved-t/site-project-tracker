import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/features/auth/presentation/controllers/auth_provider.dart';
import 'package:site_project_tracker/features/auth/presentation/screens/upgrade_account_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

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
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? "G",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              accountName: Text(
                user?.isAnonymous == true
                    ? "Guest User"
                    : user?.email ?? "",
              ),
              accountEmail: Text(
                user?.isAnonymous == true
                    ? "Limited Access"
                    : "Authenticated Account",
              ),
            ),

            /// SETTINGS
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),

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
                title: const Text("Logout",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.logout();
                },
              )

          ],
        ),
      ),
    );
  }
}
