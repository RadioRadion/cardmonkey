# CardMonkey - Instructions pour Claude

## Stack Technique

| Composant | Version/Détail |
|-----------|----------------|
| Ruby | 3.3.0 |
| Rails | 7.1.3.1 |
| Base de données | PostgreSQL |
| Serveur | Puma 6.4.2 |
| Background Jobs | Sidekiq 7.0 + Redis |
| CSS | Tailwind CSS 3.x (gem tailwindcss-rails 2.3) |
| JavaScript | Stimulus + Turbo (Hotwire) |
| Assets | Importmap (pas de Node build) |
| Tests | RSpec + FactoryBot + Capybara |
| Auth | Devise |
| Pagination | Pagy 6.0 |
| Images | Cloudinary |

### Commandes de développement

```bash
# Lancer le serveur de dev
bin/dev

# Lancer les tests
bundle exec rspec

# Lancer un test spécifique
bundle exec rspec spec/models/user_spec.rb

# Migrations
rails db:migrate

# Console Rails
rails console

# Linter / qualité de code
bundle exec rubocop          # vérifier le style
bundle exec rubocop -a       # auto-fix
```

## Architecture

### Structure des dossiers

```
app/
├── controllers/     # Contrôleurs Rails (MatchesController, TradesController...)
├── models/          # Modèles ActiveRecord + concerns + forms
│   ├── concerns/    # Modules partagés (CardConditionManagement, TradeStatusChecker)
│   └── forms/       # Form objects (UserCardForm, UserWantedCardForm)
├── services/        # Services métier (Cards::SearchService, TradeCardCollector)
├── jobs/            # Background jobs Sidekiq (MatchingJob)
├── javascript/      # Stimulus controllers
│   └── controllers/ # chat_controller.js, trade_controller.js...
├── views/           # Templates ERB
└── mailers/         # TradeMailer, ApplicationMailer
```

### Logique métier principale

**Matching (algorithme d'échange)** : `app/jobs/matching_job.rb`
- Trouve les correspondances entre cartes possédées et cartes recherchées
- Filtre par condition, langue, et exclut les auto-matches
- Exécuté en asynchrone via Sidekiq

**Collection (gestion des cartes)** :
- `app/models/user_card.rb` : Cartes possédées par un utilisateur
- `app/models/user_wanted_card.rb` : Cartes recherchées par un utilisateur
- `app/models/forms/` : Form objects pour la création/édition

**Trades (échanges)** : `app/models/trade.rb`
- États : pending → modified → accepted → done (ou cancelled)
- Double confirmation requise pour compléter un échange

### Modèles clés et relations

```
User
├── has_many :user_cards (cartes possédées)
├── has_many :user_wanted_cards (cartes recherchées)
├── has_many :trades (échanges initiés)
├── has_many :matches
└── has_many :ratings

UserCard → CardVersion → Card
UserWantedCard → Card (flexible) ou CardVersion (spécifique)
Match → relie UserCard et UserWantedCard
Trade → contient plusieurs UserCards via TradeUserCard
```

## Conventions

### Nommage
- **Modèles** : CamelCase singulier (`User`, `Trade`, `Match`)
- **Contrôleurs** : CamelCase pluriel (`UsersController`, `TradesController`)
- **Fichiers Ruby** : snake_case (`user_card.rb`, `matching_job.rb`)
- **Stimulus controllers** : snake_case (`chat_controller.js`, `trade_controller.js`)
- **Services** : Namespaced si besoin (`Cards::SearchService`)

### Patterns utilisés
- **Form Objects** : `ActiveModel::Model` dans `app/models/forms/`
- **Services** : Pattern `.call()` dans `app/services/`
- **Concerns** : `ActiveSupport::Concern` dans `app/models/concerns/`
- **Enums** : Pour les statuts (`enum status: { pending: 0, modified: 1, ... }`)

### Conditions des cartes (échelle)
```
poor (0) < played (1) < light_played (2) < good (3) < excellent (4) < near_mint (5) < mint (6)
```

### Langues supportées
`fr`, `en`, `de`, `it`, `zhs`, `zht`, `ja`, `pt`, `ru`, `ko` + `any` pour UserWantedCard

## Règles Non Négociables

### Git
- **Ne jamais commit sans demande explicite de l'utilisateur**
- **Ne jamais push sans demande explicite**
- Toujours créer une branche pour une nouvelle feature (sauf demande contraire)
- Format de commit : message clair et concis

### Base de données
- **Ne pas modifier le schéma (migrations) sans validation explicite**
- Toujours vérifier l'impact sur les données existantes

### Sécurité
- **Ne JAMAIS lire les fichiers .env ou credentials**
- Ne jamais exposer de secrets dans le code
- Valider les entrées utilisateur

### Code
- Respecter le style RuboCop (max 120 caractères par ligne)
- Ne pas ajouter de gems sans validation
- Préférer l'édition de fichiers existants à la création de nouveaux
- Tests requis pour les nouvelles fonctionnalités publiques
- Tests dans `spec/`, organisés en miroir de `app/` (`spec/models/`, `spec/services/`, etc.)
- FactoryBot pour les fixtures, Capybara pour les feature specs

### Front-end
- Utiliser Tailwind CSS (pas de CSS custom sauf nécessité)
- Utiliser Stimulus pour le JS interactif
- Utiliser Turbo pour les interactions AJAX
- **Utiliser la skill `frontend-design`** pour tout changement front significatif (nouvelle page, refonte UI, composants complexes). Cette skill génère du code front production-ready avec un design soigné.

## Déploiement

- **Plateforme** : Render
- **Build** : `bin/render-build.sh`
- **Cron** : Sync Scryfall quotidien à 4h UTC
- **Variables d'env** : Configurées sur Render (ne pas toucher)
