import 'package:get/get.dart';
import 'package:barber_saas/data/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    // Listen to current user changes
    ever(_authController.currentUser, (user) {
      if (user != null) {
        notifications.bindStream(
          _firestore.collection('notifications')
              .where('userId', isEqualTo: user.id)
              .orderBy('createdAt', descending: true)
              .snapshots().map((snapshot) {
                final notifs = snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data(), doc.id)).toList();
                unreadCount.value = notifs.where((n) => !n.isRead).length;
                return notifs;
              })
        );
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (var notif in unread) {
      await markAsRead(notif.id);
    }
  }

  // This would typically be triggered by a Cloud Function in a real production environment
  // We include it here to demonstrate the architecture
  Future<void> sendLocalMockNotification(String title, String body, String userId, String role) async {
    final ref = _firestore.collection('notifications').doc();
    final notif = NotificationModel(
      id: ref.id,
      userId: userId,
      role: role,
      title: title,
      body: body,
      type: 'system',
      isRead: false,
      createdAt: DateTime.now(),
    );
    await ref.set(notif.toJson());
    Get.snackbar('New Notification', title, snackPosition: SnackPosition.TOP);
  }
}
