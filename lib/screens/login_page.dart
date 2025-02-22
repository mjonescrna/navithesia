import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

enum AuthMode { login, create }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _selectedSchool = '';
  List<String> _schoolOptions = [];

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSchools();
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
    setState(() {
      _authMode = mode;
      _errorMessage = '';
    });
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
    bool authenticated = await _authService.authenticateWithBiometrics();
    if (authenticated) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder:
              (context) => HomePage(
                residentName: "Resident",
                schoolName:
                    _selectedSchool.isEmpty ? "Your School" : _selectedSchool,
              ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('NaviThesia Login'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auth Mode Segmented Control
              CupertinoSegmentedControl<AuthMode>(
                children: {
                  AuthMode.login: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  AuthMode.create: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                },
                groupValue: _authMode,
                onValueChanged: (AuthMode value) {
                  _toggleAuthMode(value);
                },
              ),
              const SizedBox(height: 24),

              // Name field (only if creating account)
              if (_authMode == AuthMode.create) ...[
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Your Name',
                  placeholderStyle: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Email field
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'School Email Address',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Password field
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password (min 6 characters)',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
                obscureText: true,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                ),
              ),

              // Confirm password field (only if creating account)
              if (_authMode == AuthMode.create) ...[
                const SizedBox(height: 24),
                CupertinoTextField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                  placeholderStyle: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                  obscureText: true,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // School label
                Text(
                  'Select Your School',
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(fontSize: 16, color: CupertinoColors.white),
                ),
                const SizedBox(height: 8),

                // School Autocomplete
                Material(
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
                      BuildContext context,
                      TextEditingController fieldController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      fieldController.text = _selectedSchool;
                      return CupertinoTextField(
                        controller: fieldController,
                        focusNode: fieldFocusNode,
                        placeholder: 'Type to search your school',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                    optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: CupertinoColors.darkBackgroundGray,
                          elevation: 4.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Error message
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: CupertinoColors.systemRed.resolveFrom(context),
                    fontSize: 16,
                  ),
                ),

              if (_isLoading) ...[
                const SizedBox(height: 16),
                const CupertinoActivityIndicator(),
              ],
              const SizedBox(height: 24),

              // Login/Create button
              CupertinoButton.filled(
                onPressed: _submit,
                child: Text(
                  _authMode == AuthMode.login ? 'Login' : 'Create Account',
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              // Forgot Password & Biometrics (only in Login mode)
              if (_authMode == AuthMode.login) ...[
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: _authenticateBiometrics,
                  child: const Icon(CupertinoIcons.lock_shield, size: 44),
                ),
                const Text(
                  'Use Face ID / Touch ID',
                  style: TextStyle(fontSize: 16, color: CupertinoColors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
