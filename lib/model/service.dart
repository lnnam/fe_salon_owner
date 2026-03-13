class Service {
  int pkey;
  String name;
  double price;
  double? pricevip;
  int? needproduct;
  double? pricePromotion;
  int? categorykey;
  double? com1a;
  double? com1b;
  double? com2a;
  double? com2b;
  String? category;

  Service({
    required this.pkey,
    required this.name,
    required this.price,
    this.pricevip,
    this.needproduct,
    this.pricePromotion,
    this.categorykey,
    this.com1a,
    this.com1b,
    this.com2a,
    this.com2b,
    this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      pkey: json['pkey'] ?? 0,
      name: json['name'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      pricevip: json['pricevip'] != null ? (json['pricevip']).toDouble() : null,
      needproduct: json['needproduct'],
      pricePromotion: json['price_promotion'] != null
          ? (json['price_promotion']).toDouble()
          : null,
      categorykey: json['categorykey'],
      com1a: json['com1a'] != null ? (json['com1a']).toDouble() : null,
      com1b: json['com1b'] != null ? (json['com1b']).toDouble() : null,
      com2a: json['com2a'] != null ? (json['com2a']).toDouble() : null,
      com2b: json['com2b'] != null ? (json['com2b']).toDouble() : null,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pkey': pkey,
      'name': name,
      'price': price,
      'pricevip': pricevip,
      'needproduct': needproduct,
      'price_promotion': pricePromotion,
      'categorykey': categorykey,
      'com1a': com1a,
      'com1b': com1b,
      'com2a': com2a,
      'com2b': com2b,
      'category': category,
    };
  }
}
