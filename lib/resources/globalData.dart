class GlobalData {
  static GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  
  GlobalData._internal();
  int notificationsAmount;
}