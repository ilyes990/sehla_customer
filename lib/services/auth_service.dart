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

  // ── Login (still mocked – real endpoint TBD) ──────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      throw const ApiException(message: 'Email et mot de passe requis');
    }
    if (password.length < 6) {
      throw const ApiException(message: 'Mot de passe invalide');
    }

    return UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Ahmed Benali',
      email: email,
      phone: '+213 555 123 456',
      location: 'Alger Centre',
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
