class LivreurModel {
  final String id;
  final String name; // maps to API field "nom"
  final String email;
  final String phone; // maps to API field "tel"

  const LivreurModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory LivreurModel.fromCreateResponse({
    required int id,
    required String nom,
    required String tel,
    required String email,
  }) =>
      LivreurModel(
        id: id.toString(),
        name: nom,
        email: email,
        phone: tel,
      );

  factory LivreurModel.fromJson(Map<String, dynamic> json) => LivreurModel(
        id: json['id']?.toString() ?? '',
        name: json['nom'] as String? ?? json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['tel'] as String? ?? json['phone'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': name,
        'tel': phone,
        'email': email,
      };

  LivreurModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
  }) =>
      LivreurModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}
