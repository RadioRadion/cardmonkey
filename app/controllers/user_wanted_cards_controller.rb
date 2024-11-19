class UserWantedCardsController < ApplicationController
  before_action :set_user
  before_action :set_user_wanted_card, only: [:edit, :update, :destroy]

  def index
    @user_wanted_cards = @user.user_wanted_cards
      .includes(:card)
      .order('cards.name_en')
  end

  def new
    @form = Forms::UserWantedCardForm.new(user_id: @user.id)
    Rails.logger.debug "Form initialized with user_id: #{@user.id}"
    Rails.logger.debug "Form object: #{@form.inspect}"
  end

  def create
    Rails.logger.debug "Create params: #{params.inspect}"
    Rails.logger.debug "Permitted params: #{user_wanted_card_form_params.inspect}"
    
    @form = Forms::UserWantedCardForm.new(user_wanted_card_form_params)
    
    if @form.save
      redirect_to user_user_wanted_cards_path(@user), notice: t('.success')
    else
      Rails.logger.debug "Form errors: #{@form.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = Forms::UserWantedCardForm.from_model(@user_wanted_card)
  end

  def update
    @form = Forms::UserWantedCardForm.new(
      user_wanted_card_form_params.merge(
        id: @user_wanted_card.id,
        card_id: @user_wanted_card.card_id
      )
    )

    if @form.save
      respond_to do |format|
        format.html { 
          redirect_to user_user_wanted_cards_path(@user), 
          notice: t('.success') 
        }
        format.json { render json: success_json_response }
      end
    else
      respond_to do |format|
        format.html { 
          render :edit, 
          status: :unprocessable_entity 
        }
        format.json { 
          render json: error_json_response, 
          status: :unprocessable_entity 
        }
      end
    end
  end

  def destroy
    name = @user_wanted_card.card.name_en
    if @user_wanted_card.destroy
      respond_to do |format|
        format.html {
          redirect_to user_user_wanted_cards_path(@user),
          notice: t('.success', name: name)
        }
        format.json { head :no_content }
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    handle_destroy_error(e)
  end

  private

  def set_user
    @user = current_user
  end

  def set_user_wanted_card
    @user_wanted_card = @user.user_wanted_cards.find(params[:id])
  end

  def user_wanted_card_form_params
    params.require(:user_wanted_card)
          .permit(:min_condition, :foil, :language, :quantity, 
                 :scryfall_id, :card_id) # Ajout de card_id
          .merge(user_id: @user.id)
  end

  def success_json_response
    {
      message: t('.success'),
      quantity: @user_wanted_card.quantity
    }
  end

  def error_json_response
    {
      message: t('.error'),
      errors: @form.errors.full_messages
    }
  end

  def handle_destroy_error(error)
    respond_to do |format|
      format.html do
        redirect_to user_user_wanted_cards_path(@user),
        alert: t('.not_found')
      end
      format.json { 
        render json: { error: error.message }, 
        status: :not_found 
      }
    end
  end
end