import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/features/auth/controllers/auth_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:barber_saas/core/config/app_config.dart';

class BarberSettingsView extends StatefulWidget {
  const BarberSettingsView({super.key});

  @override
  State<BarberSettingsView> createState() => _BarberSettingsViewState();
}

class _BarberSettingsViewState extends State<BarberSettingsView> {
  final BarberController controller = Get.find<BarberController>();
  final AuthController authController = Get.find<AuthController>();

  late final TextEditingController openTimeCtrl;
  late final TextEditingController closeTimeCtrl;
  late final TextEditingController maxQueueCtrl;

  late final TextEditingController shopNameCtrl;
  late final TextEditingController shopLogoCtrl;
  late final TextEditingController adminNameCtrl;
  late final TextEditingController adminAvatarCtrl;

  @override
  void initState() {
    super.initState();
    final shop = controller.currentShop.value;
    final adminUser = authController.currentUser.value;

    openTimeCtrl = TextEditingController(text: shop?.openingTime ?? '');
    closeTimeCtrl = TextEditingController(text: shop?.closingTime ?? '');
    maxQueueCtrl = TextEditingController(text: shop?.maxQueue.toString() ?? '');
    shopNameCtrl = TextEditingController(text: shop?.name ?? '');
    shopLogoCtrl = TextEditingController(text: shop?.logo ?? '');

    adminNameCtrl = TextEditingController(text: adminUser?.name ?? '');
    adminAvatarCtrl = TextEditingController(text: adminUser?.avatar ?? '');

    // Populate values reactively if they load/change
    ever(controller.currentShop, (newShop) {
      if (newShop != null && mounted) {
        openTimeCtrl.text = newShop.openingTime;
        closeTimeCtrl.text = newShop.closingTime;
        maxQueueCtrl.text = newShop.maxQueue.toString();
        shopNameCtrl.text = newShop.name;
        shopLogoCtrl.text = newShop.logo;
      }
    });

    ever(authController.currentUser, (newUser) {
      if (newUser != null && mounted) {
        adminNameCtrl.text = newUser.name;
        adminAvatarCtrl.text = newUser.avatar;
      }
    });
  }

  @override
  void dispose() {
    openTimeCtrl.dispose();
    closeTimeCtrl.dispose();
    maxQueueCtrl.dispose();
    shopNameCtrl.dispose();
    shopLogoCtrl.dispose();
    adminNameCtrl.dispose();
    adminAvatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section 1: Shop Timings Settings
            GlassContainer(
              opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      openTimeCtrl,
                      'Opening Time (e.g. 09:00)',
                      Icons.access_time,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      closeTimeCtrl,
                      'Closing Time (e.g. 18:00)',
                      Icons.access_time_filled,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      maxQueueCtrl,
                      'Max Queue Capacity',
                      Icons.people_alt,
                      isNumber: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.updateShopSettings(
                                    openTimeCtrl.text.trim(),
                                    closeTimeCtrl.text.trim(),
                                    int.tryParse(maxQueueCtrl.text.trim()) ?? 10,
                                  );
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Shop Timings',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Profile & Branding Settings
            GlassContainer(
              opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Branding & Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your shop branding and owner profile details. Email and password changes are disabled for platform security.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      shopNameCtrl,
                      'Shop Name',
                      Icons.store,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      shopLogoCtrl,
                      'Shop Logo URL',
                      Icons.image_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      adminNameCtrl,
                      'Owner/Admin Name',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      adminAvatarCtrl,
                      'Admin Profile Photo URL',
                      Icons.face_unlock_outlined,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.updateBrandingAndProfile(
                                    shopNameCtrl.text.trim(),
                                    shopLogoCtrl.text.trim(),
                                    adminNameCtrl.text.trim(),
                                    adminAvatarCtrl.text.trim(),
                                  );
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Update Profile & Branding',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: Share Your Shop QR/Link
            GlassContainer(
              opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Your Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let your customers scan the QR code or click the share link to view your live queue and book appointments directly!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Obx(() {
                        final shop = controller.currentShop.value;
                        if (shop == null) return const SizedBox.shrink();
                        final String deepLink = '${AppConfig.appScheme}://shop/${shop.id}';
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: deepLink,
                                version: QrVersions.auto,
                                size: 160.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Shop Link: ${AppConfig.appScheme}://shop/${shop.id}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.share, color: Colors.black),
                              label: const Text('Share Shop Link'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Share.share(
                                  'Check out our live queue and book your appointment at ${shop.name}! $deepLink',
                                  subject: 'Book at ${shop.name}',
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: textController,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
