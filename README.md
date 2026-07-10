# Application Flutter — Catalogue de Ventes Privées

**ITIS - INGETIS - ING - BA DEV/DATA 3**

Mini-projet : Application Flutter avec authentification et backend Python.

---

## Sommaire

- [Lancer le serveur Python](#1-lancer-le-serveur-python)
  - [Endpoints disponibles](#11-endpoints-disponibles)
  - [Comptes de test](#12-comptes-de-test)
- [Lancer l'application Flutter](#2-lancer-lapplication-flutter)
- [Démonstration vidéo](#3-démonstration-vidéo)
- [Rapport de projet](#4-rapport-de-projet)

---

## 1. Lancer le serveur Python

```bash
cd serveur

# Créer l'environnement virtuel (1ère fois seulement)
python3 -m venv venv

# Activer et installer les dépendances
./venv/bin/pip install -r requirements.txt

# Lancer le serveur
./venv/bin/python server.py
```

Le serveur démarre sur **http://0.0.0.0:8081** (accessible sur le réseau local).

### 1.1 Endpoints disponibles

| Méthode | Route | Description |
|---------|-------|-------------|
| `POST` | `/api/login` | Authentification (email + password) |
| `POST` | `/api/register` | Création de compte (bonus) |
| `GET` | `/api/produits` | Liste des produits (filtres : `?search=...&categorie=...`) |
| `GET` | `/api/produits/<id>` | Détail d'un produit |

### 1.2 Comptes de test

| Email | Mot de passe |
|-------|-------------|
| sophie.martin@example.com | azerty123 |
| karim.benali@example.com | motdepasse2 |

---

## 2. Lancer l'application Flutter

```bash
cd flutter

# Installer les dépendances (1ère fois seulement)
flutter pub get

# Lancer sur un appareil/émulateur
flutter run
```

> **Note réseau** : L'URL de l'API est configurée dans `flutter/lib/services/api_service.dart`.
> - Pour un **appareil réel** : utiliser l'IP locale du serveur (`http://192.168.x.x:8081`)
> - Pour l'**émulateur Android** : utiliser `http://10.0.2.2:8081`

---

## 3. Démonstration vidéo

Vidéo de démonstration de l'application (connexion, liste, détail, reconnexion automatique) :

[![Vidéo de démonstration](https://img.youtube.com/vi/1tGAOCMhhLw/maxresdefault.jpg)](https://youtube.com/shorts/1tGAOCMhhLw)

---

## 4. Rapport de projet

- [Rapport de projet (PDF)](docs/RAPPORT.pdf)
- [Source AsciiDoc du rapport](docs/RAPPORT.adoc)
