// import 'dart:html';

// import 'dart:js';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../apis/backend.dart';
import '../widgets/Constants.dart';
import '../widgets/widget_button.dart';

class UpdateGenerator extends StatefulWidget {
  final String site;
  final String username;


  const UpdateGenerator({super.key, required this.site, required this.username});

  @override
  State<UpdateGenerator> createState() => _UpdateGeneratorState();
}

class _UpdateGeneratorState extends State<UpdateGenerator> {
  // ignore: unused_field
  String _response = "";
  final _formKey = GlobalKey<FormState>();

  // Text Field Data
  String _site = "";
  String _username = "";
  String _passwordLength = "";
  String _password = "";
  final String _verificationPassword = "";

  // Decryption pass button show and hide functionality
  bool showButton = false;
  bool _isBottomSheetOpen = false;

  // Dynamic storing for text field data
  final TextEditingController _textController3 = TextEditingController();
  final TextEditingController _textController4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _site = widget.site;
    _username = widget.username;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    _textController3.dispose();
    _textController4.dispose();
  }

  void _getEnteredText() {
    setState(() {
      _site = widget.site;
      _username = widget.username;
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
                                text: 'Save Password', onPressed: () => updatePassword(context)),
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

  void showPasswordBottomSheet(BuildContext context, String site, String username, String password, String enPassword) {
    String apiAppName = site;
    String apiUsername = username;
    String apiPassword = password;
    String apiEncryptedPassword = enPassword;

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
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future updatePassword(BuildContext context) async {

    _getEnteredText();
    String option = "update";
    final res = await Backend.save_password(_site, _username, _password, 'Shazil24.', option);

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
  Future createPassword(BuildContext context) async {

    _getEnteredText();
    final res =
    await Backend.generate_password(_site, _username, _passwordLength);

    if (res.statusCode == 200) {
      setState(() {
        _password = 'POST request successful: ${res.body}';
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => UpdateGenerator_Complete(message: res.body)));
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
        title: const Text('Password UpdateGenerator'),
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
                    controller: TextEditingController(text: _site),
                    decoration: const InputDecoration(
                      labelText: 'Site',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: TextEditingController(text: _username),
                    decoration: const InputDecoration(
                      labelText: 'Username/Email',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
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

