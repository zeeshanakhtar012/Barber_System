class ShopModel {
  final String id;
  final String name;
  final String logo;
  final String address;
  final String phone;
  final String status; // 'OPEN', 'BREAK', 'CLOSED', 'BUSY', 'OFFLINE'
  final String openingTime;
  final String closingTime;
  final int maxQueue;
  final String subscriptionStatus;

  ShopModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.phone,
    required this.status,
    required this.openingTime,
    required this.closingTime,
    required this.maxQueue,
    required this.subscriptionStatus,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json, String id) {
    return ShopModel(
      id: id,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'CLOSED',
      openingTime: json['openingTime'] ?? '09:00',
      closingTime: json['closingTime'] ?? '18:00',
      maxQueue: json['maxQueue'] ?? 10,
      subscriptionStatus: json['subscriptionStatus'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'address': address,
      'phone': phone,
      'status': status,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'maxQueue': maxQueue,
      'subscriptionStatus': subscriptionStatus,
    };
  }
}
