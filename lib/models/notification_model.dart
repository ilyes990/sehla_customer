// Represents a single dish entry inside a livreur notification
class NotificationPlatModel {
  final String nom;
  final int quantite;

  const NotificationPlatModel({required this.nom, required this.quantite});

  factory NotificationPlatModel.fromJson(Map<String, dynamic> json) {
    return NotificationPlatModel(
      nom: json['nom'] as String? ?? '',
      quantite: json['quantite'] is int
          ? json['quantite'] as int
          : int.tryParse(json['quantite'].toString()) ?? 1,
    );
  }
}

class NotificationModel {
  final int id;
  final String message;
  final DateTime createdAt;

  // Livreur-order-specific fields (nullable for customer notifications)
  final int? idCommande;
  final int? idLivreur;
  final String? status; // "libre" | "reserved"
  final String? restoNom;
  final List<NotificationPlatModel> lesPlats;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.createdAt,
    this.idCommande,
    this.idLivreur,
    this.status,
    this.restoNom,
    this.lesPlats = const [],
  });

  /// Whether this notification can still be taken (status = "libre")
  bool get isLibre => status == 'libre';

  /// Whether this notification has already been reserved
  bool get isReserved => status == 'reserved';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse les_plats array if present
    final rawPlats = json['lesplats'] ?? json['les_plats'];
    List<NotificationPlatModel> plats = [];
    if (rawPlats is List) {
      plats = rawPlats
          .whereType<Map<String, dynamic>>()
          .map(NotificationPlatModel.fromJson)
          .toList();
    }

    return NotificationModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      message: json['message'] as String? ?? '',
      createdAt: _parseDate(json['created_at']),
      idCommande: _parseInt(json['id_commande']),
      idLivreur: _parseInt(json['id_livreur']),
      status: json['status'] as String?,
      restoNom: json['resto_nom'] as String?,
      lesPlats: plats,
    );
  }

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Format: "26 Fév 2026 à 14:30" (French locale, no external package)
  String get formattedDate {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    final d = createdAt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = months[d.month - 1];
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day $month $year à $hour:$minute';
  }

  /// Returns a copy with updated status
  NotificationModel copyWithStatus(String newStatus) {
    return NotificationModel(
      id: id,
      message: message,
      createdAt: createdAt,
      idCommande: idCommande,
      idLivreur: idLivreur,
      status: newStatus,
      restoNom: restoNom,
      lesPlats: lesPlats,
    );
  }
}
