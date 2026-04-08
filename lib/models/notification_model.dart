class NotificationPlatModel {
  final String nom;
  final int quantite;

  const NotificationPlatModel({
    required this.nom,
    required this.quantite,
  });

  factory NotificationPlatModel.fromJson(Map<String, dynamic> json) {
    return NotificationPlatModel(
      nom: json['nom'] as String? ?? 'Inconnu',
      quantite: json['quantite'] is int
          ? json['quantite']
          : int.tryParse(json['quantite'].toString()) ?? 1,
    );
  }
}

class NotificationModel {
  final int id;
  final String message;
  final DateTime createdAt;

  // --- New Optional Variables for Order Reservations ---
  final int? idCommande;
  final int? idLivreur;
  final String? status;
  final String? restoNom;
  final List<NotificationPlatModel>? lesplats;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.createdAt,
    this.idCommande,
    this.idLivreur,
    this.status,
    this.restoNom,
    this.lesplats,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested dishes list if present
    List<NotificationPlatModel>? plats;
    if (json['lesplats'] != null) {
      plats = (json['lesplats'] as List)
          .map((i) => NotificationPlatModel.fromJson(i))
          .toList();
    }

    return NotificationModel(
      id: _toInt(json['id']),
      // Use top-level message if this is from a nested response, or local field
      message: json['message'] as String? ?? '',
      createdAt: _toDate(json['created_at']),

      // New fields
      idCommande:
          json['id_commande'] != null ? _toInt(json['id_commande']) : null,
      idLivreur: json['id_livreur'] != null ? _toInt(json['id_livreur']) : null,
      status: json['status'] as String?,
      restoNom: json['resto_nom'] as String?,
      lesplats: plats,
    );
  }

  // Helper method to add/update message from top level if needed
  NotificationModel copyWith({String? message}) {
    return NotificationModel(
      id: id,
      message: message ?? this.message,
      createdAt: createdAt,
      idCommande: idCommande,
      idLivreur: idLivreur,
      status: status,
      restoNom: restoNom,
      lesplats: lesplats,
    );
  }

  // --- Helpers (Already in your file) ---
  static int _toInt(dynamic val) =>
      val is int ? val : int.tryParse(val.toString()) ?? 0;
  static DateTime _toDate(dynamic val) {
    if (val == null) return DateTime.now();
    try {
      return DateTime.parse(val.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  // ... (Your existing formattedDate getter)
}
