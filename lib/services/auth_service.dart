import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  // ── Real endpoint ─────────────────────────────────────────────────────────
  static const String _createCustomerEndpoint =
      'custumer/crud_custumer_api.php';

  // ── Register (Create Customer) ────────────────────────────────────────────
  /// Calls POST https://sahladelivery.com/custumer/crud_custumer_api.php
  /// Body: { nom, telf, email, password, location }
  /// Success (201): { "message": "Customer created", "id": <int> }
  /// Error  (400): { "error": "nom, telf, email, password are required" }
  Future<UserModel> register({
    required String nom,
    required String telf,
    required String email,
    required String password,
    required String location,
  }) async {
    // ── Client-side validation ─────────────────────────────────────────────
    if (nom.trim().isEmpty ||
        telf.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      throw const ApiException(
          message: 'Tous les champs obligatoires sont requis');
    }
    if (!email.contains('@')) {
      throw const ApiException(message: 'Adresse email invalide');
    }
    if (password.length < 6) {
      throw const ApiException(
          message: 'Le mot de passe doit contenir au moins 6 caractères');
    }

    // ── Real API call ──────────────────────────────────────────────────────
    final uri = Uri.parse('${BaseApiService.baseUrl}/$_createCustomerEndpoint');

    final body = jsonEncode({
      'nom': nom.trim(),
      'telf': telf.trim(),
      'email': email.trim(),
      'password': password,
      'location': location.trim(),
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Response: { "message": "Customer created", "id": 5 }
        final id = decoded['id'];
        return UserModel.fromCreateResponse(
          id: id is int ? id : int.tryParse(id.toString()) ?? 0,
          nom: nom.trim(),
          telf: telf.trim(),
          email: email.trim(),
          location: location.trim(),
        );
      }

      // 400 / other errors → { "error": "..." }
      final errorMsg = decoded['error'] as String? ??
          decoded['message'] as String? ??
          'Inscription échouée (${response.statusCode})';
      throw ApiException(message: errorMsg, statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ── Login Customer ─────────────────────────────────────────────────────────
  /// Calls POST https://sahladelivery.com/custumer/login_custumer.php
  /// Body: { email, password }
  /// The server is expected to return the user's data on success.
  /// If the email exists only in the livreur table, we show a helpful message.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw const ApiException(message: 'Email et mot de passe requis');
    }

    final uri = Uri.parse(
        '${BaseApiService.baseUrl}/custumer/login_custumer.php');
    final body = jsonEncode({
      'email': email.trim(),
      'password': password,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Support both flat and nested response shapes
        final data = decoded['customer'] as Map<String, dynamic>? ??
            decoded['user'] as Map<String, dynamic>? ??
            decoded['custumer'] as Map<String, dynamic>? ??
            decoded;

        return UserModel.fromJson({
          ...data,
          'email': email.trim(), // guarantee email is set
        });
      }

      // Special case: user exists but as a livreur, not a customer
      final serverErr = (decoded['error'] as String? ??
              decoded['message'] as String? ??
              '')
          .toLowerCase();
      if (serverErr.contains('livreur') ||
          serverErr.contains('not found') ||
          serverErr.contains('introuvable')) {
        throw const ApiException(
          message:
              'Ce compte n\'existe pas en tant que client. '
              'Vous êtes peut-être inscrit en tant que livreur. '
              'Veuillez vous inscrire comme client pour continuer.',
        );
      }

      final errorMsg = decoded['error'] as String? ??
          decoded['message'] as String? ??
          'Connexion échouée (${response.statusCode})';
      throw ApiException(message: errorMsg, statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
