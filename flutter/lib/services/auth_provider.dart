import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_service.dart';

// Clés utilisées pour stocker la session dans SharedPreferences
const _kId = 'user_id';
const _kEmail = 'user_email';
const _kNom = 'user_nom';
const _kPrenom = 'user_prenom';

/// Fournisseur d'état d'authentification.
/// Notifie les écrans quand l'utilisateur se connecte / déconnecte.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  /// Vérifie au démarrage si une session existe dans SharedPreferences
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_kId);
    if (id != null) {
      _user = User(
        id: id,
        email: prefs.getString(_kEmail) ?? '',
        nom: prefs.getString(_kNom) ?? '',
        prenom: prefs.getString(_kPrenom) ?? '',
      );
      notifyListeners();
    }
  }

  /// Appelle l'API POST /api/login, sauvegarde la session en local
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Appel POST vers l'API REST du serveur
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _user = User.fromJson(data);

        // Sauvegarde persistante de la session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kId, _user!.id);
        await prefs.setString(_kEmail, _user!.email);
        await prefs.setString(_kNom, _user!.nom);
        await prefs.setString(_kPrenom, _user!.prenom);

        _loading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Identifiants invalides.';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _error = 'Impossible de se connecter au serveur.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Appelle l'API POST /api/register, crée le compte et connecte automatiquement
  Future<bool> register(
    String nom,
    String prenom,
    String email,
    String password,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        _user = User.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kId, _user!.id);
        await prefs.setString(_kEmail, _user!.email);
        await prefs.setString(_kNom, _user!.nom);
        await prefs.setString(_kPrenom, _user!.prenom);

        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['error'] ?? 'Erreur lors de l\'inscription.';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Register error: $e');
      _error = 'Impossible de contacter le serveur.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur : efface SharedPreferences et réinitialise l'état
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    _error = null;
    notifyListeners();
  }
}
