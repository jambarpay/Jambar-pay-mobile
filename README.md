# Jambar Pay Mobile

## Vue d'ensemble

`jambar_pay_mobile` est le front mobile Flutter de Jambar Pay. Il prend en charge :

- l'authentification par numéro de téléphone et PIN
- l'affichage du tableau de bord wallet
- l'historique des transactions
- la recherche et la visualisation des restaurants partenaires
- le paiement via QR et la confirmation de transaction
- la gestion du profil utilisateur

L'application est structurée autour d'une architecture modulaire avec une séparation claire entre la présentation, le domaine métier et l'accès aux données.

## Architecture du projet

### Arborescence clé

- `lib/main.dart` : point d'entrée de l'application Flutter
- `lib/injection.dart` : configuration de l'injection de dépendances GetIt
- `lib/di.dart` : sélection de l'API réelle ou du mock
- `lib/ApiService/` : client HTTP, services API et routes backend
- `lib/data/` : data sources, repositories, persistence
- `lib/domain/` : entités, use cases, contrats de domaine
- `lib/presentation/` : BLoC, événements et états
- `lib/View/` : écrans, widgets, modèles UI et layout
- `lib/Config/` : fichier de configuration technique
- `lib/Validation/` : règles de validation

### Couche présentation

Le front mobile utilise :

- `AuthBloc` pour l'authentification
- `TransactionBloc` pour les transactions
- `PaymentBloc` pour les paiements QR
- `ProfileBloc` pour la gestion du profil

La navigation est centralisée depuis `lib/View/main.dart` avec :

- `LoginScreen`
- `PinScreen`
- `HomeScreen` (Dashboard / Historique / Restaurants / Profil)

### Couche domaine

La couche `lib/domain/` contient les règles métier, les entités et les interfaces des repositories. Elle orchestre :

- l'envoi d'OTP
- la vérification du PIN
- la récupération des transactions
- la gestion du wallet
- la confirmation des paiements

### Couche data

La couche `lib/data/` implémente :

- les datasources distants pour l'API
- les datasources locaux pour le stockage d'authentification
- les repositories métier utilisés par les use cases

### API backend

Le client API est défini dans `lib/ApiService/BaseUrl.dart`.
Par défaut, l'application cible :

- `https://api.jambarpay.com`

Les routes utilisées incluent entre autres :

- `/utilisateurs/login`
- `/utilisateurs/register`
- `/utilisateurs/refresh`
- `/utilisateurs/verify-otp`
- `/comptes`
- `/comptes/transfert`
- `/comptes/payer`
- `/comptes/solde`
- `/transactions`
- `/wallet`

## Fonctionnalités principales

- Authentification mobile par numéro de téléphone
- Saisie de PIN et validation sécurisée
- Tableau de bord wallet avec solde et état du compte
- Historique des transactions et filtre basique
- Liste de restaurants partenaires et vue en mode carte / liste
- Paiement QR avec gestion du résultat et ajout d'une transaction
- Profil utilisateur et mode sombre

## Configuration

### Variables d'environnement utiles

- `API_BASE` : URL de base de l'API backend
- `USE_MOCK_API=true` : force l'utilisation de `MockApiService`
- `USE_LOCAL_AUTH=true` : active un mode d'auth local pour développement

### Mode mock

Pour démarrer l'application en mode mock (sans backend réel) :

```bash
flutter run --dart-define=USE_MOCK_API=true
```

Pour utiliser un backend personnalisé :

```bash
flutter run --dart-define=API_BASE=https://mon-backend.example.com
```

## Lancer l'application

Récupérer les dépendances :

```bash
flutter pub get
```

Lancer sur appareil ou simulateur :

```bash
flutter run
```

Liste des appareils disponibles :

```bash
flutter devices
```

Lancer sur un device spécifique :

```bash
flutter run -d <device-id>
```

## Compilation Android

```bash
flutter build apk --debug
```

## Compilation iOS

La compilation iOS nécessite un environnement macOS.

```bash
flutter build ios
```

## Tests

```bash
flutter test
```

## Points d'attention

- Le front mobile est conçu pour une expérience de paiement et de recherche de restaurants partenaires.
- Les données de démonstration sont initialisées depuis `lib/View/models/mobile_employee_space.dart`.
- La logique d'authentification et des API est injectée via `lib/injection.dart`.
- La navigation principale se fait avec un shell `HomeScreen` reposant sur un index de page.

## Recommandations de documentation

Pour enrichir ce README sans le surcharger, vous pouvez ajouter :

- `docs/architecture.md` : architecture générale et choix techniques
- `docs/api.md` : comportement attendu des endpoints backend
- `docs/run.md` : configuration de l'environnement et astuces de build
- `docs/adr/0001-mobile-architecture.md` : décisions d'architecture importantes
