# Audit CardMonkey - État des lieux

## Section 1 : Probablement OK (Features complètes et fonctionnelles)

| Feature | Fichiers clés | État |
|---------|---------------|------|
| **Gestion collection (UserCards)** | `user_cards_controller.rb`, `user_card.rb` | Complet - CRUD, filtres, pagination Pagy |
| **Cartes recherchées (UserWantedCards)** | `user_wanted_cards_controller.rb`, `user_wanted_card.rb` | Complet - Support multi-langues |
| **Matching intelligent** | `matching_job.rb`, `match.rb` | Complet - Async via Sidekiq |
| **Système de trading** | `trades_controller.rb`, `trade.rb` | Complet - Workflow pending→done |
| **Messagerie temps réel** | `messages_controller.rb`, `chatroom.rb` | Complet - Action Cable, attachments, reactions |
| **Notifications** | `notifications_controller.rb`, `notification.rb` | Complet - Temps réel, scopes |
| **Profils utilisateurs** | `users_controller.rb`, `user.rb` | Complet - Géolocalisation, stats |
| **Authentification** | Devise | Standard et fonctionnel |
| **Tests modèles** | 11/15 modèles testés (73%) | Bien structurés, FactoryBot |

## Section 2 : À finir (Travail en cours ou incomplet)

| Élément | Fichier | Problème | Priorité |
|---------|---------|----------|----------|
| **37 fichiers modifiés non commités** | Divers | Changements du 1er avril en attente de commit | Haute |
| **21 fichiers untracked** | Ratings, PWA, Sidekiq config | Nouvelles features non intégrées à git | Haute |
| **Tests manquants** | `rating.rb`, `message_reaction.rb` | Modèles récents sans specs | Moyenne |
| **Vue suggestions incomplète** | `_suggestions.html.erb` | Commentaire "Autres détails ici" | Basse |
| **Service recherche basique** | `cards/search_service.rb` | Recherche anglais uniquement, pas de filtres avancés | Basse |

## Section 3 : Cassé ou douteux

| Problème | Fichier | Ligne(s) | Sévérité |
|----------|---------|----------|----------|
| **Concern cassé** | `trade_status_checker.rb` | ~5 | CRITIQUE - Appelle `active_trade_count` qui n'existe pas |
| **Code dupliqué matching** | `user_card.rb` vs `matching_job.rb` | 90-134 vs 25-63 | CRITIQUE - Même logique en double |
| **Confusion ID Scryfall** | `user_card_form.rb`, `user_wanted_card_form.rb` | 100, 91 | Moyenne - `scryfall_id` est en fait `oracle_id` |
| **Mailer orphelin** | `sponsor_mailer.rb` | 1-8 | Mineure - Pas de template, code mort |
| **Contrôleur surdimensionné** | `trades_controller.rb` | 425 lignes | Moyenne - SRP violé, 26 méthodes |

---

## Contexte git

**Branche actuelle** : master

**Derniers commits** :
- `c74807c` - trade acceptance improved
- `7c3ef25` - notification counter fixed
- `7695ebb` - cloudinary config for production

**Travail récent (3 mois)** :
- Janvier : Intégration Scryfall API
- Mars : Features trading + notifications
- Avril : Deployment production + Ratings + PWA

**12 branches locales** à nettoyer (create_match_jobs, last_things_before_mvp, etc.)
