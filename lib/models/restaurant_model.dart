class RestaurantModel {
  final String id;
  final String name;
  final String? tel;
  final String? email;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.tel,
    this.email,
  });

  /// Maps the API JSON keys: { "id", "nom", "tel", "email" }
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id']?.toString() ?? '',
      name: json['nom']?.toString() ?? 'Restaurant',
      tel: json['tel']?.toString(),
      email: json['email']?.toString(),
    );
  }
}