import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../apis/backend.dart';
import '../widgets/Constants.dart';


class ShowPasswordPage extends StatefulWidget {
  const ShowPasswordPage({super.key});

  @override
  State<ShowPasswordPage> createState() => _ShowPasswordPageState();
}

class _ShowPasswordPageState extends State<ShowPasswordPage> {

  final TextEditingController _sitesEditingController = TextEditingController();
  List<dynamic> siteDataList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    List<dynamic> results = [];
    results = [];
    Backend.getSites().then((value) {
      results  = value;
      setState(() {
        siteDataList = results;
      });
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
        Backend.getSites().then((value) {
          results  = value;
          setState(() {
            siteDataList = results;
          });
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
  Future<void> getUsernameAndPassword(BuildContext context, String selectedSite) async {
    List<dynamic> usernameAndPasswords = [];
    final res = await Backend.getPassword(selectedSite, 'Shazil24.');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      final List<dynamic> value = data;

      if (kDebugMode) {
        print(value);
      }
      setState(() {
        usernameAndPasswords = value;
      });
      showPasswordBottomSheet(context, selectedSite, usernameAndPasswords);
    }

  }

  void showPasswordBottomSheet(BuildContext context, String site, List<dynamic> usernameAndPassword) {
    String apiAppName = site;
    // String apiUsername = username;
    // String apiPassword = password;
    List<dynamic> apiUsernameAndPassword = usernameAndPassword;
    final PageController controller = PageController();
    int currentPage = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) => SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 300, // Set a height for the PageView
                  child: PageView.builder(
                      itemCount: apiUsernameAndPassword.length,
                      controller: controller,
                      onPageChanged: (int index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            TextField(
                              controller: TextEditingController(
                                  text: apiAppName),
                              decoration: const InputDecoration(
                                  labelText: "Site/App"),
                              enabled: false,
                            ),
                            TextField(
                              controller: TextEditingController(
                                  text: apiUsernameAndPassword[index]['userName']),
                              decoration: const InputDecoration(
                                  labelText: "Username"),
                              enabled: false,
                            ),
                            TextField(
                              controller: TextEditingController(
                                  text: apiUsernameAndPassword[index]['password']),
                              decoration: const InputDecoration(
                                  labelText: "Password"),
                              enabled: false,
                            ),
                          ],
                        );
                      }// Add more pages if needed
                  ),
                ),
                // Optional: Add an indicator or other UI elements
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SmoothPageIndicator(
                    controller: controller,  // Use the same controller here
                    count: apiUsernameAndPassword.length, // Number of pages
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: TColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clearSearch() {
    _sitesEditingController.clear();
    setState(() {
      siteDataList = [];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Display Password'),),
      body:
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const Text('Select the Site to Update Password',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600, color: TColors.primaryColor),),
              const SizedBox(height: 12,),
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
                height: MediaQuery.of(context).size.height,
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
                          title: TextButton(
                            child: Text(siteDataList[index]),
                            onPressed: () {
                              getUsernameAndPassword(context, siteDataList[index]);
                            },
                          ),
                          leading: const Icon(Icons.wifi),
                          trailing: const Icon(Icons.arrow_forward_ios_outlined),

                        );
                      }),
                ),
              ) :
              const Center(
                heightFactor: 10,
                child: Text('No Data Found'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
