import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  static const String baseUrl = 'https://shebaone.com/api';

  Future<Map<String, dynamic>> login(String mobile) async {
    final url = Uri.parse('$baseUrl/login');
    for (int i = 0; i < 3; i++) {
      try {
        // Generate a temporary userId as a workaround for the server constraint
        final temporaryUserId = 161;

        print('Login Request: URL=$url, mobile=$mobile, userId=$temporaryUserId, Attempt=${i + 1}');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'mobile': mobile,
            'userId': temporaryUserId, // Add userId to fix the server error
          }),
        ).timeout(const Duration(seconds: 30));

        print('Login Response: Status=${response.statusCode}, Body=${response.body}');

        if (response.statusCode == 200) {
          try {
            return json.decode(response.body) as Map<String, dynamic>;
          } catch (e) {
            return {'status': false, 'message': 'Invalid response format: $e'};
          }
        } else if (response.statusCode == 500) {
          if (i == 2) {
            return {
              'status': false,
              'message': 'Server error: ${response.statusCode} - ${response.body}'
            };
          }
          continue;
        } else {
          return {
            'status': false,
            'message': 'Server error: ${response.statusCode} - ${response.body}'
          };
        }
      } catch (e) {
        print('Login Error: $e');
        if (i == 2) {
          return {'status': false, 'message': 'Network error: $e'};
        }
      }
    }
    return {'status': false, 'message': 'Server error after retries'};
  }

  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    final url = Uri.parse('$baseUrl/login-verify');
    for (int i = 0; i < 3; i++) {
      try {
        print(
            'Verify OTP Request: URL=$url, user_id=$userId, verify_code=$otp, Attempt=${i + 1}');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_id': userId, 'verify_code': otp}),
        ).timeout(const Duration(seconds: 30));

        print('Verify OTP Response: Status=${response.statusCode}, Body=${response.body}');

        if (response.statusCode == 200) {
          try {
            return json.decode(response.body) as Map<String, dynamic>;
          } catch (e) {
            return {'status': false, 'message': 'Invalid response format: $e'};
          }
        } else if (response.statusCode == 500) {
          if (i == 2) {
            return {
              'status': false,
              'message': 'Server error: ${response.statusCode} - ${response.body}'
            };
          }
          continue;
        } else {
          return {
            'status': false,
            'message': 'Server error: ${response.statusCode} - ${response.body}'
          };
        }
      } catch (e) {
        print('Verify OTP Error: $e');
        if (i == 2) {
          return {'status': false, 'message': 'Network error: $e'};
        }
      }
    }
    return {'status': false, 'message': 'Server error after retries'};
  }

  Future<Map<String, dynamic>> resendOtp(String userId) async {
    final url = Uri.parse('$baseUrl/resend-otp');
    for (int i = 0; i < 3; i++) {
      try {
        print('Resend OTP Request: URL=$url, user_id=$userId, Attempt=${i + 1}');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_id': userId}),
        ).timeout(const Duration(seconds: 30));

        print('Resend OTP Response: Status=${response.statusCode}, Body=${response.body}');

        if (response.statusCode == 200) {
          try {
            return json.decode(response.body) as Map<String, dynamic>;
          } catch (e) {
            return {'status': false, 'message': 'Invalid response format: $e'};
          }
        } else if (response.statusCode == 500) {
          if (i == 2) {
            return {
              'status': false,
              'message': 'Server error: ${response.statusCode} - ${response.body}'
            };
          }
          continue;
        } else {
          return {
            'status': false,
            'message': 'Server error: ${response.statusCode} - ${response.body}'
          };
        }
      } catch (e) {
        print('Resend OTP Error: $e');
        if (i == 2) {
          return {'status': false, 'message': 'Network error: $e'};
        }
      }
    }
    return {'status': false, 'message': 'Server error after retries'};
  }
}