import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/core/services/notification_service.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class NotificationsView extends GetView<NotificationService> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Obx(() => controller.unreadCount.value > 0 
                  ? TextButton(
                      onPressed: () => controller.markAllAsRead(),
                      child: const Text('Mark all as read', style: TextStyle(color: Colors.amber)),
                    )
                  : const SizedBox.shrink()
                )
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No notifications yet.', style: TextStyle(color: Colors.white54))),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notif = controller.notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        if (!notif.isRead) controller.markAsRead(notif.id);
                      },
                      child: GlassContainer(
                        opacity: notif.isRead ? 0.05 : 0.2,
                        child: ListTile(
                          leading: Icon(
                            notif.type == 'system' ? Icons.info_outline : Icons.notifications,
                            color: notif.isRead ? Colors.white38 : Colors.amber,
                          ),
                          title: Text(notif.title, style: TextStyle(color: notif.isRead ? Colors.white70 : Colors.white, fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(notif.body, style: TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: notif.isRead 
                            ? null 
                            : const Icon(Icons.circle, color: Colors.amber, size: 12),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
