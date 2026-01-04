import 'package:flutter/material.dart';
import 'package:password_generator/global/globals.dart' as globals;

class MyListView extends StatefulWidget {
  MyListView({super.key}) {
    // Initialize the items list asynchronously in the constructor
    // _initializeItems();
  }

  @override
  State<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  Widget makeListTile(String sitesData) => ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border:
                Border(right: BorderSide(width: 1.0, color: Colors.white24))),
        child: const Icon(Icons.autorenew, color: Colors.white),
      ),
      title: const Text(
        "New Site",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: <Widget>[
          const Icon(Icons.linear_scale, color: Colors.yellowAccent),
          Text(sitesData, style: const TextStyle(color: Colors.white))
        ],
      ),
      trailing: const Icon(Icons.keyboard_arrow_right,
          color: Colors.white, size: 30.0));

  @override
  Widget build(BuildContext context) {
    // final makeCard =

    return ListView.builder(
      itemCount: globals.sites.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: makeListTile(globals.sites[index]),
          ),
        );
      },
    );
  }
}
