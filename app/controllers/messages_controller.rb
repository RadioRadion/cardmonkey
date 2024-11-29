class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom
  before_action :set_message, only: [:update, :destroy, :toggle_reaction, :mark_delivered]
  before_action :authorize_message_action!, only: [:update, :destroy]

  def index
    @messages = @chatroom.messages
                        .includes(:user, :reactions, attachments_attachments: :blob)
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(25)
    
    render @messages.reverse
  end

  def create
    @message = @chatroom.messages.build(message_params)
    @message.user = current_user

    if @message.save
      process_attachments if params[:message][:attachments].present?
      broadcast_message
      create_notification unless @message.user == @chatroom.other_user(current_user)
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_chatroom_path(current_user, @chatroom) }
      end
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @message.update(message_params)
      broadcast_message_update
      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @message.destroy
    broadcast_message_deletion
    head :ok
  end

  def toggle_reaction
    reaction = @message.reactions.find_or_initialize_by(
      user: current_user,
      emoji: params[:emoji]
    )

    if reaction.persisted?
      reaction.destroy
    else
      reaction.save
    end

    broadcast_reactions_update
    head :ok
  end

  def mark_delivered
    return head :ok if @message.user == current_user

    @message.update(delivered_at: Time.current) unless @message.delivered?
    broadcast_delivery_status if @message.saved_change_to_delivered_at?
    
    head :ok
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find_by!(id: params[:chatroom_id])
    authorize_chatroom!
  end

  def set_message
    @message = @chatroom.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, attachments: [])
  end

  def authorize_chatroom!
    unless @chatroom.participant?(current_user)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authorize_message_action!
    unless @message.user == current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def process_attachments
    params[:message][:attachments].each do |attachment|
      @message.attachments.attach(attachment)
    end
  end

  def broadcast_message
    Turbo::StreamsChannel.broadcast_append_to(
      @chatroom,
      target: "message-list",
      partial: "messages/message",
      locals: { message: @message, current_user: @message.user }
    )
  end

  def broadcast_message_update
    Turbo::StreamsChannel.broadcast_replace_to(
      @chatroom,
      target: "message_#{@message.id}",
      partial: "messages/message",
      locals: { message: @message, current_user: @message.user }
    )
  end

  def broadcast_message_deletion
    Turbo::StreamsChannel.broadcast_remove_to(
      @chatroom,
      target: "message_#{@message.id}"
    )
  end

  def broadcast_reactions_update
    Turbo::StreamsChannel.broadcast_replace_to(
      @chatroom,
      target: "message_reactions_#{@message.id}",
      partial: "messages/reactions",
      locals: { message: @message }
    )
  end

  def broadcast_delivery_status
    Turbo::StreamsChannel.broadcast_replace_to(
      @chatroom,
      target: "message_delivery_#{@message.id}",
      html: render_to_string(partial: "messages/delivery_status", locals: { message: @message })
    )
  end

  def create_notification
    other_user = @chatroom.other_user(current_user)
    return unless other_user

    Notification.create_notification(
      other_user.id,
      "Nouveau message de #{current_user.username}",
      'message'
    )
  end
end
