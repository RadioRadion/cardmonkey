# app/models/forms/user_card_form.rb
module Forms
  class UserCardForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :user_id, :integer
    attribute :scryfall_id, :string
    attribute :card_version_id, :string  # Changé en string car ça semble être un UUID
    attribute :condition, :string
    attribute :language, :string
    attribute :quantity, :integer
    attribute :foil, :boolean
    attribute :card_name, :string  # Added this attribute for the form

    validates :user_id, :condition, :language, :quantity, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :foil, inclusion: { in: [true, false, '0', '1', 0, 1] }
    validates :card_name, presence: true, unless: :editing?

    # Méthode de classe pour initialiser le form à partir d'un modèle existant
    def self.from_model(user_card)
      new(
        id: user_card.id,
        user_id: user_card.user_id,
        card_version_id: user_card.card_version_id,
        condition: user_card.condition,
        language: user_card.language,
        quantity: user_card.quantity,
        foil: user_card.foil,
        card_name: user_card.card_version&.card&.name_fr
      )
    end

    def editing?
      id.present?
    end

    def card_name
      return @card_name if @card_name.present?
      return nil unless card_version_id.present?
      version = CardVersion.find_by(id: card_version_id)
      return nil unless version&.card
      "#{version.card.name_fr} - #{version.card.name_en}"
    end

    def card_name=(value)
      @card_name = value
    end

    def save
      Rails.logger.debug "=== Saving Form ==="
      Rails.logger.debug "Attributes: #{attributes.inspect}"
      Rails.logger.debug "Valid? #{valid?}"
      Rails.logger.debug "Errors: #{errors.full_messages}" if errors.any?

      return false unless valid?

      ActiveRecord::Base.transaction do
        create_or_update_user_card.tap do |user_card|
          Rails.logger.debug "Created/Updated UserCard: #{user_card.inspect}"
          Rails.logger.debug "UserCard errors: #{user_card.errors.full_messages}" if user_card.errors.any?
        end
      end
    rescue => e
      Rails.logger.debug "Error saving: #{e.message}"
      errors.add(:base, e.message)
      false
    end

    private

    def create_or_update_user_card
      if id
        update_existing_card
      else
        create_new_card
      end
    end

    def create_new_card
      user.user_cards.create!(
        card_version: find_card_version,
        condition: condition,
        language: language,
        quantity: quantity.to_i,
        foil: foil.in?(['1', 1, true])
      )
    end

    def update_existing_card
      user_card = user.user_cards.find(id)
      user_card.update!(
        card_version: find_card_version,
        condition: condition,
        language: language,
        quantity: quantity.to_i,
        foil: foil.in?(['1', 1, true])
      )
      user_card
    end

    def find_card_version
      @card_version ||= if card_version_id.present?
        CardVersion.find(card_version_id)
      elsif scryfall_id.present?
        # Si scryfall_id est en fait un oracle_id
        card = Card.find_by!(scryfall_oracle_id: scryfall_id)
        # Prendre la première version disponible
        card.card_versions.first
      end
    end

    def user
      @user ||= User.find(user_id)
    end
  end
end
