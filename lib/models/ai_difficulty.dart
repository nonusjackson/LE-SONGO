enum AiDifficulty {
  facile,
  moyen,
  difficile;

  String get label {
    switch (this) {
      case AiDifficulty.facile:
        return 'Facile';
      case AiDifficulty.moyen:
        return 'Moyen';
      case AiDifficulty.difficile:
        return 'Difficile';
    }
  }

  String get description {
    switch (this) {
      case AiDifficulty.facile:
        return 'Pour découvrir le jeu, l\'IA fait exprès des erreurs.';
      case AiDifficulty.moyen:
        return 'Un adversaire raisonnable, bat les hésitants.';
      case AiDifficulty.difficile:
        return 'IA à pleine puissance, difficile à surprendre.';
    }
  }

  /// Profondeur de recherche minimax.
  int get depth {
    switch (this) {
      case AiDifficulty.facile:
        return 2;
      case AiDifficulty.moyen:
        return 3;
      case AiDifficulty.difficile:
        return 5;
    }
  }

  /// Probabilité que l'IA joue un coup légal au hasard plutôt que le
  /// meilleur coup trouvé — indispensable en facile, une IA à profondeur
  /// réduite reste souvent trop forte pour un débutant sans ça.
  double get mistakeChance {
    switch (this) {
      case AiDifficulty.facile:
        return 0.35;
      case AiDifficulty.moyen:
        return 0.1;
      case AiDifficulty.difficile:
        return 0.0;
    }
  }
}
