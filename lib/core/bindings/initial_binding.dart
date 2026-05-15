import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/core/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
  }
}


