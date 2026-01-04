// import 'dart:html';

// import 'dart:js';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_generator/widgets/Constants.dart';
import '../apis/backend.dart';
import '../widgets/widget_button.dart';

class Generator extends StatefulWidget {
  const Generator({super.key});

  @override
  State<Generator> createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator> {
  // ignore: unused_field
  String _response = "";
  final _formKey = GlobalKey<FormState>();

  // Text Field Data
  String _site = "";
  String _username = "";
  String _passwordLength = "";
  final String _verificationPassword = "";

  // Decryption pass button show and hide functionality
  bool showButton = false;
  bool _isBottomSheetOpen = false;

  // Dynamic storing for text field data
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();
  final TextEditingController _textController3 = TextEditingController();
  final TextEditingController _textController4 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController1.dispose();
    _textController2.dispose();
    _textController3.dispose();
    _textController4.dispose();
    super.dispose();
  }

  void _getEnteredText() {
    setState(() {
      _site = _textController1.text;
      _username = _textController2.text;
      _passwordLength = _textController3.text;
    });

    if (kDebugMode) {
      print('$_site\n$_username\n$_passwordLength');
    }
  }

  void completeState(BuildContext context, String password) {
    if (_isBottomSheetOpen) {
      Navigator.pop(context);
      _isBottomSheetOpen = false;
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          )
        ),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            _isBottomSheetOpen = true;
            return SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 15.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: TextEditingController(text: _site),
                        decoration: const InputDecoration(
                            labelText: "Site/App"),
                        enabled: false,
                      ),
                      TextField(
                        controller: TextEditingController(text: _username),
                        decoration: const InputDecoration(
                            labelText: "Username"),
                        enabled: false,
                      ),
                      TextField(
                        controller: TextEditingController(text: password),
                        decoration: const InputDecoration(
                            labelText: "Password"),
                        enabled: false,
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomThemeButton(text: 'Try Again', onPressed: () {
                            createPassword(context);
                          }),
                          CustomThemeButton(
                              text: 'Save Password', onPressed: () => {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        )
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  Future createPassword(BuildContext context) async {

    _getEnteredText();
    final res =
        await Backend.generate_password(_site, _username, _passwordLength);

    if (res.statusCode == 200) {
      setState(() {
        _response = 'POST request successful: ${res.body}';
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => Generator_Complete(message: res.body)));
        completeState(context, res.body);
      });
    } else {
      setState(() {
        _response = 'Error: ${res.statusCode}';
      });
    }

    if (kDebugMode) {
      print(_response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.secondaryColor,
      appBar: AppBar(
        title: const Text('Password Generator'),
        backgroundColor: TColors.secondaryColor,
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
                      controller: _textController1,
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
                      controller: _textController2,
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
                      controller: _textController3,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Password Length',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {

                        if (value == null || value.isEmpty) {
                          return 'Please enter a Password Length';
                        }
                        if (int.parse(value) < 8 || int.parse(value) > 20) {
                          return 'Password must be between 8 and 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20,),
                    Visibility(
                      visible: showButton,
                      child: TextFormField(
                        controller: _textController4,
                        decoration: const InputDecoration(
                          labelText: 'Verification Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a verification Password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomThemeButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createPassword(context);
                          }
                        },
                        text: 'Generate Password',
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

// ignore: camel_case_types, must_be_immutable
class Generator_Complete extends StatelessWidget {
  String message;

  Generator_Complete({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
