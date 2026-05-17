import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/features/barber/views/barber_services_view.dart';
import 'package:barber_saas/features/barber/views/barber_breaks_view.dart';
import 'package:barber_saas/features/barber/views/barber_settings_view.dart';
import 'package:barber_saas/shared/views/notifications_view.dart';
import 'package:barber_saas/core/services/notification_service.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class BarberDashboardView extends GetView<BarberController> {
  const BarberDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentShop.value?.name ?? 'Barber Dashboard',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
          children: [
            _buildLiveQueueFeed(context),
            const BarberServicesView(),
            const BarberBreaksView(),
            BarberSettingsView(),
          ],
        ),
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
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt),
                label: 'Queue',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.design_services),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pause_circle_filled),
                label: 'Breaks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveQueueFeed(BuildContext context) {
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
          _buildStatusHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.todayQueue.isEmpty) {
                return const Center(
                  child: Text(
                    'Queue is empty. Relax!',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.todayQueue.length,
                itemBuilder: (context, index) {
                  final appointment = controller.todayQueue[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassContainer(
                      opacity: 0.15,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: appointment.status == 'in_progress'
                              ? Colors.greenAccent
                              : Colors.amber,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Customer ${appointment.customerId.substring(0, 5)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${appointment.totalDuration} mins • ${appointment.status.toUpperCase()}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            controller.updateAppointmentStatus(
                              appointment.id,
                              value,
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'in_progress',
                              child: Text('Start Service'),
                            ),
                            const PopupMenuItem(
                              value: 'completed',
                              child: Text('Mark Completed'),
                            ),
                            const PopupMenuItem(
                              value: 'no_show',
                              child: Text('No Show'),
                            ),
                          ],
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

  Widget _buildStatusHeader(BuildContext context) {
    return Obx(() {
      final shop = controller.currentShop.value;
      if (shop == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shop Status',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  shop.status,
                  style: TextStyle(
                    color: shop.status == 'OPEN'
                        ? Colors.greenAccent
                        : shop.status == 'BREAK'
                        ? Colors.amber
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              dropdownColor: const Color(0xFF2D2D44),
              value: shop.status,
              items: ['OPEN', 'BREAK', 'CLOSED', 'BUSY']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) controller.updateShopStatus(val);
              },
            ),
          ],
        ),
      );
    });
  }
}
