import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/user_model.dart';

class SuperAdminController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();

  final RxList<ShopModel> shops = <ShopModel>[].obs;
  final RxList<UserModel> allCustomers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShops();
    fetchCustomers();
  }

  Future<void> fetchShops() async {
    try {
      final res = await _api.get('/shops');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'];
        shops.value = data.map((json) => ShopModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to fetch shops: $e');
    }
  }

  Future<void> fetchCustomers() async {
    try {
      final res = await _api.get('/users/customers');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'];
        allCustomers.value = data.map((json) => UserModel.fromJson(json, json['_id'])).toList();
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to fetch customers: $e');
    }
  }

  Future<void> createBarberShopWithAdmin(String shopName, String adminEmail, String adminPassword, String adminName) async {
    final cleanEmail = adminEmail.toLowerCase().trim();
    try {
      debugPrint('LOG [SuperAdmin]: Attempting to create shop via API: $shopName');
      isLoading.value = true;
      
      final res = await _api.post('/shops/create-with-admin', data: {
        'shopName': shopName,
        'adminName': adminName,
        'adminEmail': cleanEmail,
        'adminPassword': adminPassword,
      });

      if (res.statusCode == 201) {
        Get.back(); // Closes the dialog correctly on success
        Get.snackbar('Success', 'Shop and Barber Admin created successfully');
        debugPrint('LOG [SuperAdmin]: Success finished.');
        fetchShops(); // Refresh the list
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to create shop: $e');
      Get.snackbar('Error', 'Failed to create shop or email taken');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> suspendShop(String shopId) async {
    try {
      debugPrint('LOG [SuperAdmin]: Suspending shop: $shopId');
      final res = await _api.patch('/shops/$shopId', data: {'subscriptionStatus': 'suspended'});
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Shop suspended');
        fetchShops(); // Refresh the list
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to suspend shop: $e');
      Get.snackbar('Error', 'Failed to suspend shop');
    }
  }

  Future<void> updateShopDetails(String shopId, Map<String, dynamic> updateData) async {
    try {
      isLoading.value = true;
      final res = await _api.patch('/shops/$shopId', data: updateData);
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Barber Shop details updated successfully');
        fetchShops();
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to update shop: $e');
      Get.snackbar('Error', 'Failed to update shop details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateShopAdminDetails(String shopId, Map<String, dynamic> adminData) async {
    try {
      isLoading.value = true;
      final res = await _api.patch('/shops/$shopId/admin', data: adminData);
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Barber Shop Admin updated successfully');
      }
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to update shop admin: $e');
      Get.snackbar('Error', 'Failed to update shop admin details');
    } finally {
      isLoading.value = false;
    }
  }
}
