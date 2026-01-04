import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_generator/apis/backend.dart';
import 'package:password_generator/pages/show_password_page.dart';
import 'package:password_generator/pages/generator.dart';
import 'package:password_generator/pages/update_password_page.dart';
import 'package:password_generator/widgets/Constants.dart';
import '../widgets/NavigatorIcon.dart';
import 'manual_password.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final List<List<dynamic>> navigatorList = [
    ["Password Generator", Icons.enhanced_encryption, const Generator()],
    ["Show Password", Icons.visibility, const ShowPasswordPage()],
    ["Save Password Manually", Icons.add_circle_outline, const ManualPassword()],
    ["Update Password", Icons.update, const UpdatePasswordPage()]
  ];

  List<dynamic> siteDataList = [];
  final String _site_name = "";
  final String _verifyPassword = "";
  final TextEditingController _sitesEditingController = TextEditingController();
  final TextEditingController _verifyPasswordControler = TextEditingController();
  late List<dynamic> usernameAndPasswords = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    siteDataList = [];
  }

  _getEnteredText(String key, String value) {
    setState(() {
      key = value;
    });

  }

  void searchSites(String enteredText) {
    List<dynamic> results = [];
    // If there's an existing timer, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if(kDebugMode) {
      print(enteredText);
    }
    _debounce = Timer(const Duration(seconds: 1), () {
      if (enteredText.isEmpty) {
        results = [];
        setState(() {
          siteDataList = results;
        });
      } else {
        Backend.getSelectedSites(enteredText).then((value) {
          results = value;
          setState(() {
            siteDataList = results;
          });
        });
      }

    }
    );

  }

  void clearSearch() {
    _sitesEditingController.clear();
    setState(() {
      siteDataList = [];
    });
  }

  Future<void> getPassword(BuildContext context, String site, String verifyPassword) async {
    _getEnteredText(_verifyPassword, _verifyPasswordControler.text);
    final res = await Backend.getPassword(site, verifyPassword);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      final List<dynamic> value = data;

      if (kDebugMode) {
        print(value);
      }
      setState(() {
        usernameAndPasswords = value;
      });

    }

  }


  verifyDialogScreen() {
    // Example data from API
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify your Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: "Enter Password"),
                  enabled: false,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );

  }



  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the timer when disposing the widget
    _sitesEditingController.dispose(); // Don't forget to dispose of the TextEditingController!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi Shazail',
                      style: TextStyle(
                          backgroundColor: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: TColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/profile.png'),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shazil Sohail', style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w800),),
                                Text('Password Generator', style: TextStyle(color: Colors.white),),
                              ],
                            )
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Divider(
                      height: 25,
                      color: Colors.black54,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                        alignment: FractionalOffset.centerLeft,
                        child: const Text('generate safe passwords', style: TextStyle(color: Colors.white),)),
                  ]),
                ),
                const SizedBox(
                  height: 30,
                ),
                // navigation icons
                SizedBox(
                  height: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return NavigatorIcon(title: navigatorList[index][0], icon: navigatorList[index][1],onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => navigatorList[index][2]));
                          });
                        }),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                // * search bar
                Center(
                  child: TextField(
                    controller: _sitesEditingController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        hintText: 'Search .... ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none
                        ),
                        prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    onChanged: (value) {
                      searchSites(value);
                    },
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Divider(
                    height: 25,
                    color: Colors.black54,
                  ),
                ),
                siteDataList.isNotEmpty ? SizedBox(
                  height: MediaQuery.of(context).size.height/3,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: TColors.secondaryColor,
                      borderRadius: BorderRadius.circular(25),

                    ),
                    child: ListView.builder(
                        itemCount: siteDataList.length,
                        itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(siteDataList[index]),
                        leading: const Icon(Icons.wifi),
                        trailing: const Icon(Icons.arrow_forward_ios_outlined),

                      );
                    }),
                  ),
                ) :
                const Center(
                  heightFactor: 10,
                  child: Text('Sites Data for Username and Password'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



