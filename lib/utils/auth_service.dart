import 'package:firebase_auth/firebase_auth.dart';
import 'package:agora_new_way/pages/homepage.dart';
import 'package:agora_new_way/pages/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return SignInScreen();
          }
        }));
  }

  // google verified deatils
  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ]).signIn();

    print(googleUser);

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // signout method
  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
