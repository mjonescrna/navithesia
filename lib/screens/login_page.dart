import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart'; // Main app after login

enum AuthMode { login, create }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Sample school list drawn from the COA programs.docx file :contentReference[oaicite:1]{index=1}.
  List<String> _schools = [
    "AdventHealth University Nurse Anesthesia Program",
    "Albany Medical College Nurse Anesthesiology Program",
    "Allegheny School of Anesthesia",
    "Augusta University Nursing Anesthesia Program",
    "Barry University College of Health and Wellness - Nurse Anesthesiology Programs",
  ];
  String _selectedSchool = '';

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';

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
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
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
      // Navigate to the main app page.
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => HomePage()),
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
        CupertinoPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed.';
      });
    }
  }

  void _selectSchool() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.systemBackground.resolveFrom(
              context,
            ),
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedSchool = _schools[index];
              });
            },
            children: _schools.map((school) => Text(school)).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('NaviThesia Login')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CupertinoSegmentedControl<AuthMode>(
                children: {
                  AuthMode.login: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Login'),
                  ),
                  AuthMode.create: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Create Account'),
                  ),
                },
                groupValue: _authMode,
                onValueChanged: (AuthMode value) {
                  _toggleAuthMode(value);
                },
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'School Email Address',
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
              ),
              if (_authMode == AuthMode.create) ...[
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                  obscureText: true,
                ),
                SizedBox(height: 16),
                CupertinoButton(
                  child: Text(
                    _selectedSchool.isEmpty ? 'Select School' : _selectedSchool,
                  ),
                  onPressed: _selectSchool,
                ),
              ],
              SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: CupertinoColors.systemRed.resolveFrom(context),
                  ),
                ),
              if (_isLoading) CupertinoActivityIndicator(),
              SizedBox(height: 16),
              CupertinoButton.filled(
                child: Text(
                  _authMode == AuthMode.login ? 'Login' : 'Create Account',
                ),
                onPressed: _submit,
              ),
              if (_authMode == AuthMode.login) ...[
                CupertinoButton(
                  child: Text('Forgot Password?'),
                  onPressed: _forgotPassword,
                ),
                SizedBox(height: 16),
                // Biometric authentication icon button
                CupertinoButton(
                  child: Icon(CupertinoIcons.lock_shield, size: 40),
                  onPressed: _authenticateBiometrics,
                ),
                Text('Use Face ID / Touch ID'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
