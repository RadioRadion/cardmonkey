class Trade < ApplicationRecord
  belongs_to :user
  belongs_to :user_invit, class_name: 'User', foreign_key: 'user_id_invit', optional: true

  has_many :trade_user_cards, dependent: :destroy
  has_many :user_cards, through: :trade_user_cards

  # Disable broadcasts in test environment
  unless Rails.env.test?
    broadcasts_to ->(trade) { [trade.user, :trades] }
    broadcasts_to ->(trade) { [trade.user_invit, :trades] }

    after_update_commit -> {
      broadcast_replace_to [user, :trades]
      broadcast_replace_to [user_invit, :trades] if user_invit
    }
  end

  scope :pending, -> { where(status: "0") }
  scope :accepted, -> { where(status: "1") }
  scope :done, -> { where(status: "2") }
  scope :active, -> { where(status: ['0', '1']).where.not(accepted_at: nil) }

  validates :status, presence: true

  enum status: { pending: "0", accepted: "1", done: "2" }

  def self.save_message(current_user_id, other_user_id, content)
    chatroom = find_or_create_chatroom(current_user_id, other_user_id)
    Message.create!(
      content: content,
      user_id: current_user_id,
      chatroom_id: chatroom.id
    )
  end

  def status_badge
    html = case status.to_s
    when "0", "pending"
      '<span class="inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800">En attente</span>'
    when "1", "accepted"
      '<span class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800">Accepté</span>'
    when "2", "done"
      '<span class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">Complété</span>'
    end
    return html.to_s if Rails.env.test?
    html&.html_safe
  end

  def partner_for(current_user)
    return user if current_user.id == user_id_invit
    user_invit
  end

  # Alias pour la compatibilité avec TradeCardCollector
  alias_method :other_user, :partner_for

  def partner_name_for(current_user)
    partner = partner_for(current_user)
    partner&.username || 'Utilisateur supprimé'
  end

  def notify_status_change(current_user_id, message)
    recipient = other_user(User.find(current_user_id))
    Notification.create_notification(recipient.id, message)
    Trade.save_message(current_user_id, recipient.id, "trade_id:#{id}")
  end

  private

  def self.find_or_create_chatroom(current_user_id, other_user_id)
    chatroom = Chatroom.where(
      "(user_id = :current_user_id AND user_id_invit = :other_user_id) OR
       (user_id = :other_user_id AND user_id_invit = :current_user_id)",
      current_user_id: current_user_id,
      other_user_id: other_user_id
    ).first

    unless chatroom
      chatroom = Chatroom.create!(
        user_id: current_user_id,
        user_id_invit: other_user_id
      )
    end

    chatroom
  end
end
