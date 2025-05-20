
import 'package:object/Authentication/user_model.dart';

import 'api_service.dart';
import 'package:flutter/material.dart';

import 'otp_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late LoginPresenter _presenter;

  @override
  void initState() {
    super.initState();
    // Initialize presenter with repository
    _presenter = LoginPresenter(AuthRepository());
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _presenter.login(_mobileController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['status'] == true) {
      final user = _presenter.parseUser(response);
      final otp = _presenter.extractOtp(response);

      if (user != null) {
        if (otp != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Test OTP: $otp')),
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              mobile: _mobileController.text,
              user: user,
              otp: otp,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user data received')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Server error. Please try again later.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Sheba One',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (!RegExp(r'^\+?\d{10,12}$').hasMatch(value)) {
                    return 'Enter a valid number (e.g., +8801234567890)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}


// =============//

class LoginPresenter {
  final AuthRepository _authRepository;

  LoginPresenter(this._authRepository);

  Future<Map<String, dynamic>> login(String mobile) async {
    final response = await _authRepository.login(mobile);
    return response;
  }

  User? parseUser(Map<String, dynamic> response) {
    if (response['status'] == true && response['user'] != null) {
      try {
        return User.fromJson(response['user']);
      } catch (e) {
        print('Error parsing user: $e');
        return null;
      }
    }
    return null;
  }

  String? extractOtp(Map<String, dynamic> response) {
    if (response['status'] == true && response['user'] != null) {
      return response['user']['verify_code']?.toString();
    }
    return null;
  }
}