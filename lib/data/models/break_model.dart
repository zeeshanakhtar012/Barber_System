class BreakModel {
  final String id;
  final String shopId;
  final String breakType; // 'Lunch', 'Prayer', 'Emergency', 'Custom'
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'active', 'completed'

  BreakModel({
    required this.id,
    required this.shopId,
    required this.breakType,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BreakModel.fromJson(Map<String, dynamic> json, String id) {
    return BreakModel(
      id: id,
      shopId: json['shopId'] ?? '',
      breakType: json['breakType'] ?? 'Custom',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'breakType': breakType,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
    };
  }
}
