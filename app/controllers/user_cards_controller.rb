# app/controllers/user_cards_controller.rb
class UserCardsController < ApplicationController
  before_action :set_user
  before_action :set_user_card, only: [:edit, :update, :destroy]

  def index
    @user_cards = @user.user_cards
                      .includes(card_version: [:card, :extension])
                      .order('cards.name_en')
  end

  def new
    @form = Forms::UserCardForm.new(user_id: @user.id)
    # Pour le debug
    Rails.logger.debug "Form initialized with user_id: #{@user.id}"
    Rails.logger.debug "Form object: #{@form.inspect}"
  end
  def create
    Rails.logger.debug "=== Create Action ==="
    Rails.logger.debug "Params: #{params.inspect}"
    
    @form = Forms::UserCardForm.new(user_card_form_params)
    Rails.logger.debug "Form created with: #{user_card_form_params.inspect}"
  
    if @form.save
      redirect_to user_user_cards_path(@user), 
                  notice: t('.success', name: @form.card_name)
    else
      Rails.logger.debug "Form errors: #{@form.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_card_versions
    @form = Forms::UserCardForm.from_model(@user_card)
  end

  def update
    @form = Forms::UserCardForm.new(user_card_form_params.merge(id: @user_card.id))

    if @form.save
      respond_to do |format|
        format.html { redirect_to user_user_cards_path(@user), notice: t('.success') }
        format.json { render json: success_json_response }
      end
    else
      respond_to do |format|
        format.html do
          load_card_versions
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: error_json_response, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    name = @user_card.card_version.card.name_en
    
    if @user_card.destroy
      respond_to do |format|
        format.html { 
          redirect_to user_user_cards_path(@user), 
                      notice: t('.success', name: name)
        }
        format.json { head :no_content }
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    handle_destroy_error(e)
  end

  def search
    results = Cards::SearchService.call(params[:query])
    render json: results
  end

  private

  def set_user
    @user = current_user
  end

  def set_user_card
    @user_card = @user.user_cards.find(params[:id])
  end

  def load_card_versions
    @card = @user_card.card_version.card
    @versions = @card.card_versions
                    .includes(:extension)
                    .order('extensions.name ASC')
  end

  def user_card_form_params
    params.require(:user_card)
          .permit(:condition, :foil, :language, :quantity, 
                 :card_version_id, :scryfall_id, :card_name)
          .merge(user_id: @user.id)
  end

  def success_json_response
    {
      message: t('.success'),
      quantity: @user_card.quantity
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
        redirect_to user_user_cards_path(@user), 
                    alert: t('.not_found')
      end
      format.json { render json: { error: error.message }, status: :not_found }
    end
  end
end
