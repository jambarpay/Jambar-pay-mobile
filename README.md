# Jambar Pay Mobile

Frontend Flutter de Jambar Pay pour Android, iOS, Web et Linux. L’application couvre l’authentification, le portefeuille, l’historique, les restaurants partenaires, le paiement QR et le profil.

## Démarrage rapide

```bash
flutter pub get
flutter run -d chrome --no-web-resources-cdn
```

Le bootstrap Web utilise CanvasKit local et Roboto est embarqué dans
l’application. Pour conserver ces ressources dans le cache PWA de production :

```bash
flutter build web --release \
  --no-web-resources-cdn \
  --pwa-strategy offline-first
```

L’application utilise le backend réel par défaut, y compris en mode debug. Les sources mock/locales sont réservées aux tests et doivent être activées explicitement avec les `--dart-define` ci-dessous.

Pour afficher les appareils disponibles :

```bash
flutter devices
```

Si Android n’apparaît pas, connecter un téléphone avec le débogage USB activé ou démarrer un émulateur Android, puis relancer `flutter devices`.

## Environnements

Les valeurs sont injectées à la compilation avec `--dart-define` :

- `API_BASE` : origine publique du front Web qui relaie `/api/v1` vers la gateway ; valeur de production `https://www.jambaarpay.com`.
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
  --dart-define=API_BASE=https://www.jambaarpay.com
```

Test Android actuel sur le VPS :

```bash
flutter run -d RF8W30AMCYW \
  --dart-define=API_BASE=https://www.jambaarpay.com
```

Le Web utilise `/api/v1` sur la même origine et Vercel relaie ces requêtes vers
la gateway. Sur mobile, `API_BASE` doit donc être l’origine HTTPS
`https://www.jambaarpay.com` (sans `/api/v1`, ajouté par le client). Le domaine et
sa réécriture Vercel doivent rester disponibles en production.

Le mobile consomme les contrats `/api/v1/auth`, `/api/v1/restaurants`, `/api/v1/qrs` et `/api/v1/payments`. `API_BASE` doit désigner une gateway qui conserve ces chemins. La gateway présente dans le dépôt doit encore être corrigée avant un test bout en bout réel.

Le parcours de connexion salarié utilise `/api/v1/auth/employee/login`. Une migration du `user-service` initialise le salarié de validation `782917770` avec un PIN haché. Le paiement QR de démonstration n’est pas exposé dans l’application.

L'invitation SMS est déclenchée par le backend quand l'entreprise crée le salarié,
sans intervention du mobile. La saisie du numéro dans le mobile déclenche ensuite
`/api/v1/auth/employee/onboarding/start`. Les appuis répétés pendant cet appel
ne produisent qu'une requête ; une réponse tardive après un retour est ignorée.
Une erreur d'activation laisse l'utilisateur sur la saisie du numéro avec le
message du serveur, y compris la limite des deux envois OTP (`429`). Le mobile
ne propose l'étape suivante qu'après une décision booléenne explicite dans une
réponse réussie. L'accusé de mise en file ne confirme pas la livraison du SMS.

Après deux minutes, le bouton « Renvoyer le code » appelle
`POST /api/v1/auth/register/resend` avec le numéro du salarié. Une réponse
`success: true` efface l'ancien code saisi et relance les deux minutes d'attente.
Un refus ou une réponse invalide affiche une erreur sans annoncer un renvoi
réussi. Le serveur doit autoriser le remplacement d'un OTP expiré ; la limite
de deux envois par activation continue de s'appliquer.

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

## Choix du service et catégories de partenaires

Dans l’espace salarié, l’onglet et le raccourci **Services** remplacent
l’ancien libellé « Restaurants ». Le salarié peut choisir **Restaurant**,
**Boutique**, **Supermarché** ou **Marché**, puis continuer vers les partenaires
de cette catégorie. « Voir tous les partenaires » ouvre directement la liste
complète. Les filtres et la recherche par nom/adresse s’appliquent à la liste
et à la carte. Ils ne changent ni les identifiants des partenaires, ni les
autorisations, ni le fonctionnement du paiement ou du QR.

