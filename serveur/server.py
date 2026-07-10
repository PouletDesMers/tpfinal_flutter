import json
import os
from flask import Flask, jsonify, request

app = Flask(__name__)

# Chargement des données depuis les fichiers JSON
def load_data():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(base_dir, "data", "users.json"), "r") as f:
        users = json.load(f)
    with open(os.path.join(base_dir, "data", "ventes.json"), "r") as f:
        ventes = json.load(f)
    return users, ventes

users, ventes = load_data()


@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Format JSON invalide"}), 400

    email = data.get("email")
    password = data.get("password")

    for u in users:
        if u["email"] == email and u["password"] == password:
            return jsonify({
                "id": u["id"],
                "email": u["email"],
                "nom": u["nom"],
                "prenom": u["prenom"],
            }), 200

    return jsonify({"error": "Email ou mot de passe incorrect"}), 401


@app.route("/api/register", methods=["POST"])
def register():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Format JSON invalide"}), 400

    email = data.get("email", "").strip().lower()
    password = data.get("password", "").strip()
    nom = data.get("nom", "").strip()
    prenom = data.get("prenom", "").strip()

    if not email or not password or not nom or not prenom:
        return jsonify({"error": "Tous les champs sont requis"}), 400

    # Vérifier si l'email existe déjà
    for u in users:
        if u["email"] == email:
            return jsonify({"error": "Cet email est déjà utilisé"}), 409

    # Créer le nouvel utilisateur
    new_id = max(u["id"] for u in users) + 1
    new_user = {
        "id": new_id,
        "email": email,
        "password": password,
        "nom": nom,
        "prenom": prenom,
    }
    users.append(new_user)

    # Sauvegarder dans le fichier JSON
    base_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(base_dir, "data", "users.json"), "w") as f:
        json.dump(users, f, indent=2)

    return jsonify({
        "id": new_user["id"],
        "email": new_user["email"],
        "nom": new_user["nom"],
        "prenom": new_user["prenom"],
    }), 201


@app.route("/api/produits", methods=["GET"])
def get_ventes():
    search = request.args.get("search", "").lower()
    categorie = request.args.get("categorie")

    resultats = ventes
    if search:
        resultats = [
            v for v in resultats
            if search in v.get("titre", "").lower()
        ]
    if categorie:
        resultats = [
            v for v in resultats
            if v.get("categorie") == categorie
        ]

    return jsonify(resultats), 200


@app.route("/api/produits/<int:id>", methods=["GET"])
def get_vente_by_id(id):
    for v in ventes:
        if v["id"] == id:
            return jsonify(v), 200
    return jsonify({"error": "Produit non trouvé"}), 404


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response


if __name__ == "__main__":
    print("API démarrée sur http://localhost:8081")
    app.run(host="0.0.0.0", port=8081, debug=True)
