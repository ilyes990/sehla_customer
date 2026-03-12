import 'package:flutter/foundation.dart';
import '../models/livreur_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/base_api_service.dart';
import '../services/livreur_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

enum UserType { customer, livreur }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final LivreurAuthService _livreurAuthService;

  AuthViewModel({
    AuthService? authService,
    LivreurAuthService? livreurAuthService,
  })  : _authService = authService ?? AuthService(),
        _livreurAuthService = livreurAuthService ?? LivreurAuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  LivreurModel? _livreur;
  UserType? _userType;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  LivreurModel? get livreur => _livreur;
  UserType? get userType => _userType;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isCustomer => _userType == UserType.customer;
  bool get isLivreur => _userType == UserType.livreur;

  // ── Login Customer ────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    try {
      final user = await _authService.login(email: email, password: password);
      _user = user;
      _livreur = null;
      _userType = UserType.customer;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError("Une erreur inattendue s'est produite");
      return false;
    }
  }

  // ── Login Livreur ─────────────────────────────────────────────────────────
  Future<bool> loginLivreur(
      {required String email, required String password}) async {
    _setLoading();
    try {
      final livreur =
          await _livreurAuthService.login(email: email, password: password);
      _livreur = livreur;
      _user = null;
      _userType = UserType.livreur;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError("Une erreur inattendue s'est produite");
      return false;
    }
  }

  // ── Register Customer ─────────────────────────────────────────────────────
  /// Maps to POST /custumer/crud_custumer_api.php
  /// Fields: nom, telf, email, password, location
  Future<bool> register({
    required String nom,
    required String telf,
    required String email,
    required String password,
    required String location,
  }) async {
    _setLoading();
    try {
      final user = await _authService.register(
        nom: nom,
        telf: telf,
        email: email,
        password: password,
        location: location,
      );
      _user = user;
      _livreur = null;
      _userType = UserType.customer;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError("Une erreur inattendue s'est produite");
      return false;
    }
  }

  // ── Register Livreur ──────────────────────────────────────────────────────
  Future<bool> registerLivreur({
    required String nom,
    required String tel,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final livreur = await _livreurAuthService.register(
        nom: nom,
        tel: tel,
        email: email,
        password: password,
      );
      _livreur = livreur;
      _user = null;
      _userType = UserType.livreur;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError("Une erreur inattendue s'est produite");
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading();
    await _authService.logout();
    _user = null;
    _livreur = null;
    _userType = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Update Location (Customer only) ───────────────────────────────────────
  void updateLocation(String location) {
    if (_user != null) {
      _user = _user!.copyWith(location: location);
      notifyListeners();
    }
  }

  // ── Private Helpers ───────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
