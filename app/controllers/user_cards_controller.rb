# app/controllers/user_cards_controller.rb
class UserCardsController < ApplicationController
  before_action :set_user
  before_action :set_user_card, only: [:edit, :update, :destroy]

  def index
    @pagy, @user_cards = pagy(
      filtered_user_cards,
      items: 15
    )

    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("cards_list", partial: "user_cards/cards_list", locals: { user_cards: @user_cards, pagy: @pagy }) }
    end
  end

  def new
    @form = Forms::UserCardForm.new(user_id: @user.id)
  end

  def create
    @form = Forms::UserCardForm.new(user_card_form_params)

    if @form.save
      redirect_to user_user_cards_path(@user),
                  notice: t('.success', name: @form.card_name)
    else
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

  def filtered_user_cards
    cards = @user.user_cards
                 .includes(card_version: [:card, :extension])

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      cards = cards.joins(card_version: :card)
                   .where("cards.name_fr ILIKE :q OR cards.name_en ILIKE :q", q: search_term)
    end

    # Apply language filter
    if params[:language].present?
      cards = cards.where(language: params[:language])
    end

    # Apply condition filter
    if params[:condition].present?
      cards = cards.where(condition: params[:condition])
    end

    # Apply foil filter
    if params[:foil].present?
      cards = cards.where(foil: params[:foil] == 'true')
    end

    cards.order('card_versions.eur_price DESC NULLS LAST')
  end
end
