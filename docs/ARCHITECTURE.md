# KAO — Architecture

## Vue générale

Kao est conçu comme un système cognitif stratifié.

Chaque couche possède une responsabilité claire
et contribue à un runtime opératoire cohérent.

---

## Gouvernance source vs runtime

Kao distingue explicitement deux domaines :

### Source versionnée

La source versionnée contient :

- le code shell
- les bibliothèques
- les entrées CLI
- la documentation
- les scénarios E2E
- les journaux de sprint

Cette couche doit rester :

- relisible
- diffable
- stable
- commitable

### État runtime éphémère

L’état runtime contient :

- logs d’exécution
- snapshots runtime
- états temporaires produits par validation
- traces locales de diagnostic

Cette couche peut muter librement pendant :

- une exécution opérateur
- une validation
- un E2E
- une inspection système

Doctrine :

- le runtime n’est pas une source canonique
- un artefact runtime ne doit pas polluer le contrôle de version
- une mutation runtime ne doit pas imposer de restauration manuelle permanente
- la gouvernance Git doit distinguer clairement source et état éphémère

Règle actuellement verrouillée :

- `state/runtime/runtime.snapshot` est un artefact runtime éphémère ignoré par Git

---

## Gouvernance locale des chemins système

Kao introduit une **gouvernance canonique des chemins locaux critiques**.

Chaque chemin local enregistré possède :

- un type attendu (dir ou file)
- un owner attendu
- un group attendu
- un mode attendu

Cette baseline est définie dans un registry canonique :

- `lib/system/local_paths_registry.sh`

Elle constitue :

- une référence de conformité locale
- une source de diagnostic opérateur
- une base de réparation automatisée contrôlée

---

## Diagnostic de dérive d’ownership

La surface :

- `ray system inspect`

expose maintenant pour chaque chemin :

- état réel (OK / MISSING / TYPE-MISMATCH / UNREADABLE)
- owner réel
- group réel
- mode réel
- owner attendu
- group attendu
- mode attendu
- signal de dérive

Un signal de dérive peut être :

- `OK`
- `DRIFT:owner`
- `DRIFT:group`
- `DRIFT:mode`
- combinaisons compactes

Si le chemin est absent :

- owner réel = `n/a`
- mode réel = `n/a`
- drift = `n/a`

Cette surface permet :

- une lecture rapide d’un système incohérent
- une détection de dérive après installation ou manipulation root
- une intégration de réparation contrôlée directement depuis la surface opérateur

Les actions opératoires disponibles sont maintenant :

- `ray system repair --dry-run`
- `ray system repair`

Ces commandes :

- restent registry-driven
- ne créent aucun chemin manquant
- ne réparent que les chemins en état `OK`
- excluent les chemins `MISSING`, `TYPE-MISMATCH` ou `UNREADABLE`
- opèrent sur `owner`, `group` et `mode`

La surface de réparation expose les états suivants :

- `NOOP`
- `DRY-RUN`
- `REPAIRED`
- `SKIP`

Lecture opératoire :

- `NOOP` = chemin déjà aligné
- `DRY-RUN` = correction prévisualisée sans mutation
- `REPAIRED` = correction réellement appliquée
- `SKIP` = chemin non réparable dans son état courant

La réparation réelle recalcule ensuite l’état visible :

- owner courant
- group courant
- mode courant
- `post-drift`

Cela permet à l’opérateur de confirmer immédiatement :

- ce qui allait être corrigé
- ce qui a réellement été corrigé
- ce qui reste exclu volontairement

Doctrine de sécurité :

- aucune création implicite de chemin
- aucune réparation hors état `OK`
- aucune décision cachée hors registry canonique
- visibilité complète avant et après action

---

## Layer 0 — Machine Host

Responsabilités :

- CPU / RAM / GPU
- filesystem
- réseau
- capacités matérielles

---

## Layer 1 — Kao Operator System

Responsabilités :

- boot cognition
- orchestration runtime
- policy environnement
- supervision globale

Commandes structurantes :

- kao boot
- kao context
- kao runtime
- kao gateway

---

## Layer 2 — Identity Runtime

Gestion des perspectives actives :

- machine
- system
- owner
- user
- agent

---

## Layer 3 — Kao Brain

Responsabilités :

- mémoire opératoire
- raisonnement
- surface d’inférence
- continuité cognitive

Entrée canonique actuelle :

- brain infer

---

## Layer 4 — Gateway Routing Layer

Responsabilités :

- sélection dynamique de provider
- lecture d’état runtime
- routage cloud / local
- journalisation runtime
- cockpit diagnostic lisible

Doctrine actuelle :

- Kao ne fixe pas un provider prioritaire par principe
- le système lit d’abord l’état courant
- la politique visible actuelle est `best-available-by-state`
- un provider peut être sélectionné parce qu’il est le meilleur candidat disponible à l’instant T
- la gouvernance sépare explicitement réseau, cognition locale et cognition cloud

Expression canonique actuelle des états de travail :

- `(Device + kaoOS = on) + (LLM + @ = off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local off & cloud on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local & cloud + @ on) + moi`

