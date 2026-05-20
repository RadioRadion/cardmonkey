# app/models/forms/user_wanted_card_form.rb
module Forms
  class UserWantedCardForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :user_id, :integer
    attribute :scryfall_id, :string
    attribute :card_id, :string
    attribute :card_version_id, :integer 
    attribute :min_condition, :string
    attribute :language, :string, default: 'any'
    attribute :quantity, :integer
    attribute :foil, :boolean

    validates :user_id, :quantity, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :foil, inclusion: { in: [true, false, '0', '1', 0, 1] }
    validates :scryfall_id, presence: true, unless: :card_id
    validates :card_id, presence: true, unless: :scryfall_id

    # Méthode de classe pour initialiser le form à partir d'un modèle existant
    def self.from_model(user_wanted_card)
      new(
        id: user_wanted_card.id,
        user_id: user_wanted_card.user_id,
        card_id: user_wanted_card.card_id,
        card_version_id: user_wanted_card.card_version_id,
        min_condition: user_wanted_card.min_condition,
        language: user_wanted_card.language,
        quantity: user_wanted_card.quantity,
        foil: user_wanted_card.foil
      )
    end

    def card_name
      return nil unless card_id.present?
      card = Card.find_by(id: card_id)
      return nil unless card
      "#{card.name_fr} - #{card.name_en}"
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        create_or_update_user_wanted_card
      end
    rescue => e
      errors.add(:base, e.message)
      false
    end

    private

    def create_or_update_user_wanted_card
      if id
        update_existing_card
      else
        create_new_card
      end
    end

    def create_new_card
      user.user_wanted_cards.create!(
        card: find_card,
        card_version_id: card_version_id,
        min_condition: min_condition,
        language: language,
        quantity: quantity.to_i,
        foil: foil.in?(['1', 1, true])
      )
    end

    def update_existing_card
      user_wanted_card = user.user_wanted_cards.find(id)
      user_wanted_card.update!(
        card: find_card,
        card_version_id: card_version_id,  # Ajout de card_version_id ici
        min_condition: min_condition,
        language: language,
        quantity: quantity.to_i,
        foil: foil.in?(['1', 1, true])
      )
      user_wanted_card
    end

    def find_card
      @card ||= if scryfall_id.present?
        Card.find_by!(scryfall_oracle_id: scryfall_id)
      elsif card_id.present?
        Card.find(card_id)
      else
        raise ActiveRecord::RecordNotFound, "Une carte doit être sélectionnée"
      end
    end

    def user
      @user ||= User.find(user_id)
    end
  end
end
