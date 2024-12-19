class Service {
  String name;
  double price;
  String category;

  Service({
    required this.name,
    required this.price,
    required this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }
}