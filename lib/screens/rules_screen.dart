import 'package:flutter/material.dart';

import '../theme/songo_theme.dart';

class _RuleSection {
  final String title;
  final String body;
  const _RuleSection(this.title, this.body);
}

const _sections = [
  _RuleSection(
    'Objectif',
    'Le plateau contient 70 graines en tout. Le premier joueur qui en '
        'capture au moins 40 gagne la partie.',
  ),
  _RuleSection(
    'Le plateau',
    '2 rangées de 7 cases face à face. Chaque joueur possède une rangée '
        '(5 graines par case au départ). Tu ne peux jouer que dans tes '
        'propres cases — sur l\'écran, seules les cases entourées d\'un '
        'liseré doré sont jouables à ton tour.',
  ),
  _RuleSection(
    'Jouer un coup',
    'Touche une de tes cases jouables : toutes ses graines sont ramassées '
        'puis semées une par une, case après case, en tournant autour du '
        'plateau (jamais de case sautée) — d\'abord dans ton propre camp, '
        'puis chez l\'adversaire.\n\n'
        'Si la case choisie contient plus de 13 graines, le semis fait un '
        'tour complet du plateau sans remplir la case de départ, puis '
        'continue uniquement chez l\'adversaire (en repartant de sa '
        'première case si besoin).',
  ),
  _RuleSection(
    'Capturer des graines',
    'Si ta toute dernière graine tombe dans une case adverse qui contient '
        'alors 2, 3 ou 4 graines, tu captures cette case. Si les cases '
        'juste avant (toujours chez l\'adversaire) ont aussi 2 à 4 graines, '
        'tu les captures en chaîne, l\'une après l\'autre.\n\n'
        'Exception : si tu termines dans la toute première case adverse '
        'après avoir fait au moins un tour complet du plateau, tu ne '
        'captures que cette dernière graine.',
  ),
  _RuleSection(
    'Ce qui est interdit',
    '• Jouer ta dernière case (case 7) si elle ne contient que 1 ou 2 '
        'graines — sauf si c\'est ton seul coup possible.\n'
        '• Vider complètement le camp adverse : si une capture devait '
        'faire ça, elle est annulée et les graines restent en place.',
  ),
  _RuleSection(
    'Solidarité',
    'Si le camp adverse est entièrement vide, tu dois obligatoirement '
        'jouer un coup qui lui envoie au moins 7 graines. Si aucun de tes '
        'coups n\'y arrive, tu dois jouer celui qui lui en envoie le plus. '
        'Si même ça n\'est pas possible, la partie s\'arrête.',
  ),
  _RuleSection(
    'Fin de partie',
    'La partie s\'arrête dès qu\'un joueur atteint 40 graines, ou s\'il '
        'reste moins de 10 graines sur le plateau (les graines restantes '
        'reviennent alors au camp où elles se trouvent), ou si la règle de '
        'solidarité ne peut plus être respectée par un joueur.\n\n'
        'Si personne n\'atteint 40 graines, la partie est match nul.',
  ),
];

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Règles du Songo')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: SongoTextStyles.title),
              const SizedBox(height: 6),
              Text(section.body, style: SongoTextStyles.label),
            ],
          );
        },
      ),
    );
  }
}
