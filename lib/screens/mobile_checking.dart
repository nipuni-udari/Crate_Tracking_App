import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';
import 'package:animate_do/animate_do.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({Key? key}) : super(key: key);

  @override
  _MobileScreenState createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  // Constants for UI styling
  static const Color primaryColor = Color.fromARGB(255, 252, 132, 58);
  static const Color secondaryColor = Color.fromARGB(255, 43, 4, 4);
  static const Color buttonColor = Color.fromARGB(255, 241, 119, 62);

  Future<void> sendOtp(String mobileNumber) async {
    setState(() {
      _isLoading = true;
    });

    final url =
        Uri.parse('https://demo.secretary.lk/cargills_app/backend/otp_sms.php');

    try {
      final response = await http.post(url, body: {'mobile': mobileNumber});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        switch (data['status']) {
          case 'success':
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtpScreen(
                mobileNumber: mobileNumber,
                otp: '',
              ),
            ));
            break;

          case 'exists':
            // No alert, just navigate to home
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/home');
            break;

          case 'error':
            _showAlert(data['message'], null);
            break;

          case 'access_denied': // FIXED HERE
            _showAlert('Access denied. Mobile number not found.', null);
            break;

          default:
            _showAlert('Unexpected response from server.', null);
        }
      } else {
        _showAlert(
            'HTTP Error: ${response.statusCode}. Please try again later.',
            null);
      }
    } catch (e) {
      _showAlert('An error occurred: ${e.toString()}', null);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String message, VoidCallback? onOkPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOkPressed != null) onOkPressed();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isValidMobileNumber(String mobileNumber) {
    final regex = RegExp(r'^(?:\+94|94|0)?[1-9]\d{8}$');
    return regex.hasMatch(mobileNumber);
  }

  Future<void> _resetForm() async {
    await Future.delayed(const Duration(seconds: 1));
    _mobileController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form reset successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _resetForm,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeIn(
              duration:
                  const Duration(milliseconds: 1000), // Page fade-in animation
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    children: [
                      // Back Button
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Image
                      BounceInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: Image.asset(
                          'assets/images/forgot.gif',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registration Text
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: const Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Text(
                          "Add your phone number. We'll send you a verification code so we know you're real.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input Field and Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Enter your mobile number",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final mobileNumber =
                                      _mobileController.text.trim();
                                  if (mobileNumber.isEmpty) {
                                    _showAlert(
                                        'Please enter a mobile number.', null);
                                  } else if (!_isValidMobileNumber(
                                      mobileNumber)) {
                                    _showAlert(
                                        'Please enter a valid mobile number.',
                                        null);
                                  } else {
                                    sendOtp(mobileNumber);
                                  }
                                },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    buttonColor,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const Text(
                                        'Sending...',
                                        style: TextStyle(fontSize: 16),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(
                                          'Send',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
