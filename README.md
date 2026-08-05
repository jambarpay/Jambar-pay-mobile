# Jambar Pay Mobile

Frontend Flutter de Jambar Pay pour Android, iOS, Web et Linux. L’application couvre l’authentification, le portefeuille, l’historique, les restaurants partenaires, le paiement QR et le profil.

## Démarrage rapide

```bash
flutter pub get
flutter run -d chrome
```

Le mode debug utilise automatiquement l’API mock et l’authentification locale. Le compte de développement accepte un numéro mobile sénégalais valide et l’OTP `123456`. Le code secret de confirmation de paiement reste sur 4 chiffres.

Pour afficher les appareils disponibles :

```bash
flutter devices
```

Si Android n’apparaît pas, connecter un téléphone avec le débogage USB activé ou démarrer un émulateur Android, puis relancer `flutter devices`.

## Environnements

Les valeurs sont injectées à la compilation avec `--dart-define` :

- `API_BASE` : URL HTTPS du backend ; valeur par défaut `https://api.jambarpay.com`.
- `USE_MOCK_API` : utilise les réponses locales de développement.
- `USE_LOCAL_AUTH` : utilise l’authentification locale de développement.

Exécution explicite en mode mock :

```bash
flutter run -d chrome \
  --dart-define=USE_MOCK_API=true \
  --dart-define=USE_LOCAL_AUTH=true
```

Exécution contre un backend :

```bash
flutter run -d chrome \
  --dart-define=USE_MOCK_API=false \
  --dart-define=USE_LOCAL_AUTH=false \
  --dart-define=API_BASE=https://api.example.com
```

Le mobile consomme les contrats `/api/v1/auth`, `/api/v1/restaurants`, `/api/v1/qrs` et `/api/v1/payments`. `API_BASE` doit désigner une gateway qui conserve ces chemins. La gateway présente dans le dépôt doit encore être corrigée avant un test bout en bout réel.

Le seul parcours d’authentification exposé par le backend est actuellement une **inscription**. L’écran mobile ne collecte encore que le téléphone : l’adaptateur complète donc temporairement `firstName` et `lastName` avec des valeurs de repli. Pour des données utilisateur réelles, il faudra soit ajouter ces deux champs à l’écran d’inscription, soit fournir côté backend un endpoint de connexion pour un utilisateur existant.

Le backend actuel ne fournit pas encore le refresh token, le changement/réinitialisation de PIN ni la liste des transactions. Ces parcours restent disponibles avec les sources locales/mock ; en mode réel, ils signalent explicitement l'absence du contrat au lieu de simuler un succès.

Le scanner Web exige `localhost` ou une origine HTTPS et l’autorisation caméra du navigateur.

## Architecture

```text
lib/
├── app/router/              # GoRouter et contrats de navigation
├── core/
│   ├── config/              # environnement et messages techniques
│   ├── network/             # client HTTP, endpoints et API mock
│   └── storage/             # session chiffrée
├── data/
│   ├── datasources/         # sources locales et distantes
│   ├── models/dto/          # adaptation JSON
│   └── repositories/        # implémentations des contrats métier
├── design_system/
│   ├── layouts/             # responsive et breakpoints
│   ├── theme/               # thèmes Material 3 clair/sombre
│   └── tokens/              # couleurs, espacements, rayons, durées, typo
├── domain/
│   ├── entities/            # objets métier
│   ├── repositories/        # interfaces
│   ├── use_cases/           # orchestration métier
│   └── value_objects/       # PhoneNumber et Money
├── presentation/
│   ├── bloc/                # états et événements par fonctionnalité
│   ├── screens/             # composition des pages
│   ├── widgets/             # composants réutilisables
│   └── models/              # modèles strictement visuels
├── l10n/                    # français et anglais
├── injection.dart           # composition GetIt
└── main.dart                # bootstrap et providers racine
```

Les montants du domaine sont stockés en unités entières XOF. Les tokens de session sont conservés avec `flutter_secure_storage`. Le changement et la réinitialisation du PIN passent par les repositories ; la réinitialisation exige un code de vérification.

Les routes ne transportent aucun callback : les écrans QR, paiement et code secret communiquent avec les BLoC et retournent uniquement des résultats de navigation typés. Les routes du code secret utilisent des paramètres d’URL simples et restent donc compatibles avec les deep links.

## Qualité

```bash
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info 80
```

La suite comprend 62 tests unitaires, BLoC, widgets, intégration, accessibilité et non-régression visuelle. La couverture de lignes actuelle est de 80,79 % et la CI refuse toute régression sous 80 %. Les lints renforcés vérifient notamment les futures ignorées, les flux non fermés, les impressions console et les conventions de noms.

Le pipeline [Flutter CI](.github/workflows/flutter_ci.yml) vérifie à chaque pull request le formatage, l’analyse stricte, les tests, la couverture ainsi que les builds Web et Android release. Dependabot surveille les dépendances Dart et GitHub Actions.

## Builds

Web :

```bash
flutter build web --release
```

Android debug :

```bash
flutter build apk --debug
```

Android release non signé :

```bash
flutter build apk --release
```

Pour signer la release, copier `android/key.properties.example` vers `android/key.properties`, renseigner le chemin du keystore et les secrets, puis relancer le build. Les vrais secrets et keystores sont ignorés par Git.

Linux nécessite les dépendances système Flutter Desktop :

```bash
sudo apt install clang cmake ninja-build libgtk-3-dev
flutter run -d linux
```

La compilation iOS nécessite macOS et Xcode.
