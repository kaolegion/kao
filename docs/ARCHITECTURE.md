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
- exécution via le gateway existant

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

Ray distingue maintenant explicitement :

- l’intention opérateur exprimée
- la classe cognitive dérivée du prompt
- la famille de route cognitive associée
- l’action opératoire lisible associée
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
- la capacité runtime peut néanmoins rester favorable
- `hybrid state` peut donc rester `hybrid-ready`
- pendant que `decision state` devient `blocked-unsupported-forcing`
- et que `mode` devient `degraded`
- la lecture registry sélectionnée peut rester `none`

Finalité :

préparer Kao à :

- un routeur multi-LLM vivant
- une cognition hybride dynamique
- une orchestration agentique future
- une priorisation adaptative des modèles
- une lecture humaine de la décision avant automatisation plus lourde
- un futur classement vivant des modèles/providers
- un futur pilotage plus intelligent fondé sur la maturité runtime
- un futur paysage vivant des modèles lisible par statut stratégique

---

## Layer 6 — Provider Layer

Chaque provider expose :

- availability
- health
- note opérateur
- capacité réelle d’inférence
- policy locale si applicable

### Mistral

- provider cloud principal
- nécessite secret externe
- inference HTTP déterministe
- priorité de routage par défaut
- score fort quand prêt
- entrée canonique dans le registry

### Ollama

- provider local évolutif
- stub opératoire disponible
- backend réel détectable
- modèle cible explicite
- appels réels activables par policy
- journalisation distinguant tentative, stub et real
- score progressif selon maturité locale réelle
- entrée canonique dans le registry

But :

préparer Kao à :

- inference offline
- autonomie cognitive machine
- orchestration hybride cloud/local
- classement lisible des capacités disponibles

---

## Layer 7 — Agent Orchestration

Responsabilités :

- planification
- supervision
- pipeline exécution

---

## Layer 8 — Dev Intelligence

Responsabilités :

- compréhension repository
- assistance refactor
- stratégie sprint

---

## Layer 9 — Terminal Cognitive UX

Responsabilités :

- scènes opératoires
- narration runtime
- visibilité décisions gateway
- lecture directe des états cognitifs
- visibilité du passage cloud → local
- visibilité du modèle local ciblé
- visibilité du mode stub / backend / model-ready
- visibilité synthétique via ray
- visibilité de la raison de sélection
- visibilité du différentiel de score cloud/local
- visibilité de la différence entre capacité et décision
- visibilité du registry vivant
- visibilité du modèle actuellement retenu dans le registry

---

## Layer 10 — Communication

Canaux :

- terminal
- chat
- stream
- logs enrichis

---

## Layer 11 — Infra

Responsabilités :

- cluster
- inference distante
- monitoring
- distribution Kao


### Intentions opérateur

Première classification heuristique actuellement exposée par `ray ask` :

- file-op
- system-op
- cognitive-light
- cognitive-heavy
- unknown

Familles de route cognitives actuellement exposées :

- local-agent
- llm-light
- llm-heavy
- unknown

Cette couche est actuellement :

- déterministe
- heuristique
- lisible terminalement
- non-LLM pour la décision
- préparatoire à une orchestration agentique future
