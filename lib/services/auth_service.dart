import 'package:fasalmitra/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaptchaData {
  const CaptchaData({required this.id, required this.imageUrl});

  final String id;
  final String imageUrl;
}

class MockUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;

  MockUser({required this.uid, this.email, this.phoneNumber, this.displayName});
}

class MockUserCredential {
  final MockUser? user;
  MockUserCredential({this.user});
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Map<String, dynamic>? _cachedUser;
  CaptchaData? _captcha;
  String? _authToken;
  late SharedPreferences _prefs;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _authToken = _prefs.getString('auth_token');
    if (_authToken != null) {
      try {
        await fetchProfile();
      } catch (e) {
        _authToken = null;
        await _prefs.remove('auth_token');
      }
    }
  }

  MockUser? get currentUser {
    if (_cachedUser != null) {
      return MockUser(
        uid: _cachedUser!['id'] ?? 'unknown',
        email: _cachedUser!['email'],
        phoneNumber: _cachedUser!['phone'] ?? _cachedUser!['mobile_no'],
        displayName: _cachedUser!['username'] ?? _cachedUser!['name'],
      );
    }
    return _authToken != null ? MockUser(uid: 'user_id_placeholder') : null;
  }

  bool get isLoggedIn => _authToken != null;
  Map<String, dynamic>? get cachedUser => _cachedUser;
  CaptchaData? get currentCaptcha => _captcha;
  String? get token => _authToken;

  Future<MockUserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
    required String mobile,
    String? state,
  }) async {
    try {
      await ApiService.instance.post(
        '/register/',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'mobile_no': mobile,
          'state': state ?? '',
        },
      );

      // Auto login after register
      return await signInWithEmailPassword(email: email, password: password);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<MockUserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.instance.post(
        '/login/',
        body: {'email': email, 'password': password},
      );

      if (response['success'] != null) {
        final body = response['success']['body'];
        final token = body['token'];

        if (token != null) {
          _authToken = token;
          await _prefs.setString('auth_token', token);
          await fetchProfile();

          return MockUserCredential(user: currentUser);
        } else {
          throw AuthException('Token missing in response');
        }
      } else if (response['error'] != null) {
        throw AuthException(
          response['error']['body']['error'] ?? 'Login failed',
        );
      } else {
        throw AuthException('Unknown login response');
      }
    } catch (e) {
      if (e is AuthException) rethrow; // Pass generic auth messages
      // Extract detailed error if possible, e.g. from ApiException
      throw AuthException(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    if (_authToken == null) {
      throw AuthException('Please login again');
    }

    try {
      final response = await ApiService.instance.get(
        '/profile/',
        token: _authToken,
      );

      if (response['success'] != null) {
        final data = response['success']['body'] as Map<String, dynamic>;
        // Map API format to Internal format if needed
        // API: username, email, mobile_no, state, token_balance
        // Internal expected: id, name, email, phone, state
        _cachedUser = {
          'id':
              data['username'], // Using username as ID for now, or fetch from somewhere else? API doesn't return ID in profile?
          'name': data['username'],
          'email': data['email'],
          'phone': data['mobile_no'],
          'state': data['state'],
          ...data,
        };
        return _cachedUser!;
      } else {
        throw AuthException('Failed to fetch profile data');
      }
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
    // Deprecated/Redundant in new flow, but kept for compatibility.
    // Ideally UI should stop calling this.
    // We will do nothing here because signUpWithEmailPassword already did the job.
    return;
  }

  Future<void> signOut() async {
    _authToken = null;
    _cachedUser = null;
    await _prefs.remove('auth_token');
    // Call API logout if desired (client side only per doc)
    try {
      // ApiService.instance.post('/logout/');
    } catch (_) {}
  }

  Future<void> logout() => signOut();
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
