import 'package:flutter/material.dart';
import 'package:object/Authentication/user_model.dart';
import 'api_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobile;
  final User? user;
  final String? otp; // OTP (verify_code) from login response

  const OtpVerificationPage({
    Key? key,
    required this.mobile,
    this.user,
    this.otp,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late OtpPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = OtpPresenter(AuthRepository());

    // Pre-fill OTP field if provided
    if (widget.otp != null && widget.otp!.isNotEmpty) {
      _otpController.text = widget.otp!;

      // Show OTP in SnackBar after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Your OTP: ${widget.otp}'),
                duration: const Duration(seconds: 10)
            ),
          );
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.user == null || widget.user!.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing or invalid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await _presenter.verifyOtp(
        widget.user!.userId,
        _otpController.text.trim()
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified Successfully')),
      );

      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Invalid OTP. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (widget.user == null || widget.user!.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing or invalid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await _presenter.resendOtp(widget.user!.userId);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['status'] == true) {
      // Check for new verify_code in response
      final newOtp = _presenter.extractOtp(response);
      if (newOtp != null) {
        _otpController.text = newOtp;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New OTP: $newOtp')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'OTP resent successfully')),
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter the OTP sent to your mobile',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                widget.mobile,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OTP';
                  }
                  if (!RegExp(r'^\d{4,6}$').hasMatch(value)) {
                    return 'Enter a valid OTP (4-6 digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : _resendOtp,
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class OtpPresenter {
  final AuthRepository _authRepository;

  OtpPresenter(this._authRepository);

  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    final response = await _authRepository.verifyOtp(userId, otp);
    return response;
  }

  Future<Map<String, dynamic>> resendOtp(String userId) async {
    final response = await _authRepository.resendOtp(userId);
    return response;
  }

  String? extractOtp(Map<String, dynamic> response) {
    if (response['status'] == true && response['user'] != null) {
      return response['user']['verify_code']?.toString();
    }
    return null;
  }
}