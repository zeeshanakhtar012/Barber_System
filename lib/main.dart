import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_saas/firebase_options.dart';
import 'package:barber_saas/core/bindings/initial_binding.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/core/network/socket_client.dart';
import 'package:barber_saas/data/providers/storage_provider.dart';
import 'package:barber_saas/core/routes/app_pages.dart';
import 'package:barber_saas/core/routes/app_routes.dart';
import 'package:barber_saas/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(sharedPreferences, permanent: true);
  Get.put<StorageProvider>(StorageProvider(), permanent: true);

  // Initialize Network Clients
  final apiClient = ApiClient();
  await apiClient.init();
  Get.put<ApiClient>(apiClient, permanent: true);

  final socketClient = SocketClient();
  await socketClient.init();
  Get.put<SocketClient>(socketClient, permanent: true);

  runApp(const BarberSaaSApp());
}

class BarberSaaSApp extends StatelessWidget {
  const BarberSaaSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Barber SaaS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
