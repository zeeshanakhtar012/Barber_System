import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class BarberServicesView extends GetView<BarberController> {
  const BarberServicesView({super.key});

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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('Add New Service', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _showAddServiceDialog(context),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.services.isEmpty) {
                return const Center(child: Text('No services added yet.', style: TextStyle(color: Colors.white70)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassContainer(
                      opacity: 0.1,
                      child: ListTile(
                        title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${service.duration} mins', style: const TextStyle(color: Colors.white70)),
                        trailing: Text('\$${service.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          opacity: 0.2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Service', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)))),
              const SizedBox(height: 8),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Duration (mins)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)))),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)))),
              const SizedBox(height: 16),
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: controller.isLoading.value ? null : () {
                  controller.addService(
                    nameCtrl.text.trim(),
                    int.tryParse(durationCtrl.text.trim()) ?? 30,
                    double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                  ).then((_) => Get.back());
                },
                child: const Text('Add', style: TextStyle(color: Colors.black)),
              ))
            ],
          ),
        ),
      )
    );
  }
}
