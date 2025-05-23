import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool loading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        setState(() {
          errorMsg = "Not logged in!";
          loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/registration/api/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          errorMsg = "Failed to load profile: ${response.body}";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Error: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: Text(errorMsg)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData == null
            ? Text("No data")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Username: ${userData!['username'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Email: ${userData!['email'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("First Name: ${userData!['first_name'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Last Name: ${userData!['last_name'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
                ],
              ),
      ),
    );
  }
}