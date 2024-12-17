import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _supportsBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canAuthenticate = await widget.authService.canUseBiometrics();
    setState(() {
      _supportsBiometrics = canAuthenticate;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() => _isLoading = true);
      final success = await widget.authService.authenticateWithBiometrics();
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = await widget.authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Ask user if they want to enable biometric login
        final shouldEnableBiometric = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Enable Biometric Login'),
            content: const Text(
                'Would you like to enable fingerprint login for faster access?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Yes'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (shouldEnableBiometric == true) {
          await widget.authService.enableBiometric();
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Login failed. Please check your email and password')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(CupertinoIcons.mail),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(CupertinoIcons.lock),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          if (_supportsBiometrics)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CupertinoButton(
                                onPressed: _isLoading
                                    ? null
                                    : _authenticateWithBiometrics,
                                color: CupertinoColors.systemBlue,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.fingerprint,
                                      color: CupertinoColors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Login with Biometrics',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('Login'),
                                ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child:
                            const Text('Don\'t have an account? Register now'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
