import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaptchaData {
  const CaptchaData({required this.id, required this.imageUrl});

  final String id;
  final String imageUrl;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _cachedUser;
  CaptchaData? _captcha;

  Future<void> init(SharedPreferences prefs) async {
    // Listen to auth state changes to keep cache updated if needed
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        _cachedUser = null;
      }
    });
  }

  User? get currentUser => _firebaseAuth.currentUser;
  Map<String, dynamic>? get cachedUser => _cachedUser;
  CaptchaData? get currentCaptcha => _captcha;

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    }
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache user data
      if (credential.user != null) {
        await fetchProfile();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('Please login again');
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return {'id': user.uid, 'phone': user.phoneNumber};
      }
      _cachedUser = doc.data();
      return _cachedUser!;
    } catch (e) {
      throw AuthException('Failed to fetch profile: $e');
    }
  }

  Future<void> registerUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String state,
  }) async {
    final userData = {
      'id': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'state': state,
      'role': 'farmer', // Default role
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(uid).set(userData);
    _cachedUser = userData;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _cachedUser = null;
  }

  Future<void> logout() => signOut();
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
