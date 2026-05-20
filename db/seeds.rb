
# Create users
puts "Creating users..."
users = {
  alice: User.create!(
    email: 'alice@example.com',
    password: 'password',
    username: 'Alice',
    address: 'Paris',
    area: 20,
    preference: :value_based
  ),
  bob: User.create!(
    email: 'bob@example.com',
    password: 'password',
    username: 'Bob',
    address: 'Lyon',
    area: 30,
    preference: :quantity_based
  ),
  charlie: User.create!(
    email: 'charlie@example.com',
    password: 'password',
    username: 'Charlie',
    address: 'Marseille',
    area: 25,
    preference: :value_based
  ),
  david: User.create!(
    email: 'david@example.com',
    password: 'password',
    username: 'David',
    address: 'Bordeaux',
    area: 15,
    preference: :quantity_based
  ),
  emma: User.create!(
    email: 'emma@example.com',
    password: 'password',
    username: 'Emma',
    address: 'Toulouse',
    area: 20,
    preference: :value_based
  ),
  frank: User.create!(
    email: 'frank@example.com',
    password: 'password',
    username: 'Frank',
    address: 'Lille',
    area: 25,
    preference: :quantity_based
  ),
  grace: User.create!(
    email: 'grace@example.com',
    password: 'password',
    username: 'Grace',
    address: 'Nantes',
    area: 30,
    preference: :value_based
  ),
  henry: User.create!(
    email: 'henry@example.com',
    password: 'password',
    username: 'Henry',
    address: 'Strasbourg',
    area: 20,
    preference: :quantity_based
  )
}

# Create extensions
puts "Creating extensions..."
extensions = {
  dominaria: Extension.create!(
    code: 'DOM',
    name: 'Dominaria',
    release_date: '2018-04-27',
    icon_uri: 'https://example.com/dom.png'
  ),
  ravnica: Extension.create!(
    code: 'RNA',
    name: 'Ravnica Allegiance',
    release_date: '2019-01-25',
    icon_uri: 'https://example.com/rna.png'
  ),
  theros: Extension.create!(
    code: 'THB',
    name: 'Theros Beyond Death',
    release_date: '2020-01-24',
    icon_uri: 'https://example.com/thb.png'
  ),
  ikoria: Extension.create!(
    code: 'IKO',
    name: 'Ikoria: Lair of Behemoths',
    release_date: '2020-04-24',
    icon_uri: 'https://example.com/iko.png'
  )
}

# Create cards
puts "Creating cards..."
cards = {
  teferi: Card.create!(
    scryfall_oracle_id: 'teferi123',
    name_fr: 'Téfeiri, Héros de la Dominaria',
    name_en: 'Teferi, Hero of Dominaria'
  ),
  kaya: Card.create!(
    scryfall_oracle_id: 'kaya123',
    name_fr: 'Kaya, Usurpatrice d\'Orzhov',
    name_en: 'Kaya, Orzhov Usurper'
  ),
  hydroid: Card.create!(
    scryfall_oracle_id: 'hydroid123',
    name_fr: 'Krasis Hydroïde',
    name_en: 'Hydroid Krasis'
  ),
  shock: Card.create!(
    scryfall_oracle_id: 'shock123',
    name_fr: 'Choc',
    name_en: 'Shock'
  ),
  ashiok: Card.create!(
    scryfall_oracle_id: 'ashiok123',
    name_fr: 'Ashiok, Faiseur de Cauchemars',
    name_en: 'Ashiok, Nightmare Muse'
  ),
  elspeth: Card.create!(
    scryfall_oracle_id: 'elspeth123',
    name_fr: 'Elspeth, Mort Vaincue',
    name_en: 'Elspeth, Sun\'s Nemesis'
  ),
  lukka: Card.create!(
    scryfall_oracle_id: 'lukka123',
    name_fr: 'Lukka, Coppercoat Outcast',
    name_en: 'Lukka, Coppercoat Outcast'
  ),
  vivien: Card.create!(
    scryfall_oracle_id: 'vivien123',
    name_fr: 'Vivien, Championne des Bêtes',
    name_en: 'Vivien, Champion of the Wilds'
  )
}

