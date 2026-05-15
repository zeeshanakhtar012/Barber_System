import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class BarberBreaksView extends GetView<BarberController> {
  const BarberBreaksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassContainer(
              opacity: 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manage Shop Breaks', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Starting a break pauses the queue and delays future appointments temporarily.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Obx(() {
                    final isShopOnBreak = controller.currentShop.value?.status == 'BREAK';
                    if (isShopOnBreak) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            controller.updateShopStatus('OPEN');
                            Get.snackbar('Shop Reopened', 'The queue has resumed.');
                          },
                          child: const Text('End Break & Open Shop', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            controller.updateShopStatus('BREAK');
                            Get.snackbar('Shop on Break', 'The queue is paused.');
                          },
                          child: const Text('Start Temporary Break', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
