import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/meal_model.dart';
import 'base_api_service.dart';

/// Dedicated service for the /les_plats/api_plats.php API.
///
/// Covers:
///  - getAllPlats()           → GET all active plats
///  - getPlatById(id)         → GET single plat by id
///  - getPlatsByRestaurant()  → GET plats filtered by id_resto
///  - createPlat()            → POST multipart/form-data
///  - updatePlat()            → PUT  multipart/form-data  (POST + _method=PUT)
///  - deletePlat()            → DELETE (soft delete: sets actif = 0)
class PlatsService {
  static const String _baseEndpoint =
      'https://sahladelivery.com/les_plats/api_plats.php';

  // ─────────────────────────────────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────────────────────────────────

  /// GET all active plats (actif = 1).
  Future<List<MealModel>> getAllPlats() async {
    final uri = Uri.parse(_baseEndpoint);
    try {
      final response = await http.get(uri, headers: _jsonHeaders);
      _checkStatus(response);
      final decoded = _decodeList(response.body);
      return decoded
          .map((j) => MealModel.fromJson(j as Map<String, dynamic>))
          .where((m) => m.isAvailable) // actif == 1
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  /// GET a single plat by its id.
  Future<MealModel?> getPlatById(int id) async {
    final uri = Uri.parse('$_baseEndpoint?id=$id');
    try {
      final response = await http.get(uri, headers: _jsonHeaders);
      _checkStatus(response);
      final body = jsonDecode(response.body);
      if (body is List && body.isNotEmpty) {
        return MealModel.fromJson(body.first as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic>) {
        return MealModel.fromJson(body);
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// GET all active plats for a given restaurant [idResto].
  Future<List<MealModel>> getPlatsByRestaurant(int idResto) async {
    final uri = Uri.parse('$_baseEndpoint?id_resto=$idResto');
    try {
      final response = await http.get(uri, headers: _jsonHeaders);
      _checkStatus(response);
      final decoded = _decodeList(response.body);
      return decoded
          .map((j) => MealModel.fromJson(j as Map<String, dynamic>))
          .where((m) => m.isAvailable)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────

  /// POST multipart/form-data to create a new plat.
  /// [imgFile] is optional; if null, no image is uploaded.
  /// Returns the new plat id on success.
  Future<int> createPlat({
    required String nom,
    required double prix,
    required int idResto,
    File? imgFile,
  }) async {
    final uri = Uri.parse(_baseEndpoint);
    try {
      final request = http.MultipartRequest('POST', uri);
      request.fields['nom'] = nom.trim();
      request.fields['prix'] = prix.toString();
      request.fields['id_resto'] = idResto.toString();

      if (imgFile != null) {
        request.files.add(await http.MultipartFile.fromPath('img', imgFile.path));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _checkStatus(response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'];
      if (success == true || success == 'true' || success == 1) {
        return (decoded['id'] as num?)?.toInt() ?? 0;
      }
      throw ApiException(
          message: decoded['message'] as String? ?? 'Création échouée');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  /// PUT multipart/form-data to update an existing plat.
  /// Uses POST + _method=PUT for HTML form compatibility.
  Future<void> updatePlat({
    required int id,
    required String nom,
    required double prix,
    required int idResto,
    File? imgFile,
  }) async {
    final uri = Uri.parse('$_baseEndpoint?id=$id&_method=PUT');
    try {
      final request = http.MultipartRequest('POST', uri);
      request.fields['nom'] = nom.trim();
      request.fields['prix'] = prix.toString();
      request.fields['id_resto'] = idResto.toString();
      request.fields['_method'] = 'PUT';

      if (imgFile != null) {
        request.files.add(await http.MultipartFile.fromPath('img', imgFile.path));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _checkStatus(response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'];
      if (success == true || success == 'true' || success == 1) return;
      throw ApiException(
          message: decoded['message'] as String? ?? 'Mise à jour échouée');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE (soft)
  // ─────────────────────────────────────────────────────────────────────────

  /// DELETE (soft): sets actif = 0 on the server — never hard-deletes.
  Future<void> deletePlat(int id) async {
    final uri = Uri.parse('$_baseEndpoint?id=$id');
    try {
      final response = await http.delete(uri, headers: _jsonHeaders);
      _checkStatus(response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'];
      if (success == true || success == 'true' || success == 1) return;
      throw ApiException(
          message: decoded['message'] as String? ?? 'Suppression échouée');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
  };

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
          message: 'Erreur serveur (${response.statusCode})',
          statusCode: response.statusCode);
    }
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('plats')) {
      return decoded['plats'] as List;
    }
    return [];
  }
}
