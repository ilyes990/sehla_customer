import 'dart:convert';
import 'package:http/http.dart' as http;
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

class CommandeService {
  static const String _endpoint =
      'https://sahladelivery.com/commande/api_creat_commande.php';

  /// Creates a new order.
  ///
  /// Returns [CommandeResult] on 201 success.
  ///
  /// Throws [ApiException] with the exact API message on 400,
  /// and a generic message on 500 / network error.
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

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        message: 'Réponse invalide du serveur',
        statusCode: response.statusCode,
      );
    }

    // ── 400 Bad Request ───────────────────────────────────────────────────────
    if (response.statusCode == 400) {
      throw ApiException(
        message: decoded['message'] as String? ?? 'Champ manquant ou invalide',
        statusCode: 400,
      );
    }

    // ── 500 Server Error ──────────────────────────────────────────────────────
    if (response.statusCode == 500) {
      throw ApiException(
        message: 'Erreur serveur, veuillez réessayer',
        statusCode: 500,
      );
    }

    // ── 201 Success ───────────────────────────────────────────────────────────
    if (response.statusCode == 201) {
      final success = decoded['success'];
      if (success == true || success == 'true' || success == 1) {
        return CommandeResult.fromJson(decoded);
      }
    }

    // ── Fallback ──────────────────────────────────────────────────────────────
    throw ApiException(
      message:
          decoded['message'] as String? ?? 'Une erreur inattendue est survenue',
      statusCode: response.statusCode,
    );
  }
}
