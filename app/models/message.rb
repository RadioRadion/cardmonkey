class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many_attached :attachments

  validates :content, presence: true, unless: -> { has_attachments? || trade_message? }
  validates :content, length: { maximum: 2000 }
  validate :attachments_size_and_type

  scope :ordered, -> { order(created_at: :asc) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :with_includes, -> { includes(:user, attachments_attachments: :blob) }
  scope :unread, -> { where(read_at: nil) }
  scope :unread_for, ->(user) { where(read_at: nil).where.not(user: user) }

  after_create_commit :mark_chatroom_as_unread
  after_update :track_edit_timestamp
  
  def edited?
    edited_at.present?
  end

  def delivered?
    delivered_at.present?
  end

  def read?
    read_at.present?
  end

  def mark_as_read!(user)
    return if user == self.user
    update(read_at: Time.current) unless read?
  end

  def mark_as_delivered!
    update(delivered_at: Time.current) unless delivered?
  end

  def trade_message?
    metadata['type'] == 'trade' && metadata['trade_id'].present?
  end

  def trade_id
    metadata['trade_id'] if trade_message?
  end

  def display_content
    if trade_message?
      "#{user.username} a proposé un échange"
    else
      content
    end
  end

  def timestamp
    if created_at.to_date == Date.today
      created_at.strftime("%H:%M")
    else
      created_at.strftime("%d/%m/%Y %H:%M")
    end
  end

  def has_attachments?
    attachments.any?
  end

  private

  def track_edit_timestamp
    return unless saved_change_to_content?
    touch(:edited_at)
  end

  def mark_chatroom_as_unread
    other_user = chatroom.other_user(user)
    chatroom.mark_as_unread_for(other_user) if other_user
  end

  def attachments_size_and_type
    return unless attachments.attached?

    attachments.each do |attachment|
      if attachment.byte_size > 10.megabytes
        errors.add(:attachments, 'Le fichier est trop volumineux (max 10MB)')
      end

      unless attachment.content_type.in?(%w[image/jpeg image/png image/gif application/pdf])
        errors.add(:attachments, 'Format de fichier non supporté')
      end
    end
  end
end
