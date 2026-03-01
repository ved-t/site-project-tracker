import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/features/auth/presentation/screens/change_password_page.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../widgets/info_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// PROFILE HEADER
            ProfileHeader(user: user),

            const SizedBox(height: 24),

            /// ACCOUNT INFO CARD
            InfoCard(
              title: "Account Information",
              children: [
                InfoTile("Email", user.email ?? "Not available"),
                InfoTile(
                  "Account Type",
                  user.isAnonymous ? "Guest" : "Authenticated",
                ),
                InfoTile("User ID", user.uid),
              ],
            ),

            const SizedBox(height: 24),

            /// SETTINGS CARD
            InfoCard(
              title: "Preferences",
              children: [
                SwitchListTile(
                  title: const Text("Notifications"),
                  value: true,
                  onChanged: (value) {},
                ),
                if (!user.isAnonymous && user.isEmailUser)
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text("Change Password"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            /// GUEST UPGRADE
            if (user.isAnonymous)
              InfoCard(
                title: "Secure Your Account",
                children: [
                  ListTile(
                    leading: const Icon(Icons.upgrade),
                    title: const Text("Upgrade to Full Account"),
                    onTap: () {
                      Navigator.pushNamed(context, '/upgrade');
                    },
                  ),
                ],
              ),

            const SizedBox(height: 24),

            /// DANGER ZONE
            InfoCard(
              title: "Account Actions",
              children: [
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
                      await auth.logout();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
