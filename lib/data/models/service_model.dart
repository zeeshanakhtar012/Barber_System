class ServiceModel {
  final String id;
  final String shopId;
  final String name;
  final int duration; // in minutes
  final double price;

  ServiceModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.duration,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      shopId: json['shopId'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'] ?? 30,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'name': name,
      'duration': duration,
      'price': price,
    };
  }
}
