# 🎴 CardMonkey — Audit UX MVP (parcours nouvel utilisateur)

> Audit du point de vue d'un **nouvel utilisateur** qui arrive et veut tester avec sa **collection de ~200 rares**.
> Objectif : app efficace, étapes claires, UX fluide, sans info inutile.

## Légende
🔴 Bloquant MVP · 🟠 Important · ⚪ Confort

---

## Synthèse des frictions (du plus bloquant au moins)

| # | Friction | Sévérité | Statut |
|---|----------|----------|--------|
| 1 | Aucun import en masse (200 cartes une par une) | 🔴 | ✅ Phase 1 |
| 2 | Géoloc absente à l'inscription → matching inopérant | 🔴 | ✅ Phase 2 |
| 3 | Onboarding inexistant (pas d'étapes guidées, pas d'aide) | 🟠 | ✅ Phase 2 |
| 4 | Écran matches ambigu (qui a / qui veut ?) + bruit technique | 🟠 | ✅ Phase 3 |
| 5 | Cycle de vie des trades : « ma prochaine action ? » floue | 🟠 | ✅ Phase 4 |

> **Phases 3 & 4 implémentées.** Matches reformulés « vous donnez / vous recevez » + distance + réputation. Trades : bannière « prochaine action » sur la fiche et indice sur les lignes, bouton Refuser pour l'invité, lien chat ↔ échange.
>
> **Conforts trades ajoutés.** Notifications « action requise » distinctes (type `trade_action` : accent + badge + CTA « Voir et agir ») des notifications informatives ; récap avant envoi d'une proposition (modal de confirmation) ; garde anti-oscillation (celui qui vient de modifier doit attendre la réponse de l'autre).

---

## 1. Import de collection (🔴) — le bloqueur du scénario « 200 rares »

**Constat.** L'ajout se faisait **carte par carte** (autocomplete → édition → état → langue → foil → quantité → submit → retour liste). Pour 200 cartes : ~2000-3000 clics, 2-4 h → abandon quasi certain.

**Analyse scan vs decklist vs CSV.** Les apps de scan existent et sont matures (ManaBox, Dragon Shield, Delver Lens, CardCastle) — reconstruire un scanner = projet ML/mobile hors MVP. Toutes **exportent en CSV** et ManaBox embarque souvent le `Scryfall ID`. → **Interopérer via CSV** + offrir le **collage de decklist**, plutôt que réinventer le scan.

**Implémenté (Phase 1).**
- Service `CollectionImport` (`app/services/collection_import/`) : `Importer` (résolution par `scryfall_id` exact, sinon nom fr/en + édition ; upsert quantité), `CsvParser` (en-têtes ManaBox/Moxfield/Deckbox par nom, ordre libre), `DecklistParser` (`4 Sol Ring (CMR) 472`, `*F*` = foil), `Mappings` (condition/langue/foil des formats standards → enums internes).
- `CollectionImportJob` : import asynchrone au-delà de 50 lignes + notification de fin.
- UI `user_cards#import` : onglets « Coller une liste » / « CSV » + valeurs par défaut (état/langue/foil) + page de résultat (ajoutées / quantité MAJ / ignorées avec raison).
- CTA « Importer en masse » sur la collection et le dashboard.
- Quick-win : bouton « Enregistrer et ajouter une autre » sur le formulaire unitaire.

**Effet attendu.** 200 cartes scannées (ManaBox) → export CSV → import en quelques secondes (résolution exacte par Scryfall ID).

---

## 2. Onboarding & géolocalisation (🔴/🟠) — Phase 2 (à venir)

**Constats.**
- L'**adresse n'est pas demandée à l'inscription** (3 champs : email + mot de passe ×2) et est enterrée à 2-3 clics dans le profil → coordonnées vides → matching par distance inopérant → « l'app est vide ».
- **Pas d'onboarding** : après inscription → dashboard direct. Bons empty states mais **sans ordre** d'étapes.
- **Aucune page d'aide / FAQ** (seulement Privacy Policy + Contact).

**Reco.** Demander l'adresse à l'inscription (ou guard « profil incomplet »), checklist d'accueil ordonnée (adresse → cartes → wishlist → opportunités) + barre de progression, widget « complétez votre profil », page FAQ « Comment ça marche » (échanges, conditions MTG, géoloc, import).

---

## 3. Lisibilité des matches (🟠) — Phase 3 (à venir)

**Constats.** Colonnes « Votre carte / Leur carte » **ambiguës** (on ne sait pas qui donne/reçoit), info technique en trop (frame, langue, prix par carte), mais **distance et réputation absentes** de l'écran de match (la distance n'apparaît que dans `_potential_list`).

**Reco.** Formuler explicitement « je donne X / je reçois Y », afficher distance + réputation (`average_rating`/`rating_count`), retirer le bruit technique de la vue principale.

---

## 4. Cycle de vie des trades (🟠) — Phase 4 (à venir)

**Constats.** La proposition (`new_proposition`) est plutôt bien faite (sélection +/- bicolonne, balance €). Mais ensuite : pas de récap avant envoi, **« quelle est ma prochaine action ? » peu évident**, oscillation possible modifier↔valider, confirmation physique peu guidée, **notifications qui ne distinguent pas action requise vs info**, lien trade↔chat faible.

**Reco.** Un seul CTA « prochaine action » contextuel par statut, notifications actionnables (action requise vs info + lien direct), notif manquante « le partenaire attend ta confirmation », aperçu du trade depuis le chat, récap avant envoi, garde anti-oscillation.

---

## Sources (analyse import)
- ManaBox — import/export : https://www.manabox.app/guides/collection/import-export/
- Moxfield — format CSV : https://moxfield.com/help/importing-collection
- Draftsim — 11 meilleurs trackers de collection : https://draftsim.com/mtg-collection-tracker/
- Dragon Shield MTG Scanner : https://apps.apple.com/us/app/mtg-scanner-dragon-shield/id1460657155
