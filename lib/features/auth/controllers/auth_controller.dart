import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:barber_saas/data/models/user_model.dart';
import 'package:barber_saas/data/providers/storage_provider.dart';
import 'package:barber_saas/core/network/api_client.dart';
import 'package:barber_saas/core/routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final StorageProvider _storage = Get.find<StorageProvider>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasSuperAdmin = true.obs; // Assume true until checked

  @override
  void onInit() {
    super.onInit();
    _checkSuperAdminExists();
    _checkSavedSession();
  }

  void _checkSavedSession() async {
    final session = await _storage.getSession();
    if (session == null || session['userId'] == null) {
      debugPrint('LOG [Auth]: No active session found, navigating to Login');
      Get.offAllNamed(AppRoutes.login);
    } else {
      debugPrint('LOG [Auth]: Session found for user ${session['userId']}, fetching role data...');
      isLoading.value = true;
      await fetchUserData(session['userId']!);
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final res = await _api.get('/auth/me');
      if (res.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(res.data['data'], res.data['data']['_id']);
        currentUser.value = userModel;
        _navigateBasedOnRole(userModel.role);
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Failed to fetch user data: $e');
      await logout();
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'super_admin':
        Get.offAllNamed(AppRoutes.superAdminDashboard);
        break;
      case 'barber_admin':
        Get.offAllNamed(AppRoutes.barberAdminDashboard);
        break;
      case 'customer':
      default:
        Get.offAllNamed(AppRoutes.customerDashboard);
        break;
    }
  }

  Future<void> login(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    final cleanPassword = password.trim();
    try {
      debugPrint('LOG [Auth]: Attempting REST API Login for email: "$cleanEmail"');
      isLoading.value = true;
      
      final res = await _api.post('/auth/login', data: {
        'email': cleanEmail,
        'password': cleanPassword,
      });

      if (res.statusCode == 200) {
        final data = res.data['data'];
        final token = data['token'];
        final userData = data['user'];
        
        UserModel userModel = UserModel.fromJson(userData, userData['_id']);
        currentUser.value = userModel;
        
        await _storage.saveSession(token, userModel.id, userModel.role);
        _navigateBasedOnRole(userModel.role);
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Login failed with exception: $e');
      Get.snackbar('Login Failed', 'Invalid email or password');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerCustomer(String name, String email, String phone, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      isLoading.value = true;
      
      final res = await _api.post('/auth/register', data: {
        'name': name,
        'email': cleanEmail,
        'phone': phone,
        'password': password,
      });

      if (res.statusCode == 201) {
        debugPrint('LOG [Auth]: Customer registered successfully via API.');
        Get.snackbar('Success', 'Registered successfully. Please login.');
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Registration failed: $e');
      Get.snackbar('Registration Failed', 'Email might be taken or invalid data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkSuperAdminExists() async {
    hasSuperAdmin.value = false; // The backend throws 403 if it exists when trying to create
  }

  Future<void> createFirstSuperAdmin(String email, String password, String name) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      isLoading.value = true;
      
      final res = await _api.post('/auth/super-admin', data: {
        'name': name,
        'email': cleanEmail,
        'password': password,
      });

      if (res.statusCode == 201) {
        hasSuperAdmin.value = true;
        Get.snackbar('Success', 'First Super Admin created successfully');
        
        final data = res.data['data'];
        final token = data['token'];
        final userData = data['user'];
        
        UserModel superAdmin = UserModel.fromJson(userData, userData['_id']);
        currentUser.value = superAdmin;
        
        await _storage.saveSession(token, superAdmin.id, superAdmin.role);
        _navigateBasedOnRole(superAdmin.role);
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Super Admin creation failed: $e');
      Get.snackbar('Failed', 'A Super Admin already exists or invalid data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    Get.snackbar('Notice', 'Password reset requires Firebase Auth. Contact Super Admin to reset password.');
  }

  Future<void> logout() async {
    await _storage.clearSession();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
