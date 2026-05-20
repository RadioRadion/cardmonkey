class Rating < ApplicationRecord
  belongs_to :trade
  belongs_to :rater, class_name: 'User'
  belongs_to :rated, class_name: 'User'

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 500 }
  validates :trade_id, uniqueness: { scope: :rater_id, message: "Vous avez déjà noté cet échange" }

  validate :trade_must_be_completed
  validate :rater_must_be_participant

  scope :recent, -> { order(created_at: :desc) }
  scope :positive, -> { where(score: 4..5) }
  scope :neutral, -> { where(score: 3) }
  scope :negative, -> { where(score: 1..2) }

  private

  def trade_must_be_completed
    return if trade&.done?
    errors.add(:trade, "doit être terminé pour pouvoir noter")
  end

  def rater_must_be_participant
    return unless trade
    return if [trade.user_id, trade.user_id_invit].include?(rater_id)
    errors.add(:rater, "doit être un participant de l'échange")
  end
end
