class Trade < ApplicationRecord
  belongs_to :user
  belongs_to :user_invit, class_name: 'User', foreign_key: 'user_id_invit'
  belongs_to :last_modifier, class_name: 'User', optional: true
  has_many :trade_user_cards, dependent: :destroy
  has_many :user_cards, through: :trade_user_cards

  validates :user_id_invit, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending modified accepted done cancelled] }

  before_validation :set_default_status, on: :create

  enum status: {
    pending: 0,
    modified: 1,
    accepted: 2,
    done: 3,
    cancelled: 4
  }

  def partner_for(current_user)
    current_user.id == user_id ? user_invit : user
  end

  def partner_name_for(current_user)
    partner_for(current_user).username
  end

  def other_user(current_user)
    current_user.id == user_id ? user_invit : user
  end

  def can_be_modified_by?(current_user)
    return false unless pending? || modified?
    [user_id, user_id_invit].include?(current_user.id)
  end

  def can_be_validated?(current_user)
    return false unless modified?
    return false if last_modifier_id == current_user.id
    [user_id, user_id_invit].include?(current_user.id)
  end

  def can_be_accepted_by?(current_user)
    pending? && current_user.id == user_id_invit
  end

  def self.save_message(from_user_id, to_user_id, content)
    chatroom = find_or_create_chatroom(from_user_id, to_user_id)
    Message.create!(
      content: content,
      user_id: from_user_id,
      chatroom_id: chatroom.id
    )
  end

  def self.find_or_create_chatroom(user1_id, user2_id)
    Chatroom.find_or_create_by!(
      user_id: [user1_id, user2_id].min,
      user_id_invit: [user1_id, user2_id].max
    )
  end

  private

  def set_default_status
    self.status ||= :pending
  end
end
