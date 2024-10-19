import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false; // Toggles password visibility
  bool _hasError = false; // State to manage error display

  // Validates the input fields and updates the error state
  bool _validateInputs() {
    bool isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _hasError = !isValid; // Set error state if validation fails
    });
    return isValid;
  }

  // Simulated login function (replace with actual authentication logic)
  void _performLogin() {
    if (_validateInputs()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      // Simulated authentication logic (replace with your logic)
      if (email == "test@example.com" && password == "password123") {
        print('Login successful');
        setState(() {
          _hasError = false; // Reset error state on successful login
        });

        // Navigate to HomeScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _hasError = true; // Set error state on failed login
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Adjust layout when keyboard opens
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100), // Space for the top padding
              // Display the appropriate SVG based on the error state
              SvgPicture.asset(
                _hasError
                    ? 'assets/images/ErrorLogo.svg' // Error logo path
                    : 'assets/images/Logo.svg', // Normal logo path
                // height: 300,
                // width: 300,
              ),
              const SizedBox(height: 40),
              _buildEmailField(), // Email input field
              const SizedBox(height: 20),
              _buildPasswordField(), // Password input field
              const SizedBox(height: 20),
              _buildLoginButton(), // Login button
              const SizedBox(height: 100), // Space for keyboard
            ],
          ),
        ),
      ),
    );
  }

  // Builds the email input field with validation
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        labelText: 'Email',
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.black),
        focusedBorder: _inputBorder(color: Colors.blue, width: 2.0),
        prefixIcon: const Icon(Icons.email, color: Colors.blue),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
    );
  }

  // Builds the password input field with visibility toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        labelText: 'Password',
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.black),
        focusedBorder: _inputBorder(color: Colors.blue, width: 2.0),
        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
    );
  }

  // Builds the login button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _performLogin, // Call the login method
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0074CE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper method to create input borders
  OutlineInputBorder _inputBorder(
      {Color color = Colors.blue, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
