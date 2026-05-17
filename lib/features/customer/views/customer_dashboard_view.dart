import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/features/customer/controllers/customer_controller.dart';
import 'package:barber_saas/features/customer/views/my_bookings_view.dart';
import 'package:barber_saas/shared/views/notifications_view.dart';
import 'package:barber_saas/core/services/notification_service.dart';
import 'package:barber_saas/core/config/app_config.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class CustomerDashboardView extends GetView<CustomerController> {
  const CustomerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Obx(() => Text(
          controller.selectedShop.value?.name ?? 'Book Appointment',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        )),
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        actions: [
          Obx(() {
            if (AppConfig.targetShopId == null && controller.preferredShopId.value != null) {
              return IconButton(
                icon: const Icon(Icons.store, color: Colors.amber),
                tooltip: 'Switch Barber Shop',
                onPressed: () => controller.clearPreferredShop(),
              );
            }
            return const SizedBox.shrink();
          }),
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
          (AppConfig.targetShopId != null || controller.preferredShopId.value != null)
              ? _buildDirectBookingFeed(context)
              : _buildShopsFeed(context),
          const MyBookingsView(),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E2C),
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white54,
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.cut),
              label: (AppConfig.targetShopId != null || controller.preferredShopId.value != null)
                  ? 'Book Now'
                  : 'Shops',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Bookings'),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search barber shops...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      // Filters available shops dynamically
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _showJoinShopDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.availableShops.isEmpty) {
                return const Center(child: Text('No Barber Shops available currently.', style: TextStyle(color: Colors.white70)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableShops.length,
                itemBuilder: (context, index) {
                  final shop = controller.availableShops[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassContainer(
                      opacity: 0.15,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.storefront, color: Colors.amber, size: 32),
                        ),
                        title: Text(shop.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 10, color: shop.status == 'OPEN' ? Colors.greenAccent : Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(shop.status, style: const TextStyle(color: Colors.white70)),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 12, color: Colors.white54),
                              const SizedBox(width: 4),
                              Text('${shop.openingTime} - ${shop.closingTime}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber, 
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: () {
                            controller.setPreferredShop(shop.id);
                          },
                          child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
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

  void _showJoinShopDialog(BuildContext context) {
    final TextEditingController linkCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect via Shop Link',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste the shop invite URL or Shop ID shared by your barber shop to lock onto their live queue!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: linkCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Invite URL or Shop ID',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'e.g. barberspace://shop/6a09996b...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  enabledBorder: OutlineInputBorder(
                     borderSide: const BorderSide(color: Colors.white30),
                     borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                     borderSide: const BorderSide(color: Colors.amber),
                     borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final text = linkCtrl.text.trim();
                      if (text.isEmpty) return;
                      
                      String shopId = text;
                      if (text.contains('/shop/')) {
                        shopId = text.split('/shop/').last;
                      }
                      
                      Get.back();
                      controller.setPreferredShop(shopId);
                      Get.snackbar('Connected', 'Successfully connected to Barber Shop!', backgroundColor: Colors.greenAccent, colorText: Colors.black);
                    },
                    child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectBookingFeed(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Obx(() {
        final shop = controller.selectedShop.value;
        if (shop == null) return const Center(child: CircularProgressIndicator(color: Colors.amber));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            opacity: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(shop.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Live Estimated Wait Time: ${controller.estimatedWaitTime.value} mins', style: const TextStyle(color: Colors.amber, fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Select Services:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                if (controller.shopServices.isEmpty)
                  const Text('Loading services...', style: TextStyle(color: Colors.white54))
                else
                  Wrap(
                    spacing: 8.0,
                    children: controller.shopServices.map((service) {
                      final isSelected = controller.selectedServices.contains(service);
                      return FilterChip(
                        label: Text('${service.name} - \$${service.price}'),
                        selected: isSelected,
                        selectedColor: Colors.amber,
                        checkmarkColor: Colors.black,
                        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                        backgroundColor: Colors.black26,
                        onSelected: (_) => controller.toggleService(service),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: controller.selectedServices.isEmpty || controller.isLoading.value ? null : () {
                      controller.bookAppointment();
                    },
                    child: controller.isLoading.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black)) 
                      : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