Lecture opératoire :

- `@` représente l’état réseau
- `LLM local` et `cloud` sont deux axes distincts
- un accès réseau ne signifie pas qu’un cloud LLM doit être utilisé
- une cognition locale peut exister en offline complet
- Kao doit toujours vérifier la meilleure option disponible lors de l’interaction

États de gouvernance désormais visibles dans les surfaces opérateur :

- `network state`
- `local llm state`
- `cloud llm state`
- `execution mode`
- `selection policy`

Modes d’exécution introduits :

- `os-core`
- `local-cognitive`
- `local-first-network-enabled`
- `cloud-cognitive`
- `hybrid-competitive`
- `state-mixed`

---

## Layer 5 — Hybrid Router Operator Surface (Ray)

Ray constitue la première surface opérateur du routeur hybride.

Il expose maintenant :

- une lecture cognitive du routage
- une inspection locale sûre
- une lecture d’ownership système
- une détection de dérive structurée
- une réparation réelle contrôlée
- une maintenance locale registry-driven
- une lecture de gouvernance runtime visible
- une politique de sélection affichée

La surface `ray status` rend maintenant lisibles :

- la route actuellement sélectionnée
- l’état réseau
- l’état LLM local
- l’état LLM cloud
- le mode d’exécution courant
- la politique de sélection `best-available-by-state`

Important :

- `mistral` peut être sélectionné parce qu’il est actuellement le meilleur candidat disponible
- cela ne signifie pas qu’il soit prioritaire par doctrine
- Kao vise une sélection future des meilleurs agents selon la valeur de la tâche et l’état réel du système

---

## Runtime session cognition layer

Kao introduit maintenant une couche de session runtime explicite.

Artefacts runtime :

- `state/runtime/session.current`
- `state/runtime/session.history`
- `state/runtime/session.timeline`
- `state/sessions/`

Bibliothèque canonique :

- `lib/runtime/session_manager.sh`
- `lib/runtime/event_normalizer.sh`

Configuration canonique :

- `config/event_taxonomy.env`

Cette couche expose :

- ouverture implicite ou explicite de session
- état de session courant
- respiration visible pendant `ray run`
- fermeture de session avec archivage lisible
- historique local des sessions fermées
- timeline canonique des événements de session
- snapshot dédié pour chaque session clôturée
- enrichissement sémantique non destructif des événements timeline

Les attributs actuellement gouvernés sont :

- identifiant de session
- identifiant d’événement
- version d’événement
- heure de début
- heure de fin
- durée
- machine
- user
- état internet
- source LLM (`cloud`, `local`, `none`)
- gateway principal
- agents secondaires appelés
- dernier événement visible sur la session active
- détail opératoire d’événement pour la timeline
- taxonomie sémantique d’événement

Surface opérateur associée :

- `ray session`
- `ray session open`
- `ray session close`
- `ray session history`
- `ray session timeline`

Doctrine :

- `session.current` est mutable et locale
- `session.history` est une trace runtime locale compacte
- `session.timeline` est la ligne canonique d’événements de session
- `state/sessions/` contient les snapshots fermés par session
- cette couche ne remplace pas la gouvernance source Git
- elle rend visible la respiration de Kao au niveau session
- elle prépare une future UX timeline sans transformer le runtime en source versionnée
- l’enrichissement sémantique doit rester compatible avec la lecture shell existante

Lecture opératoire :

- une session active représente un cycle de présence opérateur
- le gateway visible représente l’agent principal au moment courant
- la liste `agents` représente les surfaces ou sous-agents activés pendant la session
- `session.history` agit comme un index lisible des sessions clôturées
- `session.timeline` agit comme une séquence canonique grep-friendly des événements runtime
- chaque snapshot de `state/sessions/` préserve l’état fermé complet d’une session
- la taxonomie sémantique rend la timeline lisible comme langage narratif machine + humain

Format canonique timeline :

- une ligne = un événement
- préfixe canonique : `SESSION_EVENT`
- structure : `SESSION_EVENT|event_version=...|event_id=...|at=...|session_id=...|type=...|machine=...|user=...|internet=...|llm=...|gateway=...|agents=...|detail=...`

Règle d’enrichissement :

- le champ `type` reste stable et grep-friendly
- le champ `detail` peut être enrichi sémantiquement
- l’enrichissement actuel ajoute des signaux comme :
  - `family=...`
  - `scope=...`
  - `intensity=...`
  - `surface=...`
  - `action=...`

Types minimaux introduits dans ce sprint :

- `session-open`
- `session-touch`
- `session-close`

Familles actuellement visibles :

- `session_lifecycle`
- `operator_surface`

### Git hygiene note

Les artefacts suivants sont explicitement traités comme runtime local éphémère et ignorés par Git :

- `state/runtime/session.current`
- `state/runtime/session.history`
- `state/runtime/session.timeline`
- `state/sessions/`


### Git hygiene note

Les artefacts suivants sont explicitement traités comme runtime local éphémère et ignorés par Git :

- `state/runtime/session.current`
- `state/runtime/session.history`
- `state/runtime/session.timeline`
- `state/sessions/`
