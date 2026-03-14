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
- une base future de réparation automatisée

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
- une future intégration d’outils de réparation contrôlée

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
- routage cloud / local
- gestion de fallback
- journalisation runtime
- cockpit diagnostic lisible

Doctrine actuelle :

- priorité cloud par défaut
- fallback lisible vers local
- montée progressive vers cognition offline

---

## Layer 5 — Hybrid Router Operator Surface (Ray)

Ray constitue la première surface opérateur du routeur hybride.

Il expose maintenant :

- une lecture cognitive du routage
- une inspection locale sûre
- une lecture d’ownership système
- une détection de dérive structurée
- une base future de maintenance automatisée

