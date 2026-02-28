import 'package:google_sign_in/google_sign_in.dart';

void main() {
  try {
    final g = GoogleSignIn();
    print('GoogleSignIn created successfully');
    print('Has signIn: ${g.signIn != null}');
  } catch (e) {
    print('Error creating GoogleSignIn: $e');
  }
}
