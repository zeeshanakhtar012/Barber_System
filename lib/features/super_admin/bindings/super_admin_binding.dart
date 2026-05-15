import 'package:get/get.dart';
import 'package:barber_saas/features/super_admin/controllers/super_admin_controller.dart';

class SuperAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminController>(() => SuperAdminController());
  }
}
