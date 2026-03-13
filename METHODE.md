# KAO — Méthode

## Cycle canonique
1. choisir le contexte
2. définir une mission unique
3. exécuter un sprint court
4. vérifier le résultat réel
5. valider par CLI et checks ciblés
6. valider end-to-end si le flux opérateur est touché
7. documenter l'état réel
8. fermer proprement
9. converger avant le sprint suivant
10. préparer la reprise

## Règles
- une mission principale par sprint
- micro-steps uniquement
- une action à la fois
- park les nouvelles idées
- privilégier le résultat visible
- garder une ancre de contexte
- corriger immédiatement les écarts
- toujours inspecter avant modification
- toujours injecter de manière déterministe
- séparer injection et vérification
- ne pas ouvrir un nouveau sprint sans convergence du précédent

## Inspection
Avant toute modification:
- lister les fichiers candidats
- relire les fichiers existants
- confirmer les points d'impact
- modifier uniquement les fichiers nécessaires

## Injection
La modification canonique se fait par injection déterministe:
- contenu complet explicite
- chemins absolus
- pas d'éditeur interactif
- pas d'hypothèse sur le contenu
- chmod immédiat si un exécutable est créé

## Vérification
Après chaque injection:
- relire les fichiers touchés
- exécuter le test le plus proche du changement
- confirmer l'absence d'erreur
- vérifier la cohérence doc / état / sprint

## Validation
Kao distingue 3 niveaux:
- check quick
- check full
- E2E

## E2E
Le système E2E sert de preuve terrain terminal-first.

Il mesure:
- score
- warn
- errors
- log de session

Il est requis dès qu'un changement touche:
- le boot
- le flux opérateur
- la récupération après erreur
- le comportement global de session

## Convergence
Un sprint est convergé quand:
- le code est en place
- la validation est réelle
- les documents racine sont alignés
- le sprint d'état est à jour
- la doctrine globale absorbe le changement
- le prochain point d'évolution est clair
