import 'package:barber_saas/data/models/service_model.dart';

class AppointmentModel {
  final String id;
  final String shopId;
  final String customerId;
  final List<ServiceModel> services;
  final String status; // 'pending', 'confirmed', 'checked_in', 'in_progress', 'completed', 'cancelled', 'no_show'
  final int queuePosition;
  final DateTime estimatedStart;
  final DateTime estimatedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int totalDuration; // in minutes
  final double totalPrice;

  AppointmentModel({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.services,
    required this.status,
    required this.queuePosition,
    required this.estimatedStart,
    required this.estimatedEnd,
    this.actualStart,
    this.actualEnd,
    required this.totalDuration,
    required this.totalPrice,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String id) {
    var servicesList = (json['services'] as List? ?? []).map((s) => ServiceModel.fromJson(s, s['id'])).toList();
    
    return AppointmentModel(
      id: id,
      shopId: json['shopId'] ?? '',
      customerId: json['customerId'] ?? '',
      services: servicesList,
      status: json['status'] ?? 'pending',
      queuePosition: json['queuePosition'] ?? 0,
      estimatedStart: DateTime.parse(json['estimatedStart']),
      estimatedEnd: DateTime.parse(json['estimatedEnd']),
      actualStart: json['actualStart'] != null ? DateTime.parse(json['actualStart']) : null,
      actualEnd: json['actualEnd'] != null ? DateTime.parse(json['actualEnd']) : null,
      totalDuration: json['totalDuration'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'customerId': customerId,
      'services': services.map((s) => s.toJson()..['id'] = s.id).toList(),
      'status': status,
      'queuePosition': queuePosition,
      'estimatedStart': estimatedStart.toIso8601String(),
      'estimatedEnd': estimatedEnd.toIso8601String(),
      'actualStart': actualStart?.toIso8601String(),
      'actualEnd': actualEnd?.toIso8601String(),
      'totalDuration': totalDuration,
      'totalPrice': totalPrice,
    };
  }
}
