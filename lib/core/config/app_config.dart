class AppConfig {
  /// Leave this as null when you want the app to function as the Master Super Admin tool.
  /// 
  /// To compile a standalone app for the Play Store for a specific barbershop:
  /// Paste the exact Firestore Document ID for that shop below.
  /// Example: static const String? targetShopId = "YOUR_SHOP_ID_HERE";
  static const String? targetShopId = null;
}
