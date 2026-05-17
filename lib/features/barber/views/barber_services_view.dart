import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barber_saas/features/barber/controllers/barber_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';
import 'package:barber_saas/data/models/service_model.dart';

class BarberServicesView extends GetView<BarberController> {
  const BarberServicesView({super.key});

  static const List<Map<String, String>> templateImages = [
    {
      'name': 'Classic Cut',
      'url': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400&auto=format&fit=crop'
    },
    {
      'name': 'Beard Styling',
      'url': 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&auto=format&fit=crop'
    },
    {
      'name': 'Luxury Shave',
      'url': 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&auto=format&fit=crop'
    },
    {
      'name': 'Hair Coloring',
      'url': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400&auto=format&fit=crop'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  'Add New Service',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showServiceDialog(context),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.services.isEmpty) {
                return const Center(
                  child: Text(
                    'No services added yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  final hasImage = service.images.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassContainer(
                      opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(6),
                                image: hasImage
                                    ? DecorationImage(
                                        image: NetworkImage(service.images.first),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: !hasImage
                                  ? const Icon(Icons.cut, color: Colors.amber, size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${service.duration} mins • \$${service.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                              onPressed: () => _showServiceDialog(context, service: service),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete Service',
                                  titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  middleText: 'Are you sure you want to delete ${service.name}?',
                                  middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                                  backgroundColor: const Color(0xFF2D2D44),
                                  textCancel: 'Cancel',
                                  cancelTextColor: Colors.white70,
                                  textConfirm: 'Delete',
                                  confirmTextColor: Colors.black,
                                  buttonColor: Colors.redAccent,
                                  onConfirm: () {
                                    controller.deleteService(service.id);
                                    Get.back();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showServiceDialog(BuildContext context, {ServiceModel? service}) {
    final isEdit = service != null;
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final durationCtrl = TextEditingController(text: service?.duration.toString() ?? '');
    final priceCtrl = TextEditingController(text: service?.price.toString() ?? '');
    final customUrlCtrl = TextEditingController();

    final RxList<String> dialogImages = <String>[...(service?.images ?? [])].obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: GlassContainer(
            opacity: 0.25,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isEdit ? 'Edit Service' : 'Add Service',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Service Name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Duration (mins)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Price (\$)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Service Images',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Selected Images Previews
                  Obx(() {
                    if (dialogImages.isEmpty) {
                      return Container(
                        height: 70,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Text(
                          'No images added yet.',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dialogImages.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    dialogImages[idx],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.black45,
                                      width: 70,
                                      height: 70,
                                      child: const Icon(Icons.error, color: Colors.redAccent, size: 20),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => dialogImages.removeAt(idx),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  
                  // Custom Image URL Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customUrlCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration('Paste Custom Image URL').copyWith(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final url = customUrlCtrl.text.trim();
                          if (url.isNotEmpty) {
                            dialogImages.add(url);
                            customUrlCtrl.clear();
                          }
                        },
                        child: const Icon(Icons.add, color: Colors.black),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Premium Templates Selection
                  const Text(
                    'Tap to add high-quality templates:',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: templateImages.length,
                      itemBuilder: (context, idx) {
                        final item = templateImages[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => dialogImages.add(item['url']!),
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Image.network(
                                      item['url']!,
                                      width: 80,
                                      height: 54,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  height: 54,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['name']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Real Gallery Upload Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.amber, size: 18),
                      label: const Text('Upload from Gallery', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        try {
                          final ImagePicker picker = ImagePicker();
                          final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                          if (file == null) return;

                          // Show elegant progress indicator
                          Get.dialog(
                            const Center(
                              child: GlassContainer(
                                opacity: 0.2,
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(color: Colors.amber),
                                      SizedBox(height: 16),
                                      Text(
                                        'Uploading to Server...',
                                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            barrierDismissible: false,
                          );

                          final String? uploadedUrl = await controller.uploadImageFile(file.path);
                          Get.back(); // Dismiss progress dialog

                          if (uploadedUrl != null) {
                            dialogImages.add(uploadedUrl);
                            Get.snackbar(
                              'Upload Successful',
                              'Service image uploaded successfully!',
                              backgroundColor: Colors.green.withValues(alpha: 0.8),
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Upload Failed',
                              'Could not upload image to server.',
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          Get.back();
                          Get.snackbar(
                            'Error',
                            'An error occurred: $e',
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit buttons
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  final name = nameCtrl.text.trim();
                                  final duration = int.tryParse(durationCtrl.text.trim()) ?? 30;
                                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                                  if (name.isEmpty) {
                                    Get.snackbar('Error', 'Please enter a service name.');
                                    return;
                                  }

                                  if (isEdit) {
                                    controller.editService(
                                      service.id,
                                      name,
                                      duration,
                                      price,
                                      dialogImages,
                                    ).then((_) => Get.back());
                                  } else {
                                    controller.addService(
                                      name,
                                      duration,
                                      price,
                                      dialogImages,
                                    ).then((_) => Get.back());
                                  }
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.black),
                                )
                              : Text(
                                  isEdit ? 'Save Changes' : 'Create Service',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
