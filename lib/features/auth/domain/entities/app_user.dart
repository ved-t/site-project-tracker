class AppUser {
  final String uid;
  final String? email;
  final bool isAnonymous;
  final List<String> providers;

  AppUser({
    required this.uid,
    this.email,
    required this.isAnonymous,
    required this.providers,
  });

  bool get isEmailUser => providers.contains("password");
}