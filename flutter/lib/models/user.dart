// Modèle représentant un utilisateur connecté
class User {
  final int id;
  final String email;
  final String nom;
  final String prenom;

  const User({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
  });

  /// Construit un User à partir d'un JSON renvoyé par l'API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
    );
  }
}
