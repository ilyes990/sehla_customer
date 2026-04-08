import 'base_api_service.dart';

/// Represents a request dish item for the createCommande API.
class CommandePlatItem {
  final int id;
  final String nom;
  final int quantite;
  final double prix;
  final String note; // optional, send '' if none

  const CommandePlatItem({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.prix,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'quantite': quantite,
        'prix': prix,
        'note': note,
      };
}

/// The result returned after a successful createCommande call.
class CommandeResult {
  final int idCommande;
  final String status;
  final String createdAt;
  final int nbPlats;
  final String message;

  const CommandeResult({
    required this.idCommande,
    required this.status,
    required this.createdAt,
    required this.nbPlats,
    required this.message,
  });

  factory CommandeResult.fromJson(Map<String, dynamic> json) {
    return CommandeResult(
      idCommande: json['id_commande'] is int
          ? json['id_commande'] as int
          : int.tryParse(json['id_commande'].toString()) ?? 0,
      status: json['status'] as String? ?? 'enattente',
      createdAt: json['created_at'] as String? ?? '',
      nbPlats: json['nb_plats'] is int
          ? json['nb_plats'] as int
          : int.tryParse(json['nb_plats'].toString()) ?? 0,
      message: json['message'] as String? ?? 'Commande créée avec succès.',
    );
  }
}

class CommandeService extends BaseApiService {
  /// Creates a new order.
  /// POST /commande/api_creat_commande.php
  Future<CommandeResult> createCommande({
    required int customerId,
    required String customerNom,
    required String customerTel,
    required String customerLocation,
    required int restoId,
    required String restoNom,
    required String restoTel,
    required String restoAdresse,
    required double prixCommandeTotale,
    required List<CommandePlatItem> lesPlats,
  }) async {
    final body = {
      'info_customer': {
        'id': customerId,
        'nom': customerNom,
        'tel': customerTel,
        'location': customerLocation,
      },
      'info_resto': {
        'id': restoId,
        'nom': restoNom,
        'tel': restoTel,
        'adresse': restoAdresse,
      },
      'prix_commande_totale': prixCommandeTotale,
      'les_plats': lesPlats.map((p) => p.toJson()).toList(),
    };

    try {
      final decoded = await post('commande/api_creat_commande.php', body: body);

      if (decoded != null) {
        final success = decoded['success'];
        if (success == true || success == 'true' || success == 1) {
          return CommandeResult.fromJson(decoded);
        }
      }

      throw ApiException(
        message: decoded?['message'] as String? ?? 'Une erreur est survenue',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  /// Updates the status of an order.
  /// PUT /commande/api_update_commande_status.php
  /// Allowed statuses: en_attente, prepare, termine, livree
  Future<bool> updateCommandeStatus({
    required int commandeId,
    required String status,
  }) async {
    try {
      final body = {
        'commande_id': commandeId,
        'status': status,
      };

      final decoded =
          await put('commande/api_update_commande_status.php', body: body);

      if (decoded != null) {
        final success = decoded['success'];
        return success == true || success == 'true' || success == 1;
      }
      return false;
    } catch (e) {
      print('[updateCommandeStatus] ERROR: $e');
      return false;
    }
  }
}
