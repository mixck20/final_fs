import 'package:flutter/material.dart';
import 'HomePage_JMSD.dart';
import 'signup_JMSD.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 32, 120, 179),
        foregroundColor: Colors.black,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: 18,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    ),
    home: Scaffold(
      appBar: AppBar(title: Text('Flutter Demo')),
      body: Center(
        child: LoginForm(),
      ),
    ),
  ));
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    String identifier = _emailController.text; // can be username or email
    String password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both username/email and password'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Updated: Use the correct JWT login endpoint
    final url = Uri.parse('http://127.0.0.1:8000/registration/api/token/');
    final body = {
      'username': identifier,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access'];
        final refreshToken = data['refresh'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Token saved.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage_JMSD()),
        );
      } else {
        String errorMsg = 'Login failed';
        try {
          final error = jsonDecode(response.body);
          errorMsg = error['detail'] ?? error.toString();
        } catch (e) {
          errorMsg = response.body;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error')),
      );
    }
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/Login.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        Text(
          'Sign In',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Please enter your details'),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Username or Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
              ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _handleSignUp,
          child: Text('Sign Up'),
        ),
      ],
    );
  }
}