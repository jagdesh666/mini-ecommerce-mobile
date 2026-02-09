import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _passController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            authProvider.isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    bool success = await authProvider.login(_userController.text, _passController.text);
                    if (success) {
                      Navigator.pop(context); // Login ke baad wapis jayein
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed!")));
                    }
                  },
                  child: Text("Login")
                ),
          ],
        ),
      ),
    );
  }
}