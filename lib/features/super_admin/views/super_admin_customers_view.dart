import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/super_admin/controllers/super_admin_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class SuperAdminCustomersView extends GetView<SuperAdminController> {
  const SuperAdminCustomersView({super.key});

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
      child: Obx(() {
        if (controller.allCustomers.isEmpty) {
          return const Center(child: Text('No customers found.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allCustomers.length,
          itemBuilder: (context, index) {
            final customer = controller.allCustomers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassContainer(
                opacity: 0.1,
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(customer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(customer.email, style: const TextStyle(color: Colors.white70)),
                  trailing: Text(customer.role.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
