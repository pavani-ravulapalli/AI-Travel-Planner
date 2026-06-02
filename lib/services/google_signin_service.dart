import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _isInitialized = false;

  static Future<void> initSignIn() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initSignIn();

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;

      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization =
      await authorizationClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      String? accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 =
        await authorizationClient.authorizationForScopes([
          'email',
          'profile',
        ]);

        accessToken = authorization2?.accessToken;

        if (accessToken == null) {
          throw FirebaseAuthException(
            code: 'google-sign-in-failed',
            message: 'Unable to obtain Google access token',
          );
        }
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e, stackTrace) {
      print('Google Sign-In Error: $e');
      print('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}