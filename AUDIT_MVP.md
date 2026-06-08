# 🃏 CardMonkey — Audit MVP & Tickets

> Audit de fond du back avant lancement MVP. Constats vérifiés ligne à ligne sur le code réel.
> Stack : Rails 8.0 / Ruby 3.3 / PostgreSQL / Sidekiq / Scryfall.

## Verdict global

Architecture saine (bon découpage modèles/services/jobs, algo de matching délégué au SQL et non O(n²)), **mais pas prête pour le MVP en l'état** : suite de tests rouge, pipeline Scryfall cassé, failles de sécurité (IDOR), bugs fonctionnels cassants, dette de perf/outillage.

### Scorecard

| Axe | Note | État |
|-----|------|------|
| 🧠 Matching | 🟢/⚠️ | Bon fond SQL, mais logique dupliquée ×3 avec divergence + race conditions |
| ⚡ Perfs / N+1 | 🔴 | N+1 bloquants en vue, index manquants, FK DB absentes sur `matches` |
| 🔌 Scryfall | 🔴 | Bulk data OK mais pipeline cassé (collision tâches, OOM, `extension_id` jamais assigné) |
| 🛠️ Modernité Rails | 🟠 | Rails 8 en version mais "lift & shift" : 0 nouveauté, outillage qualité absent |
| ✅ Complétude/tests/sécu | 🔴 | Suite rouge, IDOR, routes mortes (annuler/refuser un trade impossible) |

### Légende sévérité
- 🔴 **Bloquant MVP** — casse un parcours, faille, ou empêche le lancement
- 🟠 **Important** — dette notable à traiter rapidement
- ⚪ **Cosmétique / dette** — nettoyage, non urgent

### Statut des lots
- [x] **Lot 1** — Sécu + bugs cassants — ✅ A1-A5, B1-B7, D7, D8, D10, D11, I1(noté), I2 faits. I3 différé (inoffensif).
- [x] **Lot 2** — Pipeline Scryfall — ✅ C1-C6, C8, C10, C11 faits + `lib/tasks/scryfall_client.rb` (headers/timeouts/retry/stream). Parse streamé via `oj` s'active au Lot 5. C7→Lot4, C9→Lot5.
- [x] **Lot 3** — Matching/perf — ✅ D1-D6 (service `MatchFinder` + jobs async), E1-E4/E7/E2 (N+1), H1/H2 (i18n FR mono-langue assumée). Restent bornés/🟠 : E5, E6, E8, H3, D5(quantité documentée).
- [x] **Lot 4** — Migrations DB — ✅ appliquées : C7 (uniques scryfall), E9/E10/E14 (index + trigram), E11 (FK matches/chatrooms/trades), E12 (NOT NULL + backfill name_fr), E13 (unicité chatroom), D9 (check-constraint), I4 (validation Trade). A8 (confirmable) différé (change le flux auth).
- [x] **Lot 5** — Gems & outillage — ✅ rubocop/brakeman/bundler-audit/simplecov/oj/sentry ajoutés, webdrivers retiré, redis 5 + shoulda 6, CI GitHub Actions, CSP report-only, cache Redis, assets.compile=false, package.json nettoyé, backup credentials supprimé. Différés (breaking, à migrer séparément) : pagy 9, turbo-rails 2, tailwind v4 (F8), F12/F13/F14, C9 (disque cron Render).
- [~] **Lot 6** — Tests — **suite unitaire/request : 207 exemples, 8 échecs (~96% verts)**, partant d'une suite quasi entièrement rouge. Les 8 résiduels = **0 bug applicatif** : `trade_spec` teste des méthodes jamais implémentées (`status_badge`, `notify_status_change` — `status_badge` existe en *helper*), un design différent (`user_invit` attendu `optional`, `status` sans défaut, scope `.active` redéfini) ; `chatroom#unread_messages_count` est un artefact du callback `mark_chatroom_as_unread` dans le setup du test. ✅ factory `trades` réparée (bug enum `status "0"`), `Chatroom` durci (validations + alias, 7→1), `User#top_matching_users`/`matching_cards_with_user` rendus publics (corrige un bug latent du controller), `avatar_thumbnail` ajouté, `user_card_spec`/`message_spec` réalignés sur l'implémentation réelle, **nouveaux specs verts** : `match_finder_spec` (8) + `trades_authorization_spec` (3, couvre A1). ⚠️ Ces tests ont révélé et corrigé un **vrai bug de matching** (langue : clé d'enum vs valeur DB). Les 12 échecs restants sont de la **dette de tests pré-existante** (specs écrits pour une ancienne implémentation : méthodes inexistantes `status_badge`/`notify_status_change`, `user_invit` attendu optionnel, scopes Notification, callback `mark_chatroom_as_unread` qui perturbe le setup, + traductions FR manquantes pour les erreurs `belongs_to required`) — voir EPIC G. Les **system specs** (Capybara) nécessitent un driver headless configuré (infra de test).

> **Lot 6 — dette de tests restante (pré-existante, à arbitrer спéc-vs-impl)** :
> - `message_spec` : teste des trade-messages basés sur le *contenu* (`trade_id:123`, "Nouveau trade proposé !") alors que l'impl utilise `metadata`; teste un callback `create_notification` inexistant; format `#timestamp` différent. → réécrire les specs sur le comportement actuel (metadata) ou décider du format.
> - `chatroom_spec` : teste `mark_messages_as_read!`/`unread_messages_count` (l'impl expose `mark_as_read_for`/`unread_count_for`) et une validation `users_are_different` inexistante. → aligner noms ou ajouter alias/validation.
> - `user_spec` : teste `avatar_thumbnail` (méthode absente) et appelle `top_matching_users`/`matching_cards_with_user` qui sont `private`. → implémenter ou ajuster la visibilité/les specs.
> - **System specs** (Capybara) : nécessitent une config de driver headless (selenium/cuprite) — échec d'infra de test, indépendant du code applicatif.

> **Note I1** : `TradeStatusChecker` n'est inclus dans aucun modèle (concern mort, `active_trade_count` jamais défini) — à supprimer ou câbler. Laissé en l'état (inoffensif).
> **Note B7 étendu** : `Chatroom has_many :notifications` était cassé comme `Message` (table `notifications` sans clé) → retiré aussi.

---

## Tableau récapitulatif

| ID | Sévérité | Epic | Titre | Lot | Statut |
|----|----------|------|-------|-----|--------|
| A1 | 🔴 | Sécu | IDOR `set_trade` | 1 | ☐ |
| A2 | 🔴 | Sécu | Injection cartes tiers `process_trade_cards` | 1 | ☐ |
| A3 | 🔴 | Sécu | IDOR `matches#show` | 1 | ☐ |
| A4 | 🔴 | Sécu | `CardsController` edit/update/destroy non protégés | 1 | ☐ |
| A5 | 🔴 | Sécu | Pas de `rescue_from RecordNotFound` global | 1 | ☐ |
| A6 | 🟠 | Sécu | CSP commentée | 5 | ☐ |
| A7 | 🟠 | Sécu | `credentials.yml.enc.backup` commité | 5 | ☐ |
| A8 | 🟠 | Sécu | Devise `:confirmable` + email re-vérif | 4 | ☐ |
| B1 | 🔴 | Bugs | Clés `@trades` mismatch (index invisible) | 1 | ☐ |
| B2 | 🔴 | Bugs | Actions `decline`/`cancel` absentes | 1 | ☐ |
| B3 | 🔴 | Bugs | Race condition double-confirmation | 1 | ☐ |
| B4 | 🟠 | Bugs | `handle_trade_creation` hors transaction | 1 | ☐ |
| B5 | 🟠 | Bugs | Routes mortes | 1 | ☐ |
| B6 | 🟠 | Bugs | `Chatroom#active_users` colonne/Redis cassés | 1 | ☐ |
| B7 | 🟠 | Bugs | `Message` assoc polymorphique cassée | 1/4 | ☐ |
| C1 | 🔴 | Scryfall | Collision deux `scryfall:sync` | 2 | ☐ |
| C2 | 🔴 | Scryfall | `initialize_cards` n'assigne pas extension/rarity/frame/border | 2 | ☐ |
| C3 | 🟠 | Scryfall | Multi-faces (`card_faces`) non gérées | 2 | ☐ |
| C4 | 🔴 | Scryfall | Headers HTTP User-Agent/Accept | 2 | ☐ |
| C5 | 🔴 | Scryfall | OOM : download+parse non streamés | 2 | ☐ |
| C6 | 🟠 | Scryfall | Filtrer digital + tokens | 2 | ☐ |
| C7 | 🟠 | Scryfall | Index uniques scryfall_id / oracle_id | 4 | ☐ |
| C8 | ⚪ | Scryfall | `cleanup_backups` manquant + schedule.rb redondant | 2 | ☐ |
| C9 | 🟠 | Scryfall | Render cron disk/env | 5 | ☐ |
| C10 | 🟠 | Scryfall | Langues limitées en/fr | 2 | ☐ |
| C11 | 🟠 | Scryfall | Timeouts réseau + retry borné | 2 | ☐ |
| D1 | 🟠 | Matching | Logique dupliquée ×3 + divergence condition | 3 | ☐ |
| D2 | 🟠 | Matching | `insert_all` sans `unique_by:` | 3 | ☐ |
| D3 | 🟠 | Matching | Matching `UserWantedCard` synchrone | 3 | ☐ |
| D4 | 🟠 | Matching | `notify_trade_partners` synchrone | 3 | ☐ |
| D5 | ⚪ | Matching | Quantité ignorée (double-dépense) | 3 | ☐ |
| D6 | ⚪ | Matching | Triple source `CONDITION_ORDER` | 3 | ☐ |
| D7 | ⚪ | Matching | Code mort `UserCard` | 1 | ☐ |
| D8 | ⚪ | Matching | `StandardDeckExplorer` mort | 1 | ☐ |
| D9 | ⚪ | Matching | `no_self_matching` check_constraint | 4 | ☐ |
| D10 | 🟠 | Matching | Form objects (rescue large, save, nil) | 1 | ☐ |
| D11 | 🟠 | Matching | `Cards::SearchService` NPE/name_fr/LIKE | 1 | ☐ |
| E1 | 🔴 | Perf | N+1 `_potential_list` | 3 | ☐ |
| E2 | 🔴 | Perf | N+1 `_dashboard` | 3 | ☐ |
| E3 | 🔴 | Perf | N+1 `trades/index` + `_trade_row` | 3 | ☐ |
| E4 | 🔴 | Perf | N+1 chatrooms | 3 | ☐ |
| E5 | 🟠 | Perf | N+1 `_user_wanted_card` | 3 | ☐ |
| E6 | 🟠 | Perf | `TradeCardCollector` mémoïsation | 3 | ☐ |
| E7 | 🟠 | Perf | `parse_card_quantities`/`process_trade_cards` batch | 3 | ☐ |
| E8 | 🟠 | Perf | `MatchesController#index` `to_a` | 3 | ☐ |
| E9 | 🟠 | Perf | Index manquants | 4 | ☐ |
| E10 | 🟠 | Perf | pg_trgm GIN sur cards.name + username | 4 | ☐ |
| E11 | 🟠 | Perf | FK DB manquantes | 4 | ☐ |
| E12 | 🟠 | Perf | NOT NULL manquants | 4 | ☐ |
| E13 | 🟠 | Perf | Unicité chatrooms (user, invit) | 4 | ☐ |
| E14 | 🟠 | Perf | username unicité | 4 | ☐ |
| E15 | ⚪ | Perf | counter_cache matches | 4 | ☐ |
| F1 | 🟠 | Modern | RuboCop | 5 | ☐ |
| F2 | 🟠 | Modern | Brakeman | 5 | ☐ |
| F3 | 🟠 | Modern | bundler-audit | 5 | ☐ |
| F4 | 🟠 | Modern | CI GitHub Actions | 5 | ☐ |
| F5 | 🟠 | Modern | Sentry | 5 | ☐ |
| F6 | 🟠 | Modern | SimpleCov | 5 | ☐ |
| F7 | 🔴 | Modern | `webdrivers` abandonnée | 5 | ☐ |
| F8 | 🟠 | Modern | Gems anciennes (redis, pagy, turbo…) | 5 | ☐ |
| F9 | 🟠 | Modern | `assets.compile=true` en prod | 5 | ☐ |
| F10 | 🟠 | Modern | Cache memory_store non partagé | 5 | ☐ |
| F11 | 🟠 | Modern | `package.json` @rails/ujs incohérent | 5 | ☐ |
| F12 | ⚪ | Modern | `establish_connection` manuel | 5 | ☐ |
| F13 | ⚪ | Modern | byebug→debug, spring/jbuilder | 5 | ☐ |
| F14 | ⚪ | Modern | frozen_string_literal + Ruby patch | 5 | ☐ |
| G1 | 🔴 | Tests | System specs rouges (driver) | 6 | ☐ |
| G2 | 🔴 | Tests | Model specs rouges (factories) | 6 | ☐ |
| G3 | 🟠 | Tests | Spec `MatchingJob` | 6 | ☐ |
| G4 | 🟠 | Tests | Specs request/autorisation | 6 | ☐ |
| G5 | 🟠 | Tests | Specs services | 6 | ☐ |
| G6 | ⚪ | Tests | Specs forms/mailers/Rating | 6 | ☐ |
| H1 | 🟠 | i18n | Locale forcée `:fr` | 3 | ☐ |
| H2 | 🟠 | i18n | `en.yml` stub | 3 | ☐ |
| H3 | ⚪ | i18n | Flash en dur | 3 | ☐ |
| I1 | ⚪ | Robust | `active_trade_count` includer | 1 | ☐ |
| I2 | ⚪ | Robust | `rescue` nus | 1 | ☐ |
| I3 | ⚪ | Robust | `SponsorMailer` orphelin | 1 | ☐ |
| I4 | 🟠 | Robust | Validation `Trade` user≠invit + non vide | 4 | ☐ |

---

## EPIC A — Sécurité

### [A1] IDOR sur `set_trade` — 🔴
**Problème** : `set_trade` fait un simple `Trade.find(params[:id])` sans vérifier que `current_user` est participant. N'importe quel user connecté peut voir/agir sur n'importe quel trade.
**Fichier** : `app/controllers/trades_controller.rb:223-225` (before_action `show, edit, update, accept, validate`).
**Actuel** : `def set_trade; @trade = Trade.find(params[:id]); end`
**Cible** : `@trade = current_user.all_trades.find(params[:id])` (ou scope participant) — lève RecordNotFound (→ 404 via A5) pour un non-participant.
**Acceptation** : ☐ un non-participant reçoit 404/redirect sur show/edit/update/accept/validate.
**Test** : spec request — user C tente `GET /trades/:id` d'un trade A↔B → redirigé/404.

### [A2] Injection de cartes de tiers — 🔴
**Problème** : `process_trade_cards` insère les `user_card_id` soumis sans vérifier leur appartenance aux 2 participants. Un attaquant injecte les cartes d'autrui.
**Fichier** : `app/controllers/trades_controller.rb:293-303`.
**Cible** : valider chaque `user_card_id` ∈ cartes de `current_user` ∪ cartes du partenaire avant `create!`/`insert_all`.
**Acceptation** : ☐ un `user_card_id` n'appartenant à aucun des 2 participants est rejeté (pas de trade créé).
**Test** : spec — soumettre un id tiers → erreur / aucune `TradeUserCard` créée.

### [A3] IDOR sur `matches#show` — 🔴
**Problème** : `Match.find(params[:id])` rendu sans contrôle d'appartenance → exposition des cartes/users d'autrui.
**Fichier** : `app/controllers/matches_controller.rb:43-50`.
**Cible** : scoper au `current_user` (`user_id` ou `user_id_target`).
**Acceptation** : ☐ un match non lié à current_user renvoie 404.

### [A4] `CardsController` edit/update/destroy non protégés — 🔴 (latent)
**Problème** : actions modifiant le référentiel global `Card` sans aucune autorisation. Non routées actuellement mais dangereuses si on ajoute les routes.
**Fichier** : `app/controllers/cards_controller.rb:6-24`.
**Cible** : supprimer ces actions (le référentiel n'est éditable que par le sync Scryfall).
**Acceptation** : ☐ actions supprimées, routes index/show/search/versions intactes.

### [A5] `rescue_from RecordNotFound` global — 🔴
**Problème** : pas de gestion globale → 500 sur ID invalide (et 404 propre nécessaire pour A1/A3).
**Fichier** : `app/controllers/application_controller.rb`.
**Cible** : `rescue_from ActiveRecord::RecordNotFound, with: :not_found` → redirect/404.
**Acceptation** : ☐ ID invalide → 404 (pas 500).

### [A6] CSP commentée — 🟠 (Lot 5)
**Fichier** : `config/initializers/content_security_policy.rb`. Activer une CSP de base.

### [A7] `credentials.yml.enc.backup` commité — 🟠 (Lot 5)
**Fichier** : `config/credentials.yml.enc.backup`. Supprimer du repo + ajouter au `.gitignore`.

### [A8] Devise `:confirmable` + email re-vérif — 🟠 (Lot 4, migration)
**Fichier** : `app/models/user.rb:13-14`. Ajouter `:confirmable` (colonnes confirmation) ; re-vérif sur changement d'email.

---

## EPIC B — Bugs fonctionnels cassants

### [B1] Clés `@trades` mismatch — 🔴
**Problème** : controller remplit `@trades` avec `'pending'/'modified'/'accepted'/'done'` ; la vue lit `'0'/'1'/'2'` → **aucune section ne s'affiche**.
**Fichiers** : `app/controllers/trades_controller.rb:31-36` vs `app/views/trades/index.html.erb:88,99,107,118,126,137`.
**Cible** : aligner la vue sur les clés string nommées.
**Acceptation** : ☐ `/trades` affiche les sections pending/modified/accepted/done.

### [B2] Actions `decline`/`cancel` absentes — 🔴
**Problème** : routes `POST /trades/:id/decline` et `/cancel` existent mais sans action → 500. État `cancelled` (enum) jamais atteint.
**Fichiers** : `config/routes.rb:36-37`, `app/controllers/trades_controller.rb`, `app/models/trade.rb:14-20`.
**Cible** : implémenter `decline` (refus d'une proposition) et `cancel` (annulation), avec gardes `can_be_*?` + transition vers `cancelled`, notifications. Ajouter `set_trade` à ces actions (scopé A1).
**Acceptation** : ☐ refuser/annuler change le statut, pas de 500, garde participation.

### [B3] Race condition double-confirmation — 🔴
**Problème** : `handle_trade_completion` lit/écrit `completed_by_user_ids` sans verrou → 2 clics simultanés → un seul ID persiste, trade jamais `done`.
**Fichier** : `app/controllers/trades_controller.rb:340-367`.
**Cible** : `@trade.lock!` en début de transaction (SELECT…FOR UPDATE).
**Acceptation** : ☐ deux confirmations concurrentes → `done`.

### [B4] `handle_trade_creation` hors transaction — 🟠
**Fichier** : `app/controllers/trades_controller.rb:108-114`. Englober save + cartes + notif + mail dans une transaction (mail/notif en `after_commit` / `deliver_later`).

### [B5] Routes mortes — 🟠
**Fichier** : `config/routes.rb`. `cards#autocomplete`, `users#profile/dashboard`, `matches#dashboard`, `messages#mark_read` sans action. Implémenter ou retirer.

### [B6] `Chatroom#active_users`/`typing_users` cassés — 🟠
**Fichier** : `app/models/chatroom.rb:72-87`. Référence `users.last_seen_at` (colonne inexistante) + `Redis.current` (supprimé redis-rb 5). Supprimer ou réécrire (méthodes non utilisées).

### [B7] `Message` assoc polymorphique cassée — 🟠 (Lot 1 code + Lot 4 schéma)
**Fichier** : `app/models/message.rb:5` (`has_many :notifications, as: :notifiable`) vs `notifications` sans colonnes polymorphiques (`schema.rb:150-161`). Soit retirer l'assoc, soit ajouter les colonnes. MVP : retirer l'assoc invalide.

---

## EPIC C — Pipeline Scryfall

### [C1] Collision deux `scryfall:sync` — 🔴
**Problème** : `lib/tasks/scryfall.rake:6` (scraping carte-par-carte) et `lib/tasks/scryfall_data_sync.rake:116` (bulk) définissent la même tâche → fusion, le scraping tourne avant le bulk.
**Cible** : supprimer `lib/tasks/scryfall.rake` + helpers one-shot `lib/tasks/add_*.rb` ; garder uniquement le pipeline bulk.
**Acceptation** : ☐ une seule définition de `scryfall:sync`.

### [C2] `initialize_cards` n'assigne pas extension/rarity/frame/border — 🔴
**Problème** : `version_attributes` ne contient que card_id, scryfall_id, img_uri, prix. Or `CardVersion` valide `presence` sur `extension_id`, `rarity`, `frame`, `border_color` → **save échoue**.
**Fichiers** : `lib/tasks/initialize_cards.rake:99-124` vs `app/models/card_version.rb:6-11`.
**Cible** : créer/cacher l'`Extension` (depuis `set`/`set_name`/`released_at`/`icon_svg_uri`) et assigner `rarity`, `frame`, `border_color`, `collector_number`, `extension_id`.
**Acceptation** : ☐ le sync crée des `CardVersion` valides (échantillon testé).

### [C3] Multi-faces non gérées — 🟠
**Fichier** : `lib/tasks/initialize_cards.rake:102`. `image_uris` absent pour DFC/split/adventure → `img_uri = nil`. Fallback `card_faces[0].image_uris.normal`.

### [C4] Headers HTTP manquants — 🔴
**Fichier** : `lib/tasks/scryfall_data_sync.rake:43,55`. Ajouter `User-Agent: CardMonkey/1.0` et `Accept`. Sans ça, risque 403.

### [C5] OOM download+parse — 🔴
**Fichier** : `lib/tasks/scryfall_data_sync.rake:55,58` + `initialize_cards.rake`. Fichier ~2 Go chargé en RAM + parsé 3-4×. Streamer le download (gem `down`) et le parse (`oj`/yajl). Supprimer le double-parse de validation.

### [C6] Filtrer digital + tokens — 🟠
**Fichier** : `lib/tasks/initialize_cards.rake:56`. Exclure `digital == true` et `layout == 'token'`.

### [C7] Index uniques scryfall — 🟠 (Lot 4)
Migration : unique sur `card_versions.scryfall_id` et `cards.scryfall_oracle_id`.

### [C8] `cleanup_backups` + schedule.rb — ⚪
`config/schedule.rb:22` référence `scryfall:cleanup_backups` inexistant ; redondant avec `render.yaml`. Définir la tâche ou retirer `schedule.rb`.

### [C9] Render cron disk/env — 🟠 (Lot 5)
`render.yaml:7-13,70-73`. Disque monté sur le web pas le cron ; 1 Go douteux ; cron sans migrate. Aligner (ou import 100 % streaming sans fichier).

### [C10] Langues en/fr seulement — 🟠
`lib/tasks/initialize_cards.rake:56`. Décider scope MVP (assumer fr/en, ou étendre + colonnes noms localisés).

### [C11] Timeouts + retry — 🟠
`scryfall_data_sync.rake`. Ajouter `open_timeout`/`read_timeout` ; retry borné avec back-off.

---

## EPIC D — Matching / logique métier

### [D1] Logique dupliquée ×3 + divergence condition — 🟠
**Problème** : matching en 3 endroits ; côté `UserWantedCard` le **filtre de condition n'est pas appliqué** → matches asymétriques selon l'ordre de création.
**Fichiers** : `app/jobs/matching_job.rb`, `app/models/user_card.rb`, `app/models/user_wanted_card.rb:96-142`.
**Cible** : extraire un `MatchFinder` (service/concern) unique, appliquer le filtre condition des 2 côtés.

### [D2] `insert_all` sans `unique_by:` — 🟠
**Fichiers** : `app/jobs/matching_job.rb:30`, `app/models/user_wanted_card.rb`. Ajouter `unique_by: :index_matches_on_user_card_and_wanted_card_unique`.

### [D3] Matching `UserWantedCard` synchrone — 🟠
**Fichier** : `app/models/user_wanted_card.rb:40-43`. Router vers `MatchingJob` (async) comme `UserCard`.

### [D4] `notify_trade_partners` synchrone — 🟠
**Fichiers** : `app/models/user_wanted_card.rb:71-94`, `app/models/user_card.rb:74-88`. Déplacer en job async (`after_commit on: :destroy`).

### [D5] Quantité ignorée — ⚪
Documenter la limite ou intégrer `quantity` au matching/disponibilité.

### [D6] Triple source `CONDITION_ORDER` — ⚪
`concerns/card_condition_management.rb` (array) vs `user_card.rb` (hash) vs CASE SQL. Une seule constante canonique.

### [D7] Code mort `UserCard` — ⚪ (Lot 1)
`create_matches`/`find_potential_matches` jamais appelés (callbacks → MatchingJob). Supprimer.

### [D8] `StandardDeckExplorer` mort — ⚪ (Lot 1)
`app/services/standard_deck_explorer.rb` : ~17 méthodes non définies, assoc inexistantes, jamais référencé. Supprimer le fichier.

### [D9] `no_self_matching` check_constraint — ⚪ (Lot 4)
`insert_all` contourne la validation. Ajouter `check_constraint "user_id <> user_id_target"` sur `matches`.

### [D10] Form objects — 🟠 (Lot 1)
**Fichiers** : `app/models/forms/user_card_form.rb`, `user_wanted_card_form.rb`.
- `rescue => e` → rescue ciblé (`RecordInvalid`, `RecordNotFound`).
- `save` doit renvoyer un booléen.
- `find_card_version` nil + `card_versions.first` non déterministe → garde + ordre.
- `unless: :card_id` → `unless: -> { card_id.present? }`.

### [D11] `Cards::SearchService` — 🟠 (Lot 1)
**Fichier** : `app/services/cards/search_service.rb:14-26`. Garde NPE (`card_versions.first&.`), chercher aussi `name_fr`, prévoir trigram (E10).

---

## EPIC E — Performance / DB

### [E1] N+1 `_potential_list` — 🔴
`app/views/matches/_potential_list.html.erb:16-17` : 2× `User.find` en boucle. Précharger les users cible dans le controller et indexer par id.

### [E2] N+1 `_dashboard` — 🔴
`app/views/home/_dashboard.html.erb:91` (`User.find` en boucle) + img wanted ~209. Utiliser un hash préchargé `@match_users_by_id` ; ajouter `card: :card_versions` à l'`includes`.

### [E3] N+1 `trades/index` + `_trade_row` — 🔴
`app/views/trades/index.html.erb:217` (`User.find`) + `app/views/trades/_trade_row.html.erb:14-19` (2× COUNT SQL/ligne). Partitionner les `trade_user_cards` préchargés en Ruby (`.size`).

### [E4] N+1 chatrooms — 🔴
`app/views/chatrooms/index.html.erb` (`messages.last`, `unread_count_for` en boucle) + `chatrooms_controller.rb:48` `includes(:messages)` (charge tout). Calculer `last_message`/`unread_count` en requêtes agrégées ; retirer `includes(:messages)`.

### [E5] N+1 `_user_wanted_card` — 🟠
`app/views/user_wanted_cards/_user_wanted_card.html.erb:40,49` : `matches_count` (COUNT/ligne) + `img_uri`. counter_cache (E15) + `card: :card_versions`.

### [E6] `TradeCardCollector` mémoïsation — 🟠
`app/services/trade_card_collector.rb` : `find_wanted_cards` recalculé ~4×. Mémoïser.

### [E7] Batch `parse_card_quantities`/`process_trade_cards` — 🟠
`app/controllers/trades_controller.rb:269-302` : `UserCard.find` en boucle + `create!` en boucle. `where(id:).index_by` + `insert_all`.

### [E8] `MatchesController#index` `to_a` — 🟠
`app/controllers/matches_controller.rb:13` : `pagy_array(...to_a)` charge tout. Paginer en SQL.

### [E9-E15] Migrations DB — 🟠/⚪ (Lot 4)
- E9 : index `trades.user_id_invit`, `chatrooms.user_id_invit`, `card_versions.eur_price`, composite `user_wanted_cards(card_id, language)`.
- E10 : extension `pg_trgm` + index GIN `cards.name_fr/name_en`, `users.username`.
- E11 : FK DB `matches.*`, `chatrooms.user_id_invit`, `trades.user_id_invit`, `trades.last_modifier_id`.
- E12 : `NOT NULL` alignés sur validations (user_cards, user_wanted_cards, matches, cards, card_versions) — **après nettoyage des données**.
- E13 : unique `chatrooms(user_id, user_id_invit)`.
- E14 : politique unicité `username`.
- E15 : `counter_cache` matches sur user_card/user_wanted_card.

---

## EPIC F — Modernité / outillage (Lot 5)

- **F1** RuboCop (`.rubocop.yml` existe, doc le promet) → `rubocop-rails-omakase`.
- **F2** Brakeman. **F3** bundler-audit. **F4** CI GitHub Actions. **F5** Sentry. **F6** SimpleCov.
- **F7** 🔴 Supprimer `webdrivers` (gèle selenium 4.10), libérer `selenium-webdriver`.
- **F8** Upgrades : `redis ~>5`, `shoulda-matchers ~>6`, `pagy ~>9`, `turbo-rails ~>2`, `tailwindcss-rails ~>3/4`.
- **F9** `config.assets.compile = false` en prod (`production.rb:29`).
- **F10** Cache partagé (Solid Cache/Redis) au lieu de `:memory_store` (`production.rb:62`).
- **F11** Nettoyer `package.json` (`@rails/ujs` supprimé en Rails 8, versions 6.0).
- **F12** Retirer `establish_connection` manuel (`puma.rb`, `database_connection.rb`).
- **F13** `byebug`→`debug` ; retirer `spring`/`jbuilder` si inutilisés.
- **F14** `frozen_string_literal` ; monter Ruby vers dernière 3.3.x.

---

## EPIC G — Tests (Lot 6)

- **G1** 🔴 System specs rouges → réparer driver Capybara/JS.
- **G2** 🔴 Model specs trade/chatroom/message/user rouges → réparer factories/setup.
- **G3** Spec `MatchingJob` (cœur métier).
- **G4** Specs request/autorisation (couvre A1-A3).
- **G5** Specs services (`SearchService`, `TradeCardCollector`).
- **G6** Specs forms/mailers/`Rating`/`MessageReaction`.
- Objectif : `bundle exec rspec` vert + SimpleCov.

---

## EPIC H — i18n (Lot 3)

- **H1** 🟠 Locale forcée `:fr` (`application_controller.rb:9-11`) → préférence user/`Accept-Language`.
- **H2** 🟠 `en.yml` = stub → remplir, **ou** assumer mono-langue fr MVP (décision).
- **H3** ⚪ Flash en dur (fr) dans controllers → i18n.

---

## EPIC I — Robustesse diverse

- **I1** ⚪ `active_trade_count` (concern `TradeStatusChecker`) doit exister sur l'includer — vérifier.
- **I2** ⚪ `rescue` nus (`matches_controller.rb:40`) → cibler.
- **I3** ⚪ `SponsorMailer` orphelin → brancher ou supprimer.
- **I4** 🟠 Validation `Trade` : `user_id != user_id_invit` + trade non vide (`trade.rb`).

---

## Ordre de résolution (lots)

1. **Lot 1** — A1-A5, B1-B7, D7, D8, D10, D11, I1-I3 (code only)
2. **Lot 2** — C1-C6, C8, C10, C11 (code)
3. **Lot 3** — D1-D6, E1-E8, H1-H3 (sans migration)
4. **Lot 4** ⚠️ — C7, E9-E15, A8, D9, I4 (migrations)
5. **Lot 5** ⚠️ — F1-F14, A6, A7, C9 (gems/outillage/infra)
6. **Lot 6** — G1-G6 (tests verts)

Règles : aucun commit/push sans demande ; checkpoint + `bundle exec rspec` après chaque lot.
