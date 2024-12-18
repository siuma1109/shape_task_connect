import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

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
  String _biometricType = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canAuthenticate = await widget.authService.canUseBiometrics();
      final biometricType = await widget.authService.getBiometricType();

      print('Can authenticate: $canAuthenticate');
      print('Biometric type: $biometricType');

      setState(() {
        _supportsBiometrics = canAuthenticate;
        _biometricType = biometricType;
      });
    } catch (e) {
      print('Error checking biometrics: $e');
    }
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
      try {
        setState(() => _isLoading = true);

        bool success = await widget.authService.login(
          _emailController.text,
          _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (success) {
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
              ) ??
              false;

          if (shouldEnableBiometric) {
            await widget.authService.enableBiometric();
          }

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Login failed. Please check your email and password')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
                            ),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  key: const Key('loginButton'),
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
