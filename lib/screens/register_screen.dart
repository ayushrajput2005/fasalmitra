import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fasalmitra/screens/phone_login.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/services/tip_service.dart';
import 'package:fasalmitra/widgets/language_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _grassAsset = 'assets/images/grass.png';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();

  bool _submitting = false;
  bool _cachedGrass = false;
  CaptchaData? _captcha;
  bool _captchaLoading = false;

  // OTP State
  String? _verificationId;
  int? _resendToken;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = AuthService.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      String phone = user.phoneNumber!;
      if (phone.startsWith('+91')) {
        phone = phone.substring(3);
      }
      _phoneController.text = phone;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cachedGrass) {
      precacheImage(const AssetImage(_grassAsset), context).catchError((_) {});
      _cachedGrass = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _captchaController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    setState(() => _captchaLoading = true);
    try {
      final captcha = await AuthService.instance.fetchCaptcha();
      if (!mounted) return;
      setState(() {
        _captcha = captcha;
        _captchaController.clear();
      });
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Captcha failed: $err')));
    } finally {
      if (mounted) {
        setState(() => _captchaLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is already authenticated
    final currentUser = AuthService.instance.currentUser;

    if (_captcha == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Captcha not ready yet')));
      return;
    }
    final captchaText = _captchaController.text.trim();
    if (captchaText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter captcha text')));
      return;
    }

    // Sanitize phone number
    String rawPhone = _phoneController.text.trim();
    rawPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawPhone.length > 10 && rawPhone.startsWith('91')) {
      rawPhone = rawPhone.substring(2);
    }

    if (rawPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final lang = LanguageService.instance;

    try {
      // If user is NOT logged in, we need to do OTP flow
      if (currentUser == null) {
        if (!_codeSent) {
          // Step 1: Send OTP
          await AuthService.instance.verifyCaptcha(
            captchaId: _captcha!.id,
            text: captchaText,
          );

          await AuthService.instance.sendOtp(
            phoneNumber: '+91$rawPhone',
            verificationCompleted: (credential) async {
              // Auto-verification (rare but possible)
              await FirebaseAuth.instance.signInWithCredential(credential);
              // Proceed to register
              if (mounted) _submit();
            },
            verificationFailed: (e) {
              messenger.showSnackBar(
                SnackBar(content: Text(e.message ?? 'Verification failed')),
              );
              setState(() => _submitting = false);
            },
            codeSent: (verificationId, resendToken) {
              setState(() {
                _verificationId = verificationId;
                _resendToken = resendToken;
                _codeSent = true;
                _submitting = false;
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text('${lang.t('otpSentPrefix')} +91$rawPhone'),
                ),
              );
            },
            codeAutoRetrievalTimeout: (_) {},
            forceResendingToken: _resendToken,
          );
          return; // Wait for user to enter OTP
        } else {
          // Step 2: Verify OTP
          final otp = _otpController.text.trim();
          if (otp.length != 6) {
            messenger.showSnackBar(SnackBar(content: Text(lang.t('enterOtp'))));
            setState(() => _submitting = false);
            return;
          }

          await AuthService.instance.verifyOtp(_verificationId!, otp);

          // Wait for auth state to propagate
          int retries = 0;
          while (AuthService.instance.currentUser == null && retries < 10) {
            await Future.delayed(const Duration(milliseconds: 200));
            retries++;
          }

          // Now user is logged in, proceed to register logic below
        }
      } else {
        // User is logged in, just verify captcha if not already done in OTP step?
        // Actually, if they are logged in, we might skip captcha or just verify it again.
        // Let's verify it again to be safe/consistent with existing flow.
        await AuthService.instance.verifyCaptcha(
          captchaId: _captcha!.id,
          text: captchaText,
        );
      }

      // Step 3: Register User Data
      await AuthService.instance.registerUser(
        name: _nameController.text.trim(),
        phoneNumber: '+91$rawPhone',
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Registration submitted!')),
      );
      // Navigate to Home instead of Login, since they are now logged in
      Navigator.of(context).pushReplacementNamed(
        PhoneLoginScreen.routeName,
      ); // Or Home? User requested "login/register work", usually register -> login or home.
      // The original code went to PhoneLoginScreen. Let's keep it or maybe go to Home if they are logged in?
      // If they just registered, they are logged in. Sending them to login screen might be confusing if they are already logged in.
      // But let's stick to original flow: Register -> Login Screen (maybe to force re-login or just as a success page).
      // Wait, if they are logged in, going to PhoneLoginScreen might auto-redirect to Home if PhoneLoginScreen checks auth.
      // Let's send them to Home if they are logged in.
      // Actually, let's stick to the requested behavior: "make it work".
      // Original code: Navigator.of(context).pushReplacementNamed(PhoneLoginScreen.routeName);
    } catch (err) {
      String message = err.toString();
      if (err is FirebaseAuthException) {
        message = '${err.code}: ${err.message}';
      } else if (err is AuthException) {
        message = err.message;
      }
      messenger.showSnackBar(SnackBar(content: Text('Error: $message')));
      _loadCaptcha();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final card = _buildRegisterCard();
              if (!isWide) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildWelcomePanel(height: constraints.maxHeight * 0.25),
                      card,
                    ],
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildWelcomePanel()),
                  Expanded(child: SingleChildScrollView(child: card)),
                ],
              );
            },
          ),
          const Positioned(top: 16, right: 16, child: LanguageSelector()),
        ],
      ),
    );
  }

  Widget _buildWelcomePanel({double? height}) {
    final lang = LanguageService.instance;
    final grassHeight = (height ?? 400) * 0.6;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF195B33), Color(0xFF4CAF50)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: grassHeight,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  _grassAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder<String>(
                      valueListenable: TipService.instance.listenable,
                      builder: (context, tip, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lang.t('welcome')}\n${lang.t('appName')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (tip.isNotEmpty)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  key: ValueKey(tip),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tip,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCard() {
    final lang = LanguageService.instance;
    final currentUser = AuthService.instance.currentUser;
    // Determine button text
    String buttonText = lang.t('registerCta');
    if (currentUser == null) {
      if (_codeSent) {
        buttonText =
            'Verify & Register'; // TODO: Add translation key if needed, or use hardcoded for now
      } else {
        buttonText = lang.t('sendOtp');
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lang.t('register'),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: lang.t('fullName'),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            // Allow editing if not logged in
                            readOnly: currentUser != null,
                            decoration: InputDecoration(
                              labelText: lang.t('mobile'),
                              prefixText: '+91 ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return lang.t('enterPhone');
                              }
                              if (value.trim().length != 10) {
                                return 'Enter 10 digit mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _captchaController,
                                  decoration: InputDecoration(
                                    labelText: lang.t('captchaText'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildCaptchaBox(),
                            ],
                          ),
                          if (_codeSent) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _otpController,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: lang.t('enterOtp'),
                                counterText: '',
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(buttonText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(PhoneLoginScreen.routeName);
                      },
                      child: Text(lang.t('alreadyRegistered')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptchaBox() {
    return Container(
      width: 120,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade100,
      ),
      child: _captchaLoading
          ? const Center(child: CircularProgressIndicator())
          : InkWell(
              onTap: _loadCaptcha,
              child: _captcha == null || _captcha!.imageUrl.isEmpty
                  ? const Center(child: Text('Tap to load'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _captcha!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Text('Captcha')),
                      ),
                    ),
            ),
    );
  }
}
