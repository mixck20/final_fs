import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://127.0.0.1:8000/registration/api/register/');

    final Map<String, dynamic> requestData = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'confirm_password': _confirmPasswordController.text,
      'date_of_birth': _dobController.text,
      'gender': _genderController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: "First Name"),
                  validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: "Last Name"),
                  validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) => value!.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Enter password' : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Confirm password' : null,
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
                  validator: (value) => value!.isEmpty ? 'Enter date of birth' : null,
                ),
                TextFormField(
                  controller: _genderController,
                  decoration: InputDecoration(labelText: "Gender (optional)"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createUser,
                  child: Text('Create User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}