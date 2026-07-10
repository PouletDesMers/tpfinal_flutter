# Application Flutter — Ventes Privées

Application mobile Flutter consommant une API REST Python (Flask) pour un catalogue de ventes privées.

## Prérequis

- Flutter SDK ^3.13.0
- Serveur Python lancé (voir `../serveur/`)

## Installation

```bash
flutter pub get
flutter run
```

## Structure

- `lib/main.dart` — Point d'entrée, Provider, routes
- `lib/models/` — Modèles de données
- `lib/services/` — Providers (Auth, Favoris) + config API
- `lib/screens/` — Écrans (connexion, inscription, liste, détail)
