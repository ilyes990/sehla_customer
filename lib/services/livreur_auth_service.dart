import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/livreur_model.dart';
import 'base_api_service.dart';

class LivreurAuthService {
  // Note: these endpoints are on a different path than the customer API
  static const String _registerEndpoint =
      'https://sahladelivery.com/livreur/api_livreur.php';
  static const String _loginEndpoint =
      'https://sahladelivery.com/livreur/login_livreur.php';

  // ── Register Livreur ──────────────────────────────────────────────────────
  /// Calls POST https://sahladelivery.com/livreur/api_livreur.php
  /// Body: { nom, tel, email, password }
  Future<LivreurModel> register({
    required String nom,
    required String tel,
    required String email,
    required String password,
  }) async {
    // ── Client-side validation ─────────────────────────────────────────────
    if (nom.trim().isEmpty ||
        tel.trim().isEmpty ||
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

    final uri = Uri.parse(_registerEndpoint);
    final body = jsonEncode({
      'nom': nom.trim(),
      'tel': tel.trim(),
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final id = decoded['id'];
        return LivreurModel.fromCreateResponse(
          id: id is int ? id : int.tryParse(id.toString()) ?? 0,
          nom: nom.trim(),
          tel: tel.trim(),
          email: email.trim(),
        );
      }

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

  // ── Login Livreur ─────────────────────────────────────────────────────────
  /// Calls POST https://sahladelivery.com/livreur/login_livreur.php
  /// Body: { email, password }
  Future<LivreurModel> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw const ApiException(message: 'Email et mot de passe requis');
    }

    final uri = Uri.parse(_loginEndpoint);
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
        // If the server sends back user info in a nested field or flat
        final data = decoded['livreur'] as Map<String, dynamic>? ??
            decoded['data'] as Map<String, dynamic>? ??
            decoded;

        return LivreurModel.fromJson({
          ...data,
          'email': email.trim(), // ensure email is always present
        });
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
}
