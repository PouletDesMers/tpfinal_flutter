import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fournisseur d'état des favoris.
/// Stocke les IDs des produits favoris localement dans SharedPreferences.
class FavoritesProvider extends ChangeNotifier {
  Set<int> _favoriteIds = {};
  bool _loaded = false;

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoaded => _loaded;

  /// Charge les IDs depuis SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('favorite_ids');
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _favoriteIds = list.map((e) => e as int).toSet();
    }
    _loaded = true;
    notifyListeners();
  }

  /// Vérifie si un produit est favori
  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  /// Ajoute ou retire un produit des favoris → retourne le nouvel état
  Future<bool> toggleFavorite(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    await _save();
    return _favoriteIds.contains(productId);
  }

  /// Sauvegarde la liste dans SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_ids', jsonEncode(_favoriteIds.toList()));
  }
}
