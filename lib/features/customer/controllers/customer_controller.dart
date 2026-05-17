import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/core/network/socket_client.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/service_model.dart';
import 'package:barber_saas/data/models/appointment_model.dart';
import 'package:barber_saas/core/config/app_config.dart';

class CustomerController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final SocketClient _socket = Get.find<SocketClient>();

  final RxList<ShopModel> availableShops = <ShopModel>[].obs;
  final RxList<AppointmentModel> myAppointments = <AppointmentModel>[].obs;
  
  final Rx<ShopModel?> selectedShop = Rx<ShopModel?>(null);
  final Rx<String?> preferredShopId = Rx<String?>(null);
  final RxList<ServiceModel> shopServices = <ServiceModel>[].obs;
  final RxList<ServiceModel> selectedServices = <ServiceModel>[].obs;
  final RxInt estimatedWaitTime = 0.obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _loadMyAppointments();
  }

  void _loadPreferences() {
    if (AppConfig.targetShopId != null) {
      preferredShopId.value = AppConfig.targetShopId;
      _loadSingleTargetShop(AppConfig.targetShopId!);
      return;
    }

    final prefs = Get.find<SharedPreferences>();
    final storedShopId = prefs.getString('preferred_shop_id');
    preferredShopId.value = storedShopId;

    if (storedShopId != null) {
      _loadSingleTargetShop(storedShopId);
    } else {
      _loadAvailableShops();
    }
  }

  void _loadSingleTargetShop(String shopId) async {
    try {
      final res = await _api.get('/shops/$shopId');
      final data = res.data is Map ? res.data['data'] : res.data;
      final shop = ShopModel.fromJson(data, data['_id']);
      selectedShop.value = shop;
      _socket.connectQueue(shop.id);
      _calculateWaitTime(shop.id);
    } catch (e) {
      debugPrint('Failed to load shop: $e');
    }
  }

  Future<void> _loadAvailableShops() async {
    try {
      final res = await _api.get('/shops');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data is Map ? res.data['data'] : res.data;
        availableShops.value = data.map((json) => ShopModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('Failed to load shops: $e');
    }
  }

  Future<void> _loadMyAppointments() async {
    try {
      final res = await _api.get('/appointments/me');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data is Map ? res.data['data'] : res.data;
        myAppointments.value = data.map((json) => AppointmentModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
    }
  }

  Future<void> selectShop(ShopModel shop) async {
    selectedShop.value = shop;
    selectedServices.clear();
    
    // In MVP, services are hardcoded or fetched from another API route. We skip fetching for now since we didn't build a services API module yet.
    // Let's connect socket to listen to shop queue updates
    _socket.connectQueue(shop.id);
    
    _calculateWaitTime(shop.id);
  }

  void toggleService(ServiceModel service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }

  Future<void> _calculateWaitTime(String shopId) async {
    try {
      final res = await _api.get('/queue/shop/$shopId');
        final data = res.data is Map ? res.data['data'] : res.data;
        estimatedWaitTime.value = data['estimatedWaitTimeMinutes'] ?? 0;
    } catch (e) {
      debugPrint('Failed to get wait time: $e');
    }
  }

  Future<void> bookAppointment() async {
    if (selectedShop.value == null) return;
    
    try {
      isLoading.value = true;
      
      final res = await _api.post('/appointments', data: {
        'shopId': selectedShop.value!.id,
        'scheduledDate': DateTime.now().toIso8601String(),
        'estimatedDuration': 30, // Default MVP
      });

      if (res.statusCode == 201) {
        Get.back();
        Get.snackbar('Success', 'Appointment Booked!');
        _loadMyAppointments();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not book appointment');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final res = await _api.patch('/appointments/$appointmentId/status', data: {'status': 'cancelled'});
      if (res.statusCode == 200) {
        Get.snackbar('Cancelled', 'Your booking has been cancelled.');
        _loadMyAppointments();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not cancel booking: $e');
    }
  }

  Future<void> setPreferredShop(String shopId) async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.setString('preferred_shop_id', shopId);
    preferredShopId.value = shopId;
    _loadSingleTargetShop(shopId);
  }

  Future<void> clearPreferredShop() async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.remove('preferred_shop_id');
    preferredShopId.value = null;
    selectedShop.value = null;
    _loadAvailableShops();
  }
}
