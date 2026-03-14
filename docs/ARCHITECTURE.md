# KAO — Architecture

## Vue générale

Kao est conçu comme un système cognitif stratifié.

Chaque couche possède une responsabilité claire
et contribue à un runtime opératoire cohérent.

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
- exposition de readiness locale progressive
- exposition du modèle local cible
- exposition de l’état runtime local
- exposition de la policy d’inférence locale réelle
- exposition de l’état réel callable ou bloqué
- exposition de score cloud déterministe
- exposition de score local déterministe
- exposition du score de route retenue
- exposition d’une raison compacte de sélection
- lecture du modèle sélectionné dans un registry canonique
- exposition d’un premier score registry indépendant du routage
- exposition d’un score runtime registry pondéré par l’état réel
- exposition d’un rang opérateur comparatif
- exposition d’un niveau de maturité par entrée registry
- exposition d’un statut stratégique dérivé pour chaque entrée registry lue

Doctrine actuelle :

- priorité cloud par défaut
- fallback lisible vers local
- montée progressive vers cognition offline
- intelligence opérateur simple avant orchestration avancée
- registry lisible avant ranking dynamique réel
- intelligence de maturité lisible avant pilotage réel du routage
- première lecture stratégique du paysage modèle avant classement vivant complet

Objectifs d’évolution :

- inference locale réellement autonome
- continuité cognitive offline
- policy adaptative cloud/local
- stabilité agentique
- ranking vivant des modèles
- sélection provider plus intelligente

---

## Layer 5 — Hybrid Router Operator Surface (Ray)

Ray constitue la première surface opérateur du routeur hybride.

Responsabilités :

- lecture compacte du routage réel
- synthèse cloud/local readiness
- synthèse du mode opératoire courant
- exposition de l’état hybride global
- exposition de l’état de décision effectif
- exposition de la raison de sélection de route
- exposition d’un score compact par famille de route
- exposition du score de la route retenue
- exposition d’une lecture compacte du registry actif
- exposition du rang opérateur de l’entrée sélectionnée
- exposition de la maturité de l’entrée sélectionnée
- exposition d’un statut stratégique dérivé pour chaque entrée registry lue
- exposition d’une vue registry dédiée
- exposition d’une vue scout dédiée au paysage modèle multi-entrée ordonné
- exposition d’une première couche de classification d’intention opérateur
- exposition d’une famille de route cognitive avant exécution réelle
- exposition d’une action opératoire lisible dérivée du prompt
- exposition d’un pont d’exécution conscient de l’intention
- exposition d’une stratégie d’exécution dérivée du prompt
- exposition d’une surface d’exécution retenue
- exposition d’un mode d’exécution auto/local/cloud
- exposition d’un identifiant de chemin local canonique
- exposition d’un label de chemin local canonique
- exposition d’un état de chemin exécutable ou en attente
- exposition d’une séquence locale lisible avant action
- exposition d’une surface d’inspection système locale sûre
- exécution via le gateway existant pour les prompts cognitifs
- exécution locale via séquences internes déterministes pour un premier sous-ensemble sûr
- inspection locale read-only via registry canonique de chemins
- préparation d’une bibliothèque future de chemins et d’un registry d’actions

Ray ne remplace pas :

- la couche gateway
- la logique provider
- la journalisation runtime

Ray agit comme :

- une couche de lecture cognitive
- une surface de pilotage humain
- une abstraction du routage réel
- une première couche d’intelligence décisionnelle lisible
- une première fenêtre vers le paysage vivant des modèles
- un bridge explicable entre intention et exécution
- une couche de séquençage local bornée pour actions sûres reconnues
- une première couche d’inspection locale sûre et canonique

Ray distingue maintenant explicitement :

- l’intention opérateur exprimée
- la classe cognitive dérivée du prompt
- la famille de route cognitive associée
- l’action opératoire lisible associée
- la stratégie d’exécution dérivée
- la surface d’exécution retenue
- le mode d’exécution courant
- la décision d’exécution retenue
- l’identifiant de chemin local retenu
- le label de chemin local retenu
- l’état du chemin local retenu
- la séquence opératoire lisible avant action
- le provider normalisé retenable
- la validité de l’expression de forcing
- la capacité runtime disponible
- la décision effectivement retenue
- l’impact opérateur d’un forcing invalide
- la lecture registry sélectionnée
- le score runtime de l’entrée sélectionnée
- le rang opérateur de l’entrée sélectionnée
- la maturité de l’entrée sélectionnée
- le statut stratégique dérivé des entrées visibles
- la vue complète des entrées registry
- la vue scout du paysage modèle multi-entrée ordonné
- une vue locale d’inspection système dérivée d’un registry canonique de chemins

États exposés :

### Route sélectionnée

- cloud
- local
- none

### État de décision

- route-selected
- no-route-selected
- blocked-unsupported-forcing

### Decision d’exécution

- routed-execution
- no-execution-bridge

### Reason opérateur

- cloud-priority-ready
- local-only-available
- forced-provider-mistral
- forced-provider-ollama
- unsupported-forced-provider
- no-provider-ready

### Score opérateur

- cloud score
- local score
- route score

### Mode opérateur

- online
- offline
- degraded
- hybrid-ready

### Mode d’exécution

- auto
- local
- cloud

### Surface d’exécution

- gateway
- shell
- system
- none

### Stratégie d’exécution

- gateway-light
- gateway-heavy
- local-exec
- local-inspect
- unclassified

### État de chemin local

- path-ready
- local-action-pending
- local-inspection-pending
- gateway-ready
- unclassified

### État d’inspection système locale

- OK
- MISSING
- TYPE-MISMATCH
- UNREADABLE

---

## Layer 6 — Local System Path Registry + Safe Inspection

Cette couche introduit une cartographie locale canonique minimale.

Responsabilités :

- déclaration des chemins locaux officiels
- normalisation de la nomenclature de chemins
- lecture déterministe des surfaces locales attendues
- inspection read-only de l’état réel des chemins
- rendu opérateur stable et diffable
- préparation de futures surfaces doctor / scan / capabilities

Bibliothèques canoniques :

- `lib/system/local_paths_registry.sh`
- `lib/system/system_inspector.sh`

Doctrine actuelle :

- registry séparé de l’inspection
- aucun effet de bord
- aucune auto-réparation
- aucune écriture système
- aucun secret exposé
- lecture locale sûre avant extension des capacités

Surface opérateur actuelle :

- `ray system inspect`

Chemins canoniques actuellement suivis :

- root path
- bin directory
- library root
- cognition libs
- system libs
- state directory
- logs directory
- runtime state
- e2e scenarios
- agent registry

Cette couche prépare :

- doctor local
- scan de capacités
- lecture locale plus riche
- évolution vers runtime awareness étendue
