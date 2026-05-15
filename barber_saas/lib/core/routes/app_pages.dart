import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/core/routes/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    // Additional pages will be added here
  ];
}
