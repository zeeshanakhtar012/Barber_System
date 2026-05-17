import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_saas/core/routes/app_routes.dart';
import 'package:barber_saas/features/customer/controllers/customer_controller.dart';

class ShopDeepLinkHandler extends StatefulWidget {
  const ShopDeepLinkHandler({super.key});

  @override
  State<ShopDeepLinkHandler> createState() => _ShopDeepLinkHandlerState();
}

class _ShopDeepLinkHandlerState extends State<ShopDeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  void _handleDeepLink() async {
    final String? shopId = Get.parameters['id'];
    if (shopId != null && shopId.isNotEmpty) {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString('preferred_shop_id', shopId);

      // If CustomerController is already registered, update its state
      if (Get.isRegistered<CustomerController>()) {
        final controller = Get.find<CustomerController>();
        controller.preferredShopId.value = shopId;
        controller.setPreferredShop(shopId);
      }
    }
    // Route back to splash/dashboard for clean session validation and routing
    Get.offAllNamed(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Connecting to Barber Shop...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
