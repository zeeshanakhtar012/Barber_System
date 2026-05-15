import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/service_model.dart';
import 'package:barber_saas/data/models/appointment_model.dart';
import 'package:barber_saas/core/config/app_config.dart';

class CustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ShopModel> availableShops = <ShopModel>[].obs;
  final RxList<AppointmentModel> myAppointments = <AppointmentModel>[].obs;
  
  final Rx<ShopModel?> selectedShop = Rx<ShopModel?>(null);
  final RxList<ServiceModel> shopServices = <ServiceModel>[].obs;
  final RxList<ServiceModel> selectedServices = <ServiceModel>[].obs;
  final RxInt estimatedWaitTime = 0.obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AppConfig.targetShopId != null) {
      _loadSingleTargetShop(AppConfig.targetShopId!);
    } else {
      _loadAvailableShops();
    }
    _loadMyAppointments();
  }

  void _loadSingleTargetShop(String shopId) {
    _firestore.collection('shops').doc(shopId).snapshots().listen((doc) {
      if (doc.exists) {
        final shop = ShopModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        selectedShop.value = shop;
        // Automatically load services for this hardcoded shop
        _firestore.collection('services').where('shopId', isEqualTo: shop.id).snapshots().listen((snapshot) {
          shopServices.value = snapshot.docs.map((sDoc) => ServiceModel.fromJson(sDoc.data(), sDoc.id)).toList();
        });
        _calculateWaitTime(shop.id);
      }
    });
  }

  void _loadAvailableShops() {
    availableShops.bindStream(
      _firestore.collection('shops').where('subscriptionStatus', isEqualTo: 'active').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ShopModel.fromJson(doc.data(), doc.id)).toList()
      )
    );
  }

  void _loadMyAppointments() {
    final user = _authController.currentUser.value;
    if (user != null) {
      myAppointments.bindStream(
        _firestore.collection('appointments').where('customerId', isEqualTo: user.id).snapshots().asyncMap((snapshot) async {
          final appointments = snapshot.docs.map((doc) => AppointmentModel.fromJson(doc.data(), doc.id)).toList();
          
          // Calculate queue position for pending/in_progress appointments
          for (var app in appointments) {
            if (app.status == 'pending' || app.status == 'confirmed') {
              final queueSnapshot = await _firestore.collection('appointments')
                .where('shopId', isEqualTo: app.shopId)
                .where('status', whereIn: ['pending', 'confirmed', 'in_progress'])
                .get();
              
              // Simple calculation: how many appointments are estimated to start before this one
              int pos = 1;
              for (var qDoc in queueSnapshot.docs) {
                final qApp = AppointmentModel.fromJson(qDoc.data(), qDoc.id);
                if (qApp.estimatedStart.isBefore(app.estimatedStart) && qApp.id != app.id) {
                  pos++;
                }
              }
              // Mutate the local model for UI rendering
              final updatedApp = AppointmentModel(
                id: app.id, shopId: app.shopId, customerId: app.customerId,
                services: app.services, status: app.status, queuePosition: pos,
                estimatedStart: app.estimatedStart, estimatedEnd: app.estimatedEnd,
                totalDuration: app.totalDuration, totalPrice: app.totalPrice
              );
              appointments[appointments.indexOf(app)] = updatedApp;
            }
          }
          return appointments;
        })
      );
    }
  }

  Future<void> selectShop(ShopModel shop) async {
    selectedShop.value = shop;
    selectedServices.clear();
    
    // Load Services for shop
    final snapshot = await _firestore.collection('services').where('shopId', isEqualTo: shop.id).get();
    shopServices.value = snapshot.docs.map((doc) => ServiceModel.fromJson(doc.data(), doc.id)).toList();
    
    _calculateWaitTime(shop.id);
  }

  void toggleService(ServiceModel service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }

  void _calculateWaitTime(String shopId) {
    // Dynamic realtime estimation
    // For simplicity: fetch current pending queue, sum up durations
    _firestore.collection('appointments')
      .where('shopId', isEqualTo: shopId)
      .where('status', whereIn: ['pending', 'confirmed', 'in_progress'])
      .snapshots().listen((snapshot) {
        int totalWait = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          totalWait += (data['totalDuration'] as int?) ?? 30;
        }
        estimatedWaitTime.value = totalWait;
    });
  }

  Future<void> bookAppointment() async {
    if (selectedShop.value == null || selectedServices.isEmpty) return;
    
    final user = _authController.currentUser.value;
    if (user == null) return;

    try {
      isLoading.value = true;
      
      int totalDuration = selectedServices.fold(0, (sum, item) => sum + item.duration);
      double totalPrice = selectedServices.fold(0.0, (sum, item) => sum + item.price);
      
      final now = DateTime.now();
      final estStart = now.add(Duration(minutes: estimatedWaitTime.value));
      final estEnd = estStart.add(Duration(minutes: totalDuration));

      DocumentReference ref = _firestore.collection('appointments').doc();
      AppointmentModel newAppointment = AppointmentModel(
        id: ref.id,
        shopId: selectedShop.value!.id,
        customerId: user.id,
        services: selectedServices.toList(),
        status: 'pending',
        queuePosition: 0, // Should be calculated by cloud function or more complex transaction
        estimatedStart: estStart,
        estimatedEnd: estEnd,
        totalDuration: totalDuration,
        totalPrice: totalPrice,
      );

      await ref.set(newAppointment.toJson());
      Get.back();
      Get.snackbar('Success', 'Appointment Booked!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({'status': 'cancelled'});
      Get.snackbar('Cancelled', 'Your booking has been cancelled.');
    } catch (e) {
      Get.snackbar('Error', 'Could not cancel booking: $e');
    }
  }
}