Le mobile lit la propriété `partnerType` de chaque réponse de
`GET /api/v1/restaurants` (`RESTAURANT`, `SHOP`, `SUPERMARKET`, `MARKET`). Il accepte
aussi `category` et les libellés API `BOUTIQUE`, `SUPERMARCHE`, `MARCHE`.
Pour les anciennes réponses et les caches hors ligne sans catégorie, le défaut
reste **Restaurant**. Une valeur inconnue reste visible dans **Tous**, sans être
classée à tort dans une des quatre catégories.

**Prérequis serveur/admin :** les catégories doivent être enregistrées et
renvoyées par le serveur pour alimenter les nouveaux filtres. Le mobile
n’invente pas de boutiques, supermarchés ou marchés ; une catégorie sans
partenaire affiche un message explicite. Le champ est géré dans la création et la
modification des partenaires de `Webjambarpay` et dans `restaurant_service` avec
la migration `V4__add_partner_type.sql`. Déployer ce serveur avec Flyway activé
avant l’admin et le mobile. Aucun nouveau secret ou variable d’environnement
n’est nécessaire.

## Qualité

### Gestion des erreurs

`AppFailure` porte une catégorie explicite, le statut HTTP et, si le serveur les
fournit, le code métier, `Retry-After` en secondes et l’identifiant de corrélation.
`ApiException` conserve son interface existante. Les repositories propagent les
erreurs sans les convertir en `Exception` génériques ; les décisions ne doivent
jamais dépendre des mots contenus dans un message.

- La connexion locale de secours reste possible uniquement après une panne
  réseau ou un délai dépassé sans réponse HTTP. Un refus serveur, notamment
  `401`, `403` ou `429`, ne déclenche jamais cette connexion.
- Les lectures peuvent utiliser le cache après une panne réseau, un délai
  dépassé ou une erreur serveur `5xx`. Une réponse invalide ou un refus métier
  est remonté à l’appelant. Un échec d’écriture du cache ne transforme pas une
  réponse réseau réussie en échec.
- `failureMessage` produit les messages français et anglais des écrans. Les
  erreurs techniques ne sont pas affichées telles quelles ; certains messages
  métier structurés `4xx` sont conservés après filtrage.
- Une confirmation de paiement interrompue présente un résultat incertain et
  invite à consulter l’historique avant de payer à nouveau. Aucun renvoi
  automatique du paiement n’est effectué.
- Un montant absent, non numérique ou non fini, ou une date non interprétable,
  produit une erreur de réponse invalide, sans inventer un zéro ou une date.
- `FailureDiagnostics` journalise l’opération, la catégorie, le statut et la
  corrélation validée, avec la pile d’appels. Le message brut, le contenu HTTP,
  le PIN et le jeton de session ne sont pas ajoutés aux journaux.

Les tests de `failure_handling_test.dart`, `error_policies_test.dart` et
`payment_bloc_test.dart` vérifient notamment les refus avec un cache disponible,
les erreurs de protocole, les messages localisés et les paiements incertains.
Ces contrôles locaux ne remplacent pas les essais bout en bout avec le backend.

### Vérifications

```bash
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info 80
```

La suite comprend des tests unitaires, BLoC, widgets, intégration, accessibilité et non-régression visuelle. La CI exige une couverture de lignes d’au moins 80 % ; vérifier la mesure réelle avec la commande ci-dessus. Les lints renforcés vérifient notamment les futures ignorées, les flux non fermés, les impressions console et les conventions de noms.

Le pipeline [Flutter CI](.github/workflows/flutter_ci.yml) vérifie à chaque pull request le formatage, l’analyse stricte, les tests, la couverture ainsi que les builds Web et Android release. Dependabot surveille les dépendances Dart et GitHub Actions.

## Builds

Web :

```bash
flutter build web --release \
  --no-web-resources-cdn \
  --pwa-strategy offline-first
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
