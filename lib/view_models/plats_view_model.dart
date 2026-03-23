import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/meal_model.dart';
import '../services/base_api_service.dart';
import '../services/plats_service.dart';

enum PlatsLoadState { idle, loading, success, error }

enum PlatsMutationState { idle, submitting, success, error }

class PlatsViewModel extends ChangeNotifier {
  final PlatsService _service;

  PlatsViewModel({PlatsService? service})
      : _service = service ?? PlatsService();

  // ── List state ──────────────────────────────────────────────────────────
  PlatsLoadState _loadState = PlatsLoadState.idle;
  List<MealModel> _plats = [];
  String? _loadError;

  PlatsLoadState get loadState => _loadState;
  List<MealModel> get plats => _plats;
  String? get loadError => _loadError;
  bool get isLoading => _loadState == PlatsLoadState.loading;

  // ── Mutation state (create/update/delete) ────────────────────────────────
  PlatsMutationState _mutationState = PlatsMutationState.idle;
  String? _mutationError;
  String? _mutationSuccess;

  PlatsMutationState get mutationState => _mutationState;
  String? get mutationError => _mutationError;
  String? get mutationSuccess => _mutationSuccess;
  bool get isSubmitting => _mutationState == PlatsMutationState.submitting;

  // ─────────────────────────────────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadPlats({int? idResto}) async {
    _loadState = PlatsLoadState.loading;
    _loadError = null;
    notifyListeners();
    try {
      if (idResto != null) {
        _plats = await _service.getPlatsByRestaurant(idResto);
      } else {
        _plats = await _service.getAllPlats();
      }
      _loadState = PlatsLoadState.success;
    } on ApiException catch (e) {
      _loadError = e.message;
      _loadState = PlatsLoadState.error;
    } catch (_) {
      _loadError = 'Impossible de charger les plats';
      _loadState = PlatsLoadState.error;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> createPlat({
    required String nom,
    required double prix,
    required int idResto,
    File? imgFile,
  }) async {
    _mutationState = PlatsMutationState.submitting;
    _mutationError = null;
    _mutationSuccess = null;
    notifyListeners();
    try {
      await _service.createPlat(
          nom: nom, prix: prix, idResto: idResto, imgFile: imgFile);
      _mutationState = PlatsMutationState.success;
      _mutationSuccess = 'Plat ajouté avec succès';
      notifyListeners();
      // Refresh list if we have the restaurant context
      await loadPlats(idResto: idResto);
      return true;
    } on ApiException catch (e) {
      _mutationError = e.message;
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    } catch (_) {
      _mutationError = 'Erreur lors de la création';
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> updatePlat({
    required int id,
    required String nom,
    required double prix,
    required int idResto,
    File? imgFile,
  }) async {
    _mutationState = PlatsMutationState.submitting;
    _mutationError = null;
    _mutationSuccess = null;
    notifyListeners();
    try {
      await _service.updatePlat(
          id: id, nom: nom, prix: prix, idResto: idResto, imgFile: imgFile);
      _mutationState = PlatsMutationState.success;
      _mutationSuccess = 'Plat mis à jour';
      notifyListeners();
      await loadPlats(idResto: idResto);
      return true;
    } on ApiException catch (e) {
      _mutationError = e.message;
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    } catch (_) {
      _mutationError = 'Erreur lors de la mise à jour';
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE (soft)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> deletePlat(int id, {int? idResto}) async {
    _mutationState = PlatsMutationState.submitting;
    _mutationError = null;
    _mutationSuccess = null;
    notifyListeners();
    try {
      await _service.deletePlat(id);
      // Optimistically remove from local list
      _plats = _plats.where((m) => m.id != id.toString()).toList();
      _mutationState = PlatsMutationState.success;
      _mutationSuccess = 'Plat supprimé';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _mutationError = e.message;
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    } catch (_) {
      _mutationError = 'Erreur lors de la suppression';
      _mutationState = PlatsMutationState.error;
      notifyListeners();
      return false;
    }
  }

  void clearMutationState() {
    _mutationState = PlatsMutationState.idle;
    _mutationError = null;
    _mutationSuccess = null;
    notifyListeners();
  }
}
