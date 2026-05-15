import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/service_model.dart';
import 'package:barber_saas/data/models/appointment_model.dart';

class BarberController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final Rx<ShopModel?> currentShop = Rx<ShopModel?>(null);
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxList<AppointmentModel> todayQueue = <AppointmentModel>[].obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBarberData();
  }

  void _loadBarberData() {
    final user = _authController.currentUser.value;
    if (user != null && user.shopId != null) {
      currentShop.bindStream(_getShopStream(user.shopId!));
      services.bindStream(_getServicesStream(user.shopId!));
      todayQueue.bindStream(_getTodayQueueStream(user.shopId!));
    }
  }

  Stream<ShopModel> _getShopStream(String shopId) {
    return _firestore.collection('shops').doc(shopId).snapshots().map(
      (doc) => ShopModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)
    );
  }

  Stream<List<ServiceModel>> _getServicesStream(String shopId) {
    return _firestore.collection('services').where('shopId', isEqualTo: shopId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ServiceModel.fromJson(doc.data(), doc.id)).toList()
    );
  }

  Stream<List<AppointmentModel>> _getTodayQueueStream(String shopId) {
    // Basic filter for today's queue
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    
    return _firestore.collection('appointments')
        .where('shopId', isEqualTo: shopId)
        .where('estimatedStart', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('estimatedStart')
        .snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromJson(doc.data(), doc.id)).toList()
    );
  }

  Future<void> updateShopStatus(String newStatus) async {
    if (currentShop.value == null) return;
    await _firestore.collection('shops').doc(currentShop.value!.id).update({'status': newStatus});
  }

  Future<void> addService(String name, int duration, double price) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      DocumentReference ref = _firestore.collection('services').doc();
      ServiceModel newService = ServiceModel(
        id: ref.id,
        shopId: currentShop.value!.id,
        name: name,
        duration: duration,
        price: price,
      );
      await ref.set(newService.toJson());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _firestore.collection('appointments').doc(appointmentId).update({'status': newStatus});
    // Trigger queue recalculation cloud function or logic here if needed
  }

  Future<void> updateShopSettings(String openingTime, String closingTime, int maxQueue) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      await _firestore.collection('shops').doc(currentShop.value!.id).update({
        'openingTime': openingTime,
        'closingTime': closingTime,
        'maxQueue': maxQueue,
      });
      Get.snackbar('Success', 'Shop settings updated.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
