import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:songo_app/main.dart';

void main() {
  testWidgets("L'accueil affiche les actions principales", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SongoApp());

    expect(find.text('Local (2 joueurs)'), findsOneWidget);
    expect(find.text("Contre l'IA"), findsOneWidget);
    expect(find.text('Règles du jeu'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
  });
}