# Create card versions
puts "Creating card versions..."
card_versions = {
  teferi_dom: CardVersion.create!(
    card: cards[:teferi],
    extension: extensions[:dominaria],
    scryfall_id: 'teferi_dom_123',
    img_uri: 'https://example.com/teferi.jpg',
    eur_price: 30.00,
    rarity: 'mythic'
  ),
  kaya_rna: CardVersion.create!(
    card: cards[:kaya],
    extension: extensions[:ravnica],
    scryfall_id: 'kaya_rna_123',
    img_uri: 'https://example.com/kaya.jpg',
    eur_price: 15.00,
    rarity: 'mythic'
  ),
  hydroid_rna: CardVersion.create!(
    card: cards[:hydroid],
    extension: extensions[:ravnica],
    scryfall_id: 'hydroid_rna_123',
    img_uri: 'https://example.com/hydroid.jpg',
    eur_price: 20.00,
    rarity: 'mythic'
  ),
  shock_rna: CardVersion.create!(
    card: cards[:shock],
    extension: extensions[:ravnica],
    scryfall_id: 'shock_rna_123',
    img_uri: 'https://example.com/shock.jpg',
    eur_price: 0.50,
    rarity: 'common'
  ),
  ashiok_thb: CardVersion.create!(
    card: cards[:ashiok],
    extension: extensions[:theros],
    scryfall_id: 'ashiok_thb_123',
    img_uri: 'https://example.com/ashiok.jpg',
    eur_price: 25.00,
    rarity: 'mythic'
  ),
  elspeth_thb: CardVersion.create!(
    card: cards[:elspeth],
    extension: extensions[:theros],
    scryfall_id: 'elspeth_thb_123',
    img_uri: 'https://example.com/elspeth.jpg',
    eur_price: 18.00,
    rarity: 'mythic'
  ),
  lukka_iko: CardVersion.create!(
    card: cards[:lukka],
    extension: extensions[:ikoria],
    scryfall_id: 'lukka_iko_123',
    img_uri: 'https://example.com/lukka.jpg',
    eur_price: 22.00,
    rarity: 'mythic'
  ),
  vivien_iko: CardVersion.create!(
    card: cards[:vivien],
    extension: extensions[:ikoria],
    scryfall_id: 'vivien_iko_123',
    img_uri: 'https://example.com/vivien.jpg',
    eur_price: 16.00,
    rarity: 'mythic'
  )
}

# Create user cards (collection)
puts "Creating user cards..."
[
  # Alice's collection
  { user: users[:alice], card_version: card_versions[:teferi_dom], condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:alice], card_version: card_versions[:ashiok_thb], condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:alice], card_version: card_versions[:shock_rna], condition: 'EX', foil: false, language: 'FR', quantity: 4 },
  
  # Bob's collection
  { user: users[:bob], card_version: card_versions[:kaya_rna], condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:bob], card_version: card_versions[:elspeth_thb], condition: 'NM', foil: false, language: 'FR', quantity: 2 },
  { user: users[:bob], card_version: card_versions[:vivien_iko], condition: 'NM', foil: false, language: 'EN', quantity: 1 },
  
  # Charlie's collection
  { user: users[:charlie], card_version: card_versions[:hydroid_rna], condition: 'NM', foil: false, language: 'FR', quantity: 2 },
  { user: users[:charlie], card_version: card_versions[:lukka_iko], condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:charlie], card_version: card_versions[:teferi_dom], condition: 'GD', foil: false, language: 'FR', quantity: 1 },
  
  # David's collection
  { user: users[:david], card_version: card_versions[:shock_rna], condition: 'NM', foil: false, language: 'FR', quantity: 4 },
  { user: users[:david], card_version: card_versions[:ashiok_thb], condition: 'EX', foil: false, language: 'EN', quantity: 1 },
  { user: users[:david], card_version: card_versions[:vivien_iko], condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  
  # Emma's collection
  { user: users[:emma], card_version: card_versions[:elspeth_thb], condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:emma], card_version: card_versions[:kaya_rna], condition: 'EX', foil: false, language: 'FR', quantity: 2 },
  { user: users[:emma], card_version: card_versions[:hydroid_rna], condition: 'NM', foil: false, language: 'EN', quantity: 1 },
  
  # Frank's collection
  { user: users[:frank], card_version: card_versions[:lukka_iko], condition: 'NM', foil: false, language: 'FR', quantity: 2 },
  { user: users[:frank], card_version: card_versions[:teferi_dom], condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:frank], card_version: card_versions[:shock_rna], condition: 'NM', foil: false, language: 'FR', quantity: 3 },
  
  # Grace's collection
  { user: users[:grace], card_version: card_versions[:vivien_iko], condition: 'NM', foil: false, language: 'FR', quantity: 2 },
  { user: users[:grace], card_version: card_versions[:ashiok_thb], condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:grace], card_version: card_versions[:kaya_rna], condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  
  # Henry's collection
  { user: users[:henry], card_version: card_versions[:elspeth_thb], condition: 'EX', foil: false, language: 'FR', quantity: 1 },
  { user: users[:henry], card_version: card_versions[:hydroid_rna], condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:henry], card_version: card_versions[:lukka_iko], condition: 'NM', foil: false, language: 'FR', quantity: 2 }
].each do |card_data|
  UserCard.create!(card_data)
