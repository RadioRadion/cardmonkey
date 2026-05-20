# Contexte du Projet CardMonkey

## Vue d'ensemble
Application de trading de cartes Magic permettant aux utilisateurs de gérer leur collection, rechercher des cartes souhaitées et effectuer des échanges avec d'autres collectionneurs.

## Architecture des Modèles

### Card
- Représente une carte Magic unique (entité de base)
- Attributs principaux:
  - scryfall_oracle_id
  - name_fr (nom français)
  - name_en (nom anglais)
- Relations:
  - has_many :user_wanted_cards
  - has_many :card_versions

### CardVersion
- Représente une version spécifique d'une carte (édition, illustration)
- Attributs principaux:
  - scryfall_id
  - rarity
  - frame
  - border_color
- Relations:
  - belongs_to :card
  - belongs_to :extension
  - has_many :user_cards

### User
- Représente un utilisateur de l'application
- Fonctionnalités:
  - Authentification via Devise
  - Géolocalisation
  - Préférences de matching (value_based ou quantity_based)
- Relations:
  - has_many :trades
  - has_many :messages
  - has_many :chatrooms (through messages)
  - has_many :user_cards
  - has_many :user_wanted_cards
  - has_many :matches
  - has_many :notifications

### UserCard
- Représente les cartes possédées par un utilisateur
- Attributs principaux:
  - quantity
  - condition (poor à mint)
  - language (français, anglais, etc.)
  - foil (boolean)
- Relations:
  - belongs_to :user
  - belongs_to :card_version
  - has_many :matches

### UserWantedCard
- Représente les cartes recherchées par un utilisateur
- Attributs principaux:
  - quantity
  - min_condition
  - language
  - foil
- Relations:
  - belongs_to :user
  - belongs_to :card
  - belongs_to :card_version (optional)
  - has_many :matches

## Fonctionnalités Principales

### 1. Gestion de Collection
- Ajout/suppression de cartes à sa collection
- Spécification de l'état, langue et quantité des cartes
- Support des cartes foil

### 2. Système de Recherche
- Recherche de cartes par nom (FR/EN)
- Filtrage par édition, rareté, etc.
- Gestion d'une liste de souhaits

### 3. Système de Matching
- Algorithme de correspondance basé sur:
  - Les cartes souhaitées vs collections disponibles
  - Préférences utilisateur (valeur ou quantité)
  - Conditions minimales requises
  - Localisation géographique

### 4. Communication
- Système de chat entre utilisateurs
- Notifications pour les nouveaux matches
- Gestion des propositions d'échange

### 5. Géolocalisation
- Recherche de collectionneurs par zone géographique
- Filtrage des matches par distance
- Définition d'une zone de recherche personnalisée

## Intégrations Externes

### API Scryfall
- Importation des données de cartes
- Récupération des images
- Mise à jour des prix

### Géolocalisation
- Utilisation de Geocoder pour la conversion d'adresses
- Calcul des distances entre utilisateurs

## Architecture Technique

### Backend
- Ruby on Rails
- Base de données PostgreSQL
- Action Cable pour le temps réel (chat)

### Frontend
- Tailwind CSS pour le styling
- JavaScript pour les interactions dynamiques
- Système de composants Rails

## Sécurité
- Authentification via Devise
- Validation des données utilisateur
- Protection CSRF
- Gestion des permissions

## Performance
- Indexation des recherches fréquentes
- Mise en cache des données Scryfall
- Optimisation des requêtes de matching

## Évolutivité
- Support multi-langues
- Architecture modulaire
- API extensible pour futures intégrations
