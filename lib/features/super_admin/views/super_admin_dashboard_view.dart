import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/features/super_admin/controllers/super_admin_controller.dart';
import 'package:barber_saas/features/super_admin/views/super_admin_customers_view.dart';
import 'package:barber_saas/shared/views/notifications_view.dart';
import 'package:barber_saas/core/services/notification_service.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';
import 'package:barber_saas/data/models/shop_model.dart';

class SuperAdminDashboardView extends GetView<SuperAdminController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text(
          'Super Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.amber,
                  ),
                );
              }
              return const Icon(
                Icons.notifications_outlined,
                color: Colors.white70,
              );
            }),
            onPressed: () {
              Get.bottomSheet(
                const NotificationsView(),
                isScrollControlled: true,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: currentIndex.value,
          children: [_buildShopsFeed(context), const SuperAdminCustomersView()],
        ),
      ),
      floatingActionButton: Obx(
        () => currentIndex.value == 0
            ? FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: () => _showAddShopDialog(context),
                child: const Icon(Icons.add, color: Colors.black),
              )
            : const SizedBox.shrink(),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF1E1E2C),
            selectedItemColor: Colors.amber,
            unselectedItemColor: Colors.white54,
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt),
                label: 'Customers',
              ),
            ],
          ),
        ),
      ),
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
          return const Center(
            child: Text(
              'No Barber Shops yet.',
              style: TextStyle(color: Colors.white70),
            ),
          );
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
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.store, color: Colors.black),
                  ),
                  title: Text(
                    shop.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Status: ${shop.status} | Sub: ${shop.subscriptionStatus}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditShopDialog(context, shop);
                      } else if (value == 'suspend') {
                        controller.suspendShop(shop.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Edit Details',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(
                              Icons.block,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Suspend',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
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
                const Text(
                  'Add Barber Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(shopNameCtrl, 'Shop Name'),
                const SizedBox(height: 8),
                _buildTextField(adminNameCtrl, 'Admin Name'),
                const SizedBox(height: 8),
                _buildTextField(adminEmailCtrl, 'Admin Email'),
                const SizedBox(height: 8),
                _buildTextField(adminPassCtrl, 'Admin Password', obscure: true),
                const SizedBox(height: 16),
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            debugPrint('LOG [UI]: Create Shop button tapped');
                            controller.createBarberShopWithAdmin(
                              shopNameCtrl.text.trim(),
                              adminEmailCtrl.text.trim(),
                              adminPassCtrl.text.trim(),
                              adminNameCtrl.text.trim(),
                            );
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : const Text('Create Shop'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, ShopModel shop) {
    final shopNameCtrl = TextEditingController(text: shop.name);
    final shopAddressCtrl = TextEditingController(text: shop.address);
    final shopPhoneCtrl = TextEditingController(text: shop.phone);
    final shopLogoCtrl = TextEditingController(text: shop.logo);
    final shopOpeningCtrl = TextEditingController(text: shop.openingTime);
    final shopClosingCtrl = TextEditingController(text: shop.closingTime);
    final maxQueueCtrl = TextEditingController(text: shop.maxQueue.toString());
    final RxString selectedStatus = shop.status.obs;
    final RxString selectedSubscription = shop.subscriptionStatus.obs;

    final adminNameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final adminPhoneCtrl = TextEditingController();
    final adminAvatarCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: GlassContainer(
              opacity: 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Shop & Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),

                  // Shop Details Section
                  const Row(
                    children: [
                      Icon(Icons.store, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'STORE DETAILS',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(shopNameCtrl, 'Shop Name'),
                  const SizedBox(height: 8),
                  _buildTextField(shopAddressCtrl, 'Address'),
                  const SizedBox(height: 8),
                  _buildTextField(shopPhoneCtrl, 'Shop Phone'),
                  const SizedBox(height: 8),
                  _buildTextField(shopLogoCtrl, 'Logo URL'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          shopOpeningCtrl,
                          'Open Time (HH:MM)',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          shopClosingCtrl,
                          'Close Time (HH:MM)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(maxQueueCtrl, 'Max Queue Size'),
                  const SizedBox(height: 12),

                  // Dropdowns for Status and Subscription
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: selectedStatus.value,
                            dropdownColor: const Color(0xFF2D2D44),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                            ),
                            items: ['OPEN', 'CLOSED']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => selectedStatus.value = val!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: selectedSubscription.value,
                            dropdownColor: const Color(0xFF2D2D44),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Subscription',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                            ),
                            items: ['active', 'suspended', 'trial', 'expired']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                selectedSubscription.value = val!,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24, height: 24),

                  // Admin Details Section
                  const Row(
                    children: [
                      Icon(Icons.person, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'ADMIN USER DETAILS',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    adminNameCtrl,
                    'Admin Name (Leave empty to keep current)',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    adminEmailCtrl,
                    'Admin Email (Leave empty to keep current)',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    adminPhoneCtrl,
                    'Admin Phone (Leave empty to keep current)',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    adminAvatarCtrl,
                    'Profile Photo URL (Leave empty to keep current)',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    adminPassCtrl,
                    'New Password (Leave empty to keep current)',
                    obscure: true,
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  Obx(
                    () => ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: const Text(
                        'Save Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              // 1. Gather Shop details and update
                              final Map<String, dynamic> shopUpdate = {
                                'name': shopNameCtrl.text.trim(),
                                'address': shopAddressCtrl.text.trim(),
                                'phone': shopPhoneCtrl.text.trim(),
                                'logo': shopLogoCtrl.text.trim(),
                                'openingTime': shopOpeningCtrl.text.trim(),
                                'closingTime': shopClosingCtrl.text.trim(),
                                'maxQueue':
                                    int.tryParse(maxQueueCtrl.text.trim()) ??
                                    10,
                                'status': selectedStatus.value,
                                'subscriptionStatus':
                                    selectedSubscription.value,
                              };

                              // 2. Gather Admin details (only those filled)
                              final Map<String, dynamic> adminUpdate = {};
                              if (adminNameCtrl.text.trim().isNotEmpty) {
                                adminUpdate['name'] = adminNameCtrl.text.trim();
                              }
                              if (adminEmailCtrl.text.trim().isNotEmpty) {
                                adminUpdate['email'] = adminEmailCtrl.text
                                    .trim()
                                    .toLowerCase();
                              }
                              if (adminPhoneCtrl.text.trim().isNotEmpty) {
                                adminUpdate['phone'] = adminPhoneCtrl.text
                                    .trim();
                              }
                              if (adminAvatarCtrl.text.trim().isNotEmpty) {
                                adminUpdate['avatar'] = adminAvatarCtrl.text
                                    .trim();
                              }
                              if (adminPassCtrl.text.trim().isNotEmpty) {
                                adminUpdate['password'] = adminPassCtrl.text
                                    .trim();
                              }

                              // Execute updates
                              await controller.updateShopDetails(
                                shop.id,
                                shopUpdate,
                              );
                              if (adminUpdate.isNotEmpty) {
                                await controller.updateShopAdminDetails(
                                  shop.id,
                                  adminUpdate,
                                );
                              }

                              Get.back(); // Close the dialog
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}
