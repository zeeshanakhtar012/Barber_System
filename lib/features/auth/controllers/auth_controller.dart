import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_saas/data/models/user_model.dart';
import 'package:barber_saas/data/providers/storage_provider.dart';
import 'package:barber_saas/core/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageProvider _storage = Get.put(StorageProvider());

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
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        UserModel userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        currentUser.value = userModel;
        
        _storage.saveSession('dummy_token', userModel.id, userModel.role);
        
        _navigateBasedOnRole(userModel.role);
      } else {
        // If user document doesn't exist (e.g. first time login but doc creation failed)
        await logout();
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Failed to fetch user data: $e');
      Get.snackbar('Error', 'Failed to fetch user data: $e');
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
      debugPrint('LOG [Auth]: Attempting Custom Login for email: "$cleanEmail" with password: "$cleanPassword"');
      isLoading.value = true;
      
      // DEBUG: First fetch just the email to see what is stored in the database
      final debugSnapshot = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
      if (debugSnapshot.docs.isEmpty) {
        debugPrint('LOG [Auth Debug]: NO USER FOUND WITH EMAIL "$cleanEmail"');
      } else {
        final docData = debugSnapshot.docs.first.data();
        debugPrint('LOG [Auth Debug]: Found user! Stored email: "${docData['email']}", Stored password: "${docData['password']}"');
      }

      final snapshot = await _firestore.collection('users')
          .where('email', isEqualTo: cleanEmail)
          .where('password', isEqualTo: cleanPassword)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        debugPrint('LOG [Auth]: Firestore Auth successful, saving session...');
        UserModel userModel = UserModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
        currentUser.value = userModel;
        
        await _storage.saveSession('dummy_token', userModel.id, userModel.role);
        _navigateBasedOnRole(userModel.role);
      } else {
        debugPrint('LOG [Auth Error]: Login failed: Invalid email or password');
        Get.snackbar('Login Failed', 'Invalid email or password');
      }
    } catch (e) {
      debugPrint('LOG [Auth Error]: Login failed with exception: $e');
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerCustomer(String name, String email, String phone, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      isLoading.value = true;
      
      // Check if email already exists globally in Firestore
      final existingUsers = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
      if (existingUsers.docs.isNotEmpty) {
        Get.snackbar('Error', 'Email already taken. Use another email.');
        return;
      }

      DocumentReference userRef = _firestore.collection('users').doc();
      UserModel newUser = UserModel(
        id: userRef.id,
        role: 'customer',
        name: name,
        email: cleanEmail,
        phone: phone,
        password: password,
      );
      
      await userRef.set(newUser.toJson());
      debugPrint('LOG [Auth]: Customer registered successfully in Firestore.');
      Get.snackbar('Success', 'Registered successfully. Please login.');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('LOG [Auth Error]: Registration failed: $e');
      Get.snackbar('Registration Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkSuperAdminExists() async {
    try {
      final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'super_admin').limit(1).get();
      hasSuperAdmin.value = snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking super admin: $e');
    }
  }

  Future<void> createFirstSuperAdmin(String email, String password, String name) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      isLoading.value = true;
      
      DocumentReference userRef = _firestore.collection('users').doc();
      UserModel superAdmin = UserModel(
        id: userRef.id,
        role: 'super_admin',
        name: name,
        email: cleanEmail,
        phone: '',
        password: password,
      );
      
      await userRef.set(superAdmin.toJson());
      hasSuperAdmin.value = true;
      debugPrint('LOG [Auth]: First Super Admin created successfully in Firestore');
      Get.snackbar('Success', 'First Super Admin created successfully');
      
      // Auto login the super admin
      currentUser.value = superAdmin;
      await _storage.saveSession('dummy_token', superAdmin.id, superAdmin.role);
      _navigateBasedOnRole(superAdmin.role);

    } catch (e) {
      debugPrint('LOG [Auth Error]: Super Admin creation failed: $e');
      Get.snackbar('Failed', e.toString());
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
