import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/features/super_admin/controllers/super_admin_controller.dart';
import 'package:barber_saas/features/super_admin/views/super_admin_customers_view.dart';
import 'package:barber_saas/shared/views/notifications_view.dart';
import 'package:barber_saas/core/services/notification_service.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class SuperAdminDashboardView extends GetView<SuperAdminController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        actions: [
          IconButton(
            icon: Obx(() {
              final count = Get.find<NotificationService>().unreadCount.value;
              if (count > 0) {
                return Badge(
                  label: Text(count.toString()),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.notifications_active, color: Colors.amber),
                );
              }
              return const Icon(Icons.notifications_outlined, color: Colors.white70);
            }),
            onPressed: () {
              Get.bottomSheet(const NotificationsView(), isScrollControlled: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Get.find<AuthController>().logout(),
          )
        ],
      ),
      body: Obx(() => IndexedStack(
        index: currentIndex.value,
        children: [
          _buildShopsFeed(context),
          const SuperAdminCustomersView(),
        ],
      )),
      floatingActionButton: Obx(() => currentIndex.value == 0 
        ? FloatingActionButton(
            backgroundColor: Colors.amber,
            onPressed: () => _showAddShopDialog(context),
            child: const Icon(Icons.add, color: Colors.black),
          ) 
        : const SizedBox.shrink()
      ),
      bottomNavigationBar: Obx(() => Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12, width: 1))),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E2C),
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white54,
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Customers'),
          ],
        ),
      )),
    );
  }

  Widget _buildShopsFeed(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Obx(() {
        if (controller.shops.isEmpty) {
          return const Center(child: Text('No Barber Shops yet.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.shops.length,
          itemBuilder: (context, index) {
            final shop = controller.shops[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GlassContainer(
                opacity: 0.1,
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.store, color: Colors.black)),
                  title: Text(shop.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${shop.status} | Sub: ${shop.subscriptionStatus}', style: const TextStyle(color: Colors.white70)),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'suspend') {
                        controller.suspendShop(shop.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddShopDialog(BuildContext context) {
    final shopNameCtrl = TextEditingController();
    final adminNameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: GlassContainer(
            opacity: 0.2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Barber Shop', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(shopNameCtrl, 'Shop Name'),
                const SizedBox(height: 8),
                _buildTextField(adminNameCtrl, 'Admin Name'),
                const SizedBox(height: 8),
                _buildTextField(adminEmailCtrl, 'Admin Email'),
                const SizedBox(height: 8),
                _buildTextField(adminPassCtrl, 'Admin Password', obscure: true),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  onPressed: controller.isLoading.value ? null : () {
                    debugPrint('LOG [UI]: Create Shop button tapped');
                    controller.createBarberShopWithAdmin(
                      shopNameCtrl.text.trim(),
                      adminEmailCtrl.text.trim(),
                      adminPassCtrl.text.trim(),
                      adminNameCtrl.text.trim(),
                    );
                  },
                  child: controller.isLoading.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black)) 
                    : const Text('Create Shop'),
                ))
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      ),
    );
  }
}