end

# Create wanted cards
puts "Creating wanted cards..."
[
  # Alice wants
  { user: users[:alice], card: cards[:kaya], card_version: card_versions[:kaya_rna], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:alice], card: cards[:hydroid], card_version: card_versions[:hydroid_rna], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:alice], card: cards[:lukka], card_version: card_versions[:lukka_iko], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  
  # Bob wants
  { user: users[:bob], card: cards[:teferi], card_version: card_versions[:teferi_dom], min_condition: 'GD', foil: false, language: 'FR', quantity: 1 },
  { user: users[:bob], card: cards[:ashiok], card_version: card_versions[:ashiok_thb], min_condition: 'EX', foil: false, language: 'EN', quantity: 1 },
  { user: users[:bob], card: cards[:hydroid], card_version: card_versions[:hydroid_rna], min_condition: 'NM', foil: false, language: 'FR', quantity: 2 },
  
  # Charlie wants
  { user: users[:charlie], card: cards[:elspeth], card_version: card_versions[:elspeth_thb], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:charlie], card: cards[:vivien], card_version: card_versions[:vivien_iko], min_condition: 'NM', foil: false, language: 'EN', quantity: 1 },
  { user: users[:charlie], card: cards[:kaya], card_version: card_versions[:kaya_rna], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  
  # David wants
  { user: users[:david], card: cards[:hydroid], card_version: card_versions[:hydroid_rna], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:david], card: cards[:teferi], card_version: card_versions[:teferi_dom], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:david], card: cards[:lukka], card_version: card_versions[:lukka_iko], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  
  # Emma wants
  { user: users[:emma], card: cards[:ashiok], card_version: card_versions[:ashiok_thb], min_condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:emma], card: cards[:vivien], card_version: card_versions[:vivien_iko], min_condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:emma], card: cards[:teferi], card_version: card_versions[:teferi_dom], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  
  # Frank wants
  { user: users[:frank], card: cards[:elspeth], card_version: card_versions[:elspeth_thb], min_condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  { user: users[:frank], card: cards[:kaya], card_version: card_versions[:kaya_rna], min_condition: 'EX', foil: false, language: 'FR', quantity: 1 },
  { user: users[:frank], card: cards[:hydroid], card_version: card_versions[:hydroid_rna], min_condition: 'NM', foil: false, language: 'EN', quantity: 1 },
  
  # Grace wants
  { user: users[:grace], card: cards[:teferi], card_version: card_versions[:teferi_dom], min_condition: 'EX', foil: true, language: 'EN', quantity: 1 },
  { user: users[:grace], card: cards[:lukka], card_version: card_versions[:lukka_iko], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:grace], card: cards[:hydroid], card_version: card_versions[:hydroid_rna], min_condition: 'NM', foil: true, language: 'EN', quantity: 1 },
  
  # Henry wants
  { user: users[:henry], card: cards[:ashiok], card_version: card_versions[:ashiok_thb], min_condition: 'EX', foil: false, language: 'EN', quantity: 1 },
  { user: users[:henry], card: cards[:vivien], card_version: card_versions[:vivien_iko], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 },
  { user: users[:henry], card: cards[:kaya], card_version: card_versions[:kaya_rna], min_condition: 'NM', foil: false, language: 'FR', quantity: 1 }
].each do |want_data|
  UserWantedCard.create!(want_data)
