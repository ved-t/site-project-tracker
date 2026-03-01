import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Current Password"),
                validator: (value) =>
                    value!.isEmpty ? "Enter current password" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "New Password"),
                validator: (value) =>
                    value!.length < 6 ? "Minimum 6 characters" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Confirm Password"),
                validator: (value) {
                  if (value != _newController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await auth.changePassword(
                              _currentController.text.trim(),
                              _newController.text.trim(),
                            );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password updated successfully",
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
