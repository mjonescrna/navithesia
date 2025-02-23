import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

enum AuthMode { login, create }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _selectedSchool = '';
  List<String> _schoolOptions = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _biometricType = '';

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _checkBiometrics();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (_canCheckBiometrics) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (_availableBiometrics.contains(BiometricType.face)) {
          _biometricType = 'Face ID';
        } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
          _biometricType = 'Fingerprint';
        }
        setState(() {});
      }
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    final String response = await rootBundle.loadString(
      'assets/coa_schools.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      _schoolOptions = data.cast<String>();
    });
  }

  void _toggleAuthMode(AuthMode mode) {
    if (_authMode != mode) {
      setState(() {
        _authMode = mode;
        _errorMessage = '';
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    bool success = false;
    if (_authMode == AuthMode.login) {
      success = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      if (_nameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your name.';
          _isLoading = false;
        });
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }
      if (_selectedSchool.isEmpty) {
        setState(() {
          _errorMessage = 'Please select your school';
          _isLoading = false;
        });
        return;
      }
      success = await _authService.createAccount(
        _emailController.text,
        _passwordController.text,
        _selectedSchool,
      );
    }
    setState(() {
      _isLoading = false;
    });
    if (success) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder:
              (context) => HomePage(
                residentName:
                    _authMode == AuthMode.login
                        ? "Resident"
                        : _nameController.text,
                schoolName: _selectedSchool,
              ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Authentication failed. Please check your credentials.';
      });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your email to reset password.';
      });
      return;
    }
    await _authService.resetPassword(_emailController.text);
    setState(() {
      _errorMessage = 'Password reset email sent.';
    });
  }

  Future<void> _authenticateBiometrics() async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access NaviThesia',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder:
                  (context) => HomePage(
                    residentName: "Resident",
                    schoolName:
                        _selectedSchool.isEmpty
                            ? "Your School"
                            : _selectedSchool,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication failed: $e';
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4.withOpacity(0.2)),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.all(16),
        placeholderStyle: TextStyle(
          color: CupertinoColors.systemGrey.withOpacity(0.8),
          fontSize: 16,
        ),
        style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
        decoration: null,
        obscureText: isPassword,
        keyboardType: keyboardType,
        cursorColor: CupertinoColors.activeBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // NT Icon
                Center(
                  child: Image.asset(
                    'assets/icons/nt_icon.png',
                    height: 240,
                    width: 240,
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
                const Text(
                  'NaviThesia',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Navigating Your Anesthesia Residency',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Auth Mode Selector
                CupertinoSlidingSegmentedControl<AuthMode>(
                  backgroundColor: CupertinoColors.systemGrey6.withOpacity(0.1),
                  thumbColor: CupertinoColors.activeBlue,
                  groupValue: _authMode,
                  children: {
                    AuthMode.login: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color:
                              _authMode == AuthMode.login
                                  ? CupertinoColors.white
                                  : CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    AuthMode.create: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color:
                              _authMode == AuthMode.create
                                  ? CupertinoColors.white
                                  : CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value != null) _toggleAuthMode(value);
                  },
                ),
                const SizedBox(height: 32),

                // Form Fields
                if (_authMode == AuthMode.create)
                  Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        placeholder: 'Your Name',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                _buildTextField(
                  controller: _emailController,
                  placeholder: 'School Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 16),

                if (_authMode == AuthMode.create) ...[
                  _buildTextField(
                    controller: _confirmPasswordController,
                    placeholder: 'Confirm Password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4.withOpacity(0.2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _schoolOptions.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            _selectedSchool = selection;
                          });
                        },
                        fieldViewBuilder: (
                          context,
                          fieldController,
                          fieldFocusNode,
                          onFieldSubmitted,
                        ) {
                          return CupertinoTextField(
                            controller: fieldController,
                            focusNode: fieldFocusNode,
                            placeholder: 'Select Your School',
                            padding: const EdgeInsets.all(16),
                            placeholderStyle: TextStyle(
                              color: CupertinoColors.systemGrey.withOpacity(
                                0.8,
                              ),
                              fontSize: 16,
                            ),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                            ),
                            decoration: null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: CupertinoColors.darkBackgroundGray,
                              elevation: 4.0,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                width: MediaQuery.of(context).size.width - 48,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: const TextStyle(
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                // Main Action Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: _isLoading ? null : _submit,
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _isLoading
                            ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                            : Text(
                              _authMode == AuthMode.login
                                  ? 'Login'
                                  : 'Create Account',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                  ),
                ),

                if (_authMode == AuthMode.login) ...[
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () => _forgotPassword(),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  if (_canCheckBiometrics && _biometricType.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: CupertinoColors.systemGrey4),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      onPressed: _authenticateBiometrics,
                      color: CupertinoColors.systemGrey6.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _biometricType == 'Face ID'
                                ? CupertinoIcons.person_crop_circle_fill
                                : CupertinoIcons.circle_bottomthird_split,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Login with $_biometricType',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
