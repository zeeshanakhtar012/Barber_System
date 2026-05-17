import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/core/routes/app_routes.dart';
import 'package:barber_saas/features/auth/bindings/auth_binding.dart';
import 'package:barber_saas/features/auth/views/login_view.dart';
import 'package:barber_saas/features/auth/views/register_view.dart';
import 'package:barber_saas/features/auth/views/forgot_password_view.dart';
import 'package:barber_saas/features/super_admin/bindings/super_admin_binding.dart';
import 'package:barber_saas/features/super_admin/views/super_admin_dashboard_view.dart';
import 'package:barber_saas/features/barber/bindings/barber_binding.dart';
import 'package:barber_saas/features/barber/views/barber_dashboard_view.dart';
import 'package:barber_saas/features/customer/bindings/customer_binding.dart';
import 'package:barber_saas/features/customer/views/customer_dashboard_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.superAdminDashboard,
      page: () => const SuperAdminDashboardView(),
      binding: SuperAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.barberAdminDashboard,
      page: () => const BarberDashboardView(),
      binding: BarberBinding(),
    ),
    GetPage(
      name: AppRoutes.customerDashboard,
      page: () => const CustomerDashboardView(),
      binding: CustomerBinding(),
    ),
  ];
}

