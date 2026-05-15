import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barber_saas/features/customer/controllers/customer_controller.dart';
import 'package:barber_saas/shared/widgets/glass_container.dart';

class MyBookingsView extends GetView<CustomerController> {
  const MyBookingsView({super.key});

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
      child: Obx(() {
        if (controller.myAppointments.isEmpty) {
          return const Center(
            child: Text('You have no active bookings.', style: TextStyle(color: Colors.white70, fontSize: 16)),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myAppointments.length,
          itemBuilder: (context, index) {
            final appointment = controller.myAppointments[index];
            final isActive = appointment.status == 'pending' || appointment.status == 'confirmed' || appointment.status == 'in_progress';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GlassContainer(
                opacity: isActive ? 0.2 : 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Booking ID: ${appointment.id.substring(0, 6)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(appointment.status)),
                          ),
                          child: Text(appointment.status.toUpperCase(), style: TextStyle(color: _getStatusColor(appointment.status), fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isActive) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Turn', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                appointment.queuePosition > 0 ? 'Position #${appointment.queuePosition}' : 'Live Tracking', 
                                style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Est. Start', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${appointment.estimatedStart.hour}:${appointment.estimatedStart.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        backgroundColor: Colors.white12,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text('Services: ${appointment.services.map((s) => s.name).join(', ')}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Total: \$${appointment.totalPrice.toStringAsFixed(2)} (${appointment.totalDuration} mins)', style: const TextStyle(color: Colors.white70)),
                    if (isActive) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            controller.cancelAppointment(appointment.id);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text('Cancel Booking'),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return Colors.amber;
      case 'in_progress':
        return Colors.blueAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
      case 'no_show':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }
}
