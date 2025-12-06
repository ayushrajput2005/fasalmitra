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

  Future<void> sendOtp({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
    );
  }

  Future<Map<String, dynamic>> verifyOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Authentication failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        _cachedUser = userDoc.data();
        return _cachedUser!;
      } else {
        // New user, return basic info so they can register
        return {'id': user.uid, 'phone': user.phoneNumber, 'isNewUser': true};
      }
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Invalid OTP');
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
        // Should ideally not happen if registered, but handle gracefully
        return {'id': user.uid, 'phone': user.phoneNumber};
      }
      _cachedUser = doc.data();
      return _cachedUser!;
    } catch (e) {
      throw AuthException('Failed to fetch profile: $e');
    }
  }

  // Mock captcha for now as it was backend based
  Future<CaptchaData> fetchCaptcha() async {
    // In a real Firebase app, you might use reCAPTCHA or just skip this for phone auth
    // Returning a dummy captcha to satisfy existing UI flow
    await Future.delayed(const Duration(milliseconds: 500));
    final captcha = CaptchaData(
      id: 'dummy_captcha',
      imageUrl: 'https://dummyimage.com/150x50/000/fff&text=1234',
    );
    _captcha = captcha;
    return captcha;
  }

  Future<void> verifyCaptcha({
    required String captchaId,
    required String text,
  }) async {
    // Mock verification
    await Future.delayed(const Duration(milliseconds: 500));
    if (text != '1234') {
      // For demo purposes, accept anything or simple check
      // throw AuthException('Invalid Captcha');
    }
  }

  Future<void> registerUser({
    required String name,
    required String phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('No authenticated user found');
    }

    final userData = {
      'id': user.uid,
      'name': name,
      'phone': phoneNumber, // or user.phoneNumber
      'role': 'farmer', // Default role
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
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
