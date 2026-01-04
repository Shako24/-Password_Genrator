class GlobalData {
  static final GlobalData _instance = GlobalData._internal();

  // Any global variables or state you want to manage
  String selectedSite = "";
  List<dynamic> sites = [];

  // Factory constructor
  factory GlobalData() {
    return _instance;
  }

  // Private internal constructor
  GlobalData._internal();
}
