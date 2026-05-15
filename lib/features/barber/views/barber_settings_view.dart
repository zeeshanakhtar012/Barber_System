import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class BarberSettingsView extends GetView<BarberController> {
  BarberSettingsView({super.key});

  final TextEditingController openTimeCtrl = TextEditingController();
  final TextEditingController closeTimeCtrl = TextEditingController();
  final TextEditingController maxQueueCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialize controllers from current shop data
    ever(controller.currentShop, (shop) {
      if (shop != null) {
        openTimeCtrl.text = shop.openingTime;
        closeTimeCtrl.text = shop.closingTime;
        maxQueueCtrl.text = shop.maxQueue.toString();
      }
    });

    if (controller.currentShop.value != null) {
      openTimeCtrl.text = controller.currentShop.value!.openingTime;
      closeTimeCtrl.text = controller.currentShop.value!.closingTime;
      maxQueueCtrl.text = controller.currentShop.value!.maxQueue.toString();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          opacity: 0.15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shop Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildTextField(openTimeCtrl, 'Opening Time (e.g. 09:00)', Icons.access_time),
              const SizedBox(height: 16),
              _buildTextField(closeTimeCtrl, 'Closing Time (e.g. 18:00)', Icons.access_time_filled),
              const SizedBox(height: 16),
              _buildTextField(maxQueueCtrl, 'Max Queue Capacity', Icons.people_alt, isNumber: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: controller.isLoading.value ? null : () {
                    controller.updateShopSettings(
                      openTimeCtrl.text.trim(),
                      closeTimeCtrl.text.trim(),
                      int.tryParse(maxQueueCtrl.text.trim()) ?? 10,
                    );
                  },
                  child: controller.isLoading.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController textController, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: textController,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
