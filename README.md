# Songo

App Flutter du jeu de Songo (semailles, Cameroun/Gabon). Règles complètes:
voir `../Tout sur le Songho.md`.

## État actuel

- Moteur de règles complet (`lib/engine/songo_engine.dart`) + tests unitaires
  (`test/songo_engine_test.dart`) couvrant semis, prises, prise à la chaîne,
  exception case 1, interdits (case 7), solidarité, fin de partie.
- IA simple (minimax + alpha-bêta, profondeur 4) dans `lib/engine/ai_player.dart`.
- Historique local des 3 dernières parties (score + date) via
  `shared_preferences`, pas de base de données.
- UI Flutter basique: menu, plateau jouable, écran historique.
- Mode en ligne (réseau): pas encore implémenté, prévu plus tard.

Le SDK Flutter n'était pas installé sur la machine qui a généré ce code:
le code n'a donc pas encore été compilé ni testé automatiquement. À faire
en premier avant toute autre modification.

## Installer Flutter (si pas déjà fait)

Voir https://docs.flutter.dev/get-started/install/windows — puis vérifier:

```bash
flutter doctor
```

## Premier lancement

Depuis ce dossier (`songo_app/`):

```bash
flutter pub get
flutter test
flutter run -d chrome
```

`flutter test` doit faire passer tous les cas dans `songo_engine_test.dart`
— c'est la priorité: si un cas de règle est faux, corriger le moteur avant
de toucher à l'UI.

## Builds plateformes

```bash
flutter build apk          # Android
flutter build ios          # iOS (nécessite Xcode/Mac)
flutter build web          # Web
flutter build windows      # Windows desktop
```

## Prochaines étapes (hors périmètre actuel)

- Mode en ligne (2 appareils) une fois les premiers tests validés.
- Améliorer l'IA (profondeur adaptative, meilleure heuristique).
- Animations de semis graine par graine sur le plateau.
