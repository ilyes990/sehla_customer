class MealModel {
  final String id;
  final String nom;
  final double prix;
  final String idResto;
  final String img;
  final bool actif;

  /// Full image URL built from the `img` filename.
  String get imageUrl => img.isNotEmpty
      ? 'https://sahladelivery.com/les_plats/uploads/$img'
      : 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&auto=format&fit=crop';

  const MealModel({
    required this.id,
    required this.nom,
    required this.prix,
    required this.idResto,
    required this.img,
    required this.actif,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    // Parse 'actif' — can be int (1/0) or bool
    final actifRaw = json['actif'];
    bool actif;
    if (actifRaw is int) {
      actif = actifRaw == 1;
    } else if (actifRaw is bool) {
      actif = actifRaw;
    } else {
      actif = true;
    }

    return MealModel(
      id: (json['id'])?.toString() ?? '',
      nom: json['nom'] as String? ?? 'Plat',
      prix: double.tryParse(json['prix']?.toString() ?? '0') ?? 0.0,
      idResto: (json['id_resto'])?.toString() ?? '',
      img: json['img'] as String? ?? '',
      actif: actif,
    );
  }
}
