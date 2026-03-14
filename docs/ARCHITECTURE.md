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
- exécution via le gateway existant
- préparation d’une exécution locale future plus directe

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

Ray distingue maintenant explicitement :

- l’intention opérateur exprimée
- la classe cognitive dérivée du prompt
- la famille de route cognitive associée
- l’action opératoire lisible associée
- la stratégie d’exécution dérivée
- la surface d’exécution retenue
- le mode d’exécution courant
- la décision d’exécution retenue
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

### État hybride

- hybrid-ready
- cloud-only
- local-only
- unavailable

### Lecture registry

- registry count
- registry provider
- registry model
- registry family
- registry base
- registry declared
- registry runtime
- registry score
- registry rank
- registry maturity

### Lecture scout

- provider
- model
- family
- maturity
- rank
- status
- ordre comparatif par rang

Doctrine de lecture :

- `forced raw value` expose l’entrée opérateur telle qu’exprimée
- `forced provider` expose le provider supporté normalisé retenable
- `forced state` expose si le forcing est unset, supported ou unsupported
- `decision state` décrit si une décision effective peut être retenue
- `decision` décrit si le bridge d’exécution retient une stratégie exploitable
- `execution mode` prépare une gouvernance future de l’exécution
- `surface` expose la famille d’exécution actuellement retenue
- `strategy` expose la stratégie dérivée de l’intention classifiée
- `hybrid state` décrit la capacité runtime cloud/local
- `mode` traduit la lecture opérateur effective de la situation
- `registry declared` conserve l’état canonique déclaré dans le registry
- `registry runtime` traduit la lecture runtime actuelle de cette entrée
- `registry score` prépare une première pondération runtime lisible
- `registry rank` prépare une comparaison opérateur entre entrées
- `registry maturity` expose une synthèse courte de maturité
- `status` expose une lecture stratégique dérivée de la maturité de chaque entrée visible
- cette lecture enrichie n’altère pas encore la décision réelle du routeur

Cas important :

- un forcing invalide peut bloquer la décision
- dans ce cas :
  - `forced raw value` peut conserver l’entrée invalide
  - `forced provider` peut rester `none`
  - `forced state` peut devenir `unsupported`
