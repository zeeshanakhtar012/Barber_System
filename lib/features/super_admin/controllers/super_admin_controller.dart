import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_saas/data/models/shop_model.dart';
import 'package:barber_saas/data/models/user_model.dart';

class SuperAdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<ShopModel> shops = <ShopModel>[].obs;
  final RxList<UserModel> allCustomers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    shops.bindStream(_getShopsStream());
    allCustomers.bindStream(_getCustomersStream());
  }

  Stream<List<ShopModel>> _getShopsStream() {
    return _firestore.collection('shops').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShopModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<UserModel>> _getCustomersStream() {
    return _firestore.collection('users').where('role', isEqualTo: 'customer').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Future<void> createBarberShopWithAdmin(String shopName, String adminEmail, String adminPassword, String adminName) async {
    final cleanEmail = adminEmail.toLowerCase().trim();
    try {
      debugPrint('LOG [SuperAdmin]: Attempting to create shop: $shopName');
      isLoading.value = true;
      
      debugPrint('LOG [SuperAdmin]: Step 1 - Checking if email is taken...');
      // 1. Check if email is already taken in Users collection
      final existingUsers = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
      
      debugPrint('LOG [SuperAdmin]: Step 1 - Query complete. Is empty? ${existingUsers.docs.isEmpty}');
      if (existingUsers.docs.isNotEmpty) {
        Get.snackbar('Error', 'Email already taken. Use another email.');
        isLoading.value = false;
        return;
      }

      debugPrint('LOG [SuperAdmin]: Step 2 - Creating Shop Document reference...');
      // 2. Create Shop
      DocumentReference shopRef = _firestore.collection('shops').doc();
      ShopModel newShop = ShopModel(
        id: shopRef.id,
        name: shopName,
        logo: '',
        address: 'Please update address',
        phone: 'Please update phone',
        status: 'CLOSED',
        openingTime: '09:00',
        closingTime: '18:00',
        maxQueue: 10,
        subscriptionStatus: 'active',
      );
      
      debugPrint('LOG [SuperAdmin]: Step 2 - Executing shopRef.set()...');
      await shopRef.set(newShop.toJson());
      debugPrint('LOG [SuperAdmin]: Shop document created: ${shopRef.id}');

      debugPrint('LOG [SuperAdmin]: Step 3 - Creating Admin Document reference...');
      // 3. Create Barber Admin Document in Firestore with Password
      DocumentReference userRef = _firestore.collection('users').doc();
      UserModel newAdmin = UserModel(
        id: userRef.id,
        role: 'barber_admin',
        name: adminName,
        email: cleanEmail,
        phone: '',
        password: adminPassword.trim(),
        shopId: shopRef.id,
      );
      
      debugPrint('LOG [SuperAdmin]: Step 3 - Executing userRef.set()...');
      await userRef.set(newAdmin.toJson());
      debugPrint('LOG [SuperAdmin]: Admin user document created: ${userRef.id}');
      
      debugPrint('LOG [SuperAdmin]: Step 4 - Closing dialog...');
      Get.back(); // Closes the dialog correctly on success
      Get.snackbar('Success', 'Shop and Barber Admin created successfully');
      debugPrint('LOG [SuperAdmin]: Success finished.');
      
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to create shop: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> suspendShop(String shopId) async {
    try {
      debugPrint('LOG [SuperAdmin]: Suspending shop: $shopId');
      await _firestore.collection('shops').doc(shopId).update({'subscriptionStatus': 'suspended'});
      Get.snackbar('Success', 'Shop suspended');
    } catch (e) {
      debugPrint('LOG [SuperAdmin Error]: Failed to suspend shop: $e');
      Get.snackbar('Error', 'Failed to suspend shop: $e');
    }
  }
}
