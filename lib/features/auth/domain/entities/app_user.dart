class AppUser {
  final String uid;
  final String? email;
  final bool isAnonymous;

  AppUser({
    required this.uid,
    this.email,
    required this.isAnonymous,
  });
}
