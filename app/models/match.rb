class Match < ApplicationRecord
  belongs_to :user
  belongs_to :user_card
  belongs_to :user_wanted_card

  validates :user_id_target, presence: true
  validate :no_self_matching

  private

  def no_self_matching
    if user_id == user_id_target
      errors.add(:base, "Un utilisateur ne peut pas matcher avec lui-même")
    end
  end
end
