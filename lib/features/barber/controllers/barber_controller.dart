import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/service_model.dart';
import 'package:barber_saas/data/models/appointment_model.dart';

class BarberController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
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

  void _loadBarberData() async {
    final user = _authController.currentUser.value;
    if (user != null && user.shopId != null) {
      await _loadShop(user.shopId!);
      await _loadServices(user.shopId!);
      await _loadTodayQueue(user.shopId!);
    }
  }

  Future<void> _loadShop(String shopId) async {
    try {
      final res = await _api.get('/shops/$shopId');
      if (res.statusCode == 200) {
        currentShop.value = ShopModel.fromJson(res.data['data'], res.data['data']['_id']);
      }
    } catch (e) {
      debugPrint('Failed to load shop: $e');
    }
  }

  Future<void> _loadServices(String shopId) async {
    try {
      final res = await _api.get('/services/shop/$shopId');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'];
        services.value = data.map((json) => ServiceModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('Failed to load services: $e');
    }
  }

  Future<void> _loadTodayQueue(String shopId) async {
    try {
      final res = await _api.get('/appointments/shop/$shopId/today');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'];
        todayQueue.value = data.map((json) => AppointmentModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('Failed to load today queue: $e');
    }
  }

  Future<void> updateShopStatus(String newStatus) async {
    if (currentShop.value == null) return;
    try {
      final res = await _api.patch('/shops/${currentShop.value!.id}/status', data: {'status': newStatus});
      if (res.statusCode == 200) {
        _loadShop(currentShop.value!.id);
      }
    } catch (e) {
      debugPrint('Failed to update shop status: $e');
    }
  }

  Future<void> addService(String name, int duration, double price, List<String> images) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      final res = await _api.post('/services', data: {
        'shopId': currentShop.value!.id,
        'name': name,
        'duration': duration,
        'price': price,
        'images': images,
      });
      if (res.statusCode == 201) {
        _loadServices(currentShop.value!.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editService(String serviceId, String name, int duration, double price, List<String> images) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      final res = await _api.put('/services/$serviceId', data: {
        'name': name,
        'duration': duration,
        'price': price,
        'images': images,
      });
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Service updated successfully.');
        _loadServices(currentShop.value!.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String serviceId) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      final res = await _api.delete('/services/$serviceId');
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Service deleted successfully.');
        _loadServices(currentShop.value!.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      final res = await _api.patch('/appointments/$appointmentId/status', data: {'status': newStatus});
      if (res.statusCode == 200) {
        _loadTodayQueue(currentShop.value!.id);
      }
    } catch (e) {
      debugPrint('Failed to update appointment status: $e');
    }
  }

  Future<void> updateShopSettings(String openingTime, String closingTime, int maxQueue) async {
    if (currentShop.value == null) return;
    try {
      isLoading.value = true;
      final res = await _api.patch('/shops/${currentShop.value!.id}/settings', data: {
        'openingTime': openingTime,
        'closingTime': closingTime,
        'maxQueue': maxQueue,
      });
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Shop settings updated.');
        _loadShop(currentShop.value!.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