end

# Create matches based on collections and wants
puts "Creating matches..."
UserWantedCard.all.each do |wanted_card|
  matching_cards = UserCard.joins(:card_version)
                         .where(card_version: { card_id: wanted_card.card_id })
                         .where.not(user_id: wanted_card.user_id)
                         .where('condition >= ?', wanted_card.min_condition)
                         .where(foil: wanted_card.foil)
                         .where(language: wanted_card.language)

  matching_cards.each do |matching_card|
    Match.create!(
      user: wanted_card.user,
      user_id_target: matching_card.user_id,
      user_card: matching_card,
      user_wanted_card: wanted_card
    )
  end
end

# Create trades in different states
puts "Creating trades..."
[
  # Pending trades
  { user: users[:alice], user_id_invit: users[:bob].id, status: "0", created_at: 2.days.ago },
  { user: users[:charlie], user_id_invit: users[:david].id, status: "0", created_at: 1.day.ago },
  
  # Accepted trades
  { user: users[:emma], user_id_invit: users[:frank].id, status: "1", created_at: 3.days.ago, accepted_at: 2.days.ago },
  { user: users[:grace], user_id_invit: users[:henry].id, status: "1", created_at: 2.days.ago, accepted_at: 1.day.ago },
  
  # Completed trades
  { user: users[:bob], user_id_invit: users[:charlie].id, status: "2", created_at: 5.days.ago, accepted_at: 4.days.ago, completed_at: 3.days.ago },
  { user: users[:david], user_id_invit: users[:emma].id, status: "2", created_at: 4.days.ago, accepted_at: 3.days.ago, completed_at: 2.days.ago }
].each do |trade_data|
  Trade.create!(trade_data)
end

# Create chatrooms and messages
puts "Creating chatrooms and messages..."
[
  { users: [users[:alice], users[:bob]], messages: [
    { sender: :alice, content: "Salut ! J'ai vu que tu cherchais Téfeiri, ça t'intéresse ?", time: 2.days.ago },
    { sender: :bob, content: "Oui, très intéressé ! Tu cherches quelque chose en particulier ?", time: 2.days.ago + 1.hour }
  ]},
  { users: [users[:charlie], users[:david]], messages: [
    { sender: :charlie, content: "Hey, j'ai 2 Krasis Hydroïde en excellent état si ça t'intéresse", time: 1.day.ago }
  ]},
  { users: [users[:emma], users[:frank]], messages: [
    { sender: :emma, content: "Bonjour, je vois que tu as un Lukka en foil, toujours dispo ?", time: 3.days.ago },
    { sender: :frank, content: "Oui toujours ! Tu as des cartes à échanger ?", time: 3.days.ago + 2.hours }
  ]}
].each do |chat_data|
  chatroom = Chatroom.create!(
    user: chat_data[:users][0],
    user_id_invit: chat_data[:users][1].id
  )
  
  chat_data[:messages].each do |msg|
    Message.create!(
      chatroom: chatroom,
      user: users[msg[:sender]],
      content: msg[:content],
      created_at: msg[:time]
    )
  end
end

# Create notifications
puts "Creating notifications..."
[
  { user: users[:bob], content: "Alice vous a proposé un échange", status: "unread", notification_type: "trade", created_at: 2.days.ago },
  { user: users[:david], content: "Charlie a accepté votre échange", status: "read", notification_type: "trade", created_at: 12.hours.ago, read_at: 11.hours.ago },
  { user: users[:frank], content: "Emma vous a envoyé un message", status: "unread", notification_type: "message", created_at: 3.days.ago },
  { user: users[:henry], content: "Grace a proposé un nouvel échange", status: "unread", notification_type: "trade", created_at: 1.day.ago }
].each do |notif_data|
  Notification.create!(notif_data)
end

puts "Seed completed!"
