class ServiceModel {
  final String id;
  final String shopId;
  final String name;
  final int duration; // in minutes
  final double price;
  final List<String> images;

  ServiceModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.duration,
    required this.price,
    this.images = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      shopId: json['shopId'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'] ?? 30,
      price: (json['price'] ?? 0.0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'name': name,
      'duration': duration,
      'price': price,
      'images': images,
    };
  }
}
