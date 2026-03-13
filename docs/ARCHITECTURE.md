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

Doctrine actuelle :

- priorité cloud par défaut
- fallback lisible vers local
- montée progressive vers cognition offline

Objectifs d’évolution :

- inference locale réellement autonome
- continuité cognitive offline
- policy adaptative cloud/local
- stabilité agentique

---

## Layer 5 — Hybrid Router Operator Surface (Ray)

Ray constitue la première surface opérateur du routeur hybride.

Responsabilités :

- lecture compacte du routage réel
- synthèse cloud/local readiness
- synthèse du mode opératoire courant
- exposition de l’état hybride global
- exécution via le gateway existant

Ray ne remplace pas :

- la couche gateway
- la logique provider
- la journalisation runtime

Ray agit comme :

- une couche de lecture cognitive
- une surface de pilotage humain
- une abstraction du routage réel

États exposés :

### Route sélectionnée

- cloud
- local
- none

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

Finalité :

préparer Kao à :

- un routeur multi-LLM vivant
- une cognition hybride dynamique
- une orchestration agentique future
- une priorisation adaptative des modèles

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

### Ollama

- provider local évolutif
- stub opératoire disponible
- backend réel détectable
- modèle cible explicite
- appels réels activables par policy
- journalisation distinguant tentative, stub et real

But :

préparer Kao à :

- inference offline
- autonomie cognitive machine
- orchestration hybride cloud/local

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

