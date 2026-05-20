# Audit CardMonkey - État des lieux

*Mis à jour le 20 mai 2026*

## Section 1 : Probablement OK (Features complètes et fonctionnelles)

| Feature | Fichiers clés | État |
|---------|---------------|------|
| **Gestion collection (UserCards)** | `user_cards_controller.rb`, `user_card.rb` | Complet - CRUD, filtres, pagination Pagy |
| **Cartes recherchées (UserWantedCards)** | `user_wanted_cards_controller.rb`, `user_wanted_card.rb` | Complet - Support multi-langues |
| **Matching intelligent** | `matching_job.rb`, `match.rb` | Complet - Async via Sidekiq |
| **Système de trading** | `trades_controller.rb`, `trade.rb` | Complet - Workflow pending→done |
| **Messagerie temps réel** | `messages_controller.rb`, `chatroom.rb` | Complet - Action Cable, attachments, reactions |
| **Notifications** | `notifications_controller.rb`, `notification.rb` | Complet - Temps réel, scopes |
| **Profils utilisateurs** | `users_controller.rb`, `user.rb` | Complet - Géolocalisation, stats, ratings |
| **Authentification** | Devise | Standard et fonctionnel |
| **Système de ratings** | `rating.rb`, `ratings_controller.rb` | Complet - Notes 1-5, validations |
| **Emails transactionnels** | `trade_mailer.rb` | Complet - new/modified/accepted/completed |
| **Tests modèles** | 11/17 modèles testés (65%) | Bien structurés, FactoryBot |

## Section 2 : À finir (Travail en cours ou incomplet)

| Élément | Fichier | Problème | Priorité |
|---------|---------|----------|----------|
| **Tests manquants** | `rating.rb`, `message_reaction.rb` | Modèles récents sans specs | Moyenne |
| **Vue suggestions incomplète** | `_suggestions.html.erb` | Commentaire "Autres détails ici" | Basse |
| **Service recherche basique** | `cards/search_service.rb` | Recherche anglais uniquement, pas de filtres avancés | Basse |
| **Stimulus controllers non utilisés** | `filter_form_controller.js`, `view_toggle_controller.js` | Ajoutés mais pas encore branchés aux vues | Basse |

## Section 3 : Cassé ou douteux

| Problème | Fichier | Ligne(s) | Sévérité |
|----------|---------|----------|----------|
| **Concern cassé** | `trade_status_checker.rb` | ~5 | CRITIQUE - Appelle `active_trade_count` qui n'existe pas |
| **Code dupliqué matching** | `user_card.rb` vs `matching_job.rb` | 90-134 vs 25-63 | Moyenne - Même logique en double (intentionnel pour sync/async) |
| **Confusion ID Scryfall** | `user_card_form.rb`, `user_wanted_card_form.rb` | 100, 91 | Moyenne - `scryfall_id` est en fait `oracle_id` |
| **Mailer orphelin** | `sponsor_mailer.rb` | 1-8 | Mineure - Pas de template, code mort |
| **Contrôleur surdimensionné** | `trades_controller.rb` | 425 lignes | Moyenne - SRP violé, 26 méthodes |

---

## Contexte git

**Branche actuelle** : master

**Derniers commits** :
- `ea934e8` - add stimulus controllers for filter and view toggle
- `ff0d504` - add ratings, async matching, email notifications, pagination
- `c74807c` - trade acceptance improved
- `7c3ef25` - notification counter fixed

**État actuel** : Working tree clean

**Travail récent** :
- Janvier : Intégration Scryfall API
- Mars : Features trading + notifications
- Avril : Deployment production
- Mai : Ratings, Sidekiq, Pagy pagination, emails transactionnels

**12 branches locales** à nettoyer (create_match_jobs, last_things_before_mvp, etc.)
