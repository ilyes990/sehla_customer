class UserModel {
  final String id;
  final String name; // maps to API field "nom"
  final String email;
  final String phone; // maps to API field "telf"
  final String? location; // maps to API field "location"

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.location,
  });

  /// Build from the API "Create Customer" response.
  /// The server returns { "message": "...", "id": <int> }.
  /// We construct the model from the original request values + the returned id.
  factory UserModel.fromCreateResponse({
    required int id,
    required String nom,
    required String telf,
    required String email,
    String? location,
  }) =>
      UserModel(
        id: id.toString(),
        name: nom,
        email: email,
        phone: telf,
        location: location,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        name: json['nom'] as String? ?? json['name'] as String? ?? '',
        email: json['email'] as String,
        phone: json['telf'] as String? ?? json['phone'] as String? ?? '',
        location: json['location'] as String?,
      );

  /// Serialise to the API "Create Customer" request body.
  Map<String, dynamic> toCreateJson({required String password}) => {
        'nom': name,
        'telf': phone,
        'email': email,
        'password': password,
        'location': location ?? '',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': name,
        'telf': phone,
        'email': email,
        'location': location,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? location,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
      );
}
