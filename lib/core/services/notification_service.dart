import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/core/network/socket_client.dart';
import 'package:barber_saas/data/models/notification_model.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';

class NotificationService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.currentUser, (user) {
      if (user != null) {
        _fetchNotifications(user.id);
        
        // Connect real-time notifications namespace
        final socket = Get.find<SocketClient>();
        socket.connectNotifications(user.id);
        
        socket.notificationSocket.off('new_notification');
        socket.notificationSocket.on('new_notification', (data) {
          _fetchNotifications(user.id);
          Get.snackbar(
            data['title'] ?? 'New Alert!',
            data['body'] ?? '',
            backgroundColor: Colors.amber,
            colorText: Colors.black,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.notifications_active, color: Colors.black),
            duration: const Duration(seconds: 4),
          );
        });
      } else {
        notifications.clear();
        unreadCount.value = 0;
        try {
          Get.find<SocketClient>().disconnectNotifications();
        } catch (_) {}
      }
    });
  }

  Future<void> _fetchNotifications(String userId) async {
    try {
      final response = await _apiClient.get('/notifications', queryParameters: {'userId': userId});
      final List<dynamic> data = response.data is Map ? response.data['data'] : response.data;
      final List<NotificationModel> notifs = data
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>, json['_id'] ?? ''))
          .toList();
      notifications.assignAll(notifs);
      unreadCount.value = notifs.where((n) => !n.isRead).length;
    } catch (e) {
      // TODO: handle error appropriately (e.g., logging)
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('/notifications/$notificationId', data: {'isRead': true});
    final user = _authController.currentUser.value;
    if (user != null) {
      _fetchNotifications(user.id);
    }
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (var notif in unread) {
      await markAsRead(notif.id);
    }
  }

  Future<void> sendLocalMockNotification(String title, String body, String userId, String role) async {
    final notif = NotificationModel(
      id: '',
      userId: userId,
      role: role,
      title: title,
      body: body,
      type: 'system',
      isRead: false,
      createdAt: DateTime.now(),
    );
    await _apiClient.post('/notifications', data: notif.toJson());
    Get.snackbar('New Notification', title, snackPosition: SnackPosition.TOP);
  }
}
