import 'package:get/get.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';

class BarberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BarberController>(() => BarberController());
  }
}
