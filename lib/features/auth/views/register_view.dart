import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              opacity: 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add, size: 60, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join as a Customer',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(nameController, 'Full Name', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(emailController, 'Email', Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(phoneController, 'Phone Number', Icons.phone),
                  const SizedBox(height: 16),
                  _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.registerCustomer(
                                    nameController.text.trim(),
                                    emailController.text.trim(),
                                    phoneController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Already have an account? Login', style: TextStyle(color: Colors.amber)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController textController, String label, IconData icon, {bool isPassword = false}) {
    if (isPassword) {
      return Obx(
        () => TextField(
          controller: textController,
          obscureText: _obscurePassword.value,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => _obscurePassword.toggle(),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.amber),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: textController,
      obscureText: false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
