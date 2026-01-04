import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_generator/pages/update_password.dart';
import 'package:password_generator/widgets/widget_button.dart';

import '../apis/backend.dart';

class ManualPassword extends StatefulWidget {
  const ManualPassword({super.key});

  @override
  ManualPasswordState createState() {
    return ManualPasswordState();
  }
}

class ManualPasswordState extends State<ManualPassword> {
  final _formKey = GlobalKey<FormState>();

  String _site = "";
  String _usernameEmail = "";
  String _password = "";
  String _confirmPassword = "";

  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _usernameEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  void dispose() {
    _siteController.dispose();
    _usernameEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _getEnteredText() {
    setState(() {
      _site = _siteController.text;
      _usernameEmail = _usernameEmailController.text;
      _password = _passwordController.text;
      _confirmPassword = _confirmPasswordController.text;
    });
  }


  void showPasswordDialog(BuildContext context) {
    // Example data from API
    const String apiUsername = "user123";
    const String apiPassword = "password123";
    const String apiEncryptedPassword = "encrypted123";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your Credentials'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: apiUsername),
                  decoration: const InputDecoration(labelText: "Username"),
                  enabled: false,
                ),
                TextField(
                  controller: TextEditingController(text: apiPassword),
                  decoration: const InputDecoration(labelText: "Password"),
                  enabled: false,
                ),
                TextField(
                  controller: TextEditingController(text: apiEncryptedPassword),
                  decoration: const InputDecoration(labelText: "Encrypted Password"),
                  enabled: false,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPasswordBottomSheet(BuildContext context, String site, String username, String password, String enPassword) {
    String apiAppName = site;
    String apiUsername = username;
    String apiPassword = password;
    String apiEncryptedPassword = enPassword;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          )),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: TextEditingController(text: apiAppName),
                    decoration: const InputDecoration(labelText: "Site/App"),
                    enabled: false,
                  ),
                  TextField(
                    controller: TextEditingController(text: apiUsername),
                    decoration: const InputDecoration(labelText: "Username"),
                    enabled: false,
                  ),
                  TextField(
                    controller: TextEditingController(text: apiPassword),
                    decoration: const InputDecoration(labelText: "Password"),
                    enabled: false,
                  ),
                  TextField(
                    controller: TextEditingController(text: apiEncryptedPassword),
                    decoration: const InputDecoration(labelText: "Encrypted Password", labelStyle: TextStyle(overflow: TextOverflow.ellipsis,),),
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String errorName, String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorName),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(errorMessage),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CustomThemeButton(onPressed: () {
                      Navigator.of(context).pop();
                    }, text: 'Go Back',),
                    const SizedBox(width: 5,),
                    CustomThemeButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Update_Password(site: _site, username: _usernameEmail))); }, text: 'Update Password',),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future savePasswordManually(BuildContext context) async {

    _getEnteredText();
    String option = "add";
    final res = await Backend.save_password(_site, _usernameEmail, _password, 'Shazil24.', option);

    if (res.statusCode == 200) {
      setState(() {
        List<String> response = List<String>.from(jsonDecode(res.body));

        if (kDebugMode) {
          print(response);
        }

        showPasswordBottomSheet(context, response[0], response[1], response[2], response[3]);
      });
    } else {
      final Map<String, dynamic> errorData = jsonDecode(res.body);
      await showErrorDialog(context, errorData['name'], errorData['message']);

    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Manual Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Please fill out the form below:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _siteController,
                    decoration: const InputDecoration(
                      labelText: 'Site',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a site';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Username/Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username or email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email or username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomThemeButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          savePasswordManually(context);
                        }
                      },
                      text: 'Submit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
