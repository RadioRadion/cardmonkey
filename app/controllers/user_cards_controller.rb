# app/controllers/user_cards_controller.rb
class UserCardsController < ApplicationController
  before_action :set_user
  before_action :set_user_card, only: %i[edit update destroy]

  def index
    @pagy, @user_cards = pagy(
      filtered_user_cards,
      limit: 15
    )

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("cards_list", partial: "user_cards/cards_list",
                                                                locals: { user_cards: @user_cards, pagy: @pagy })
      end
    end
  end

  def new
    @form = Forms::UserCardForm.new(user_id: @user.id)
  end

  def create
    @form = Forms::UserCardForm.new(user_card_form_params)

    if @form.save
      notice = t('.success', name: @form.card_name)
      # "Enregistrer et ajouter une autre" : on reste sur un formulaire vide
      if params[:add_another].present?
        redirect_to new_user_user_card_path(@user), notice: notice
      else
        redirect_to user_user_cards_path(@user), notice: notice
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Affiche l'écran d'import en masse (coller une liste / CSV).
  def import
  end

  # Traite l'import : petit volume en synchrone (résultat immédiat),
  # gros volume en asynchrone (job + notification).
  def import_run
    content = import_content
    if content.blank?
      redirect_to import_user_user_cards_path(@user), alert: t('.empty', default: "Aucune donnée à importer.")
      return
    end

    rows = CollectionImport.parse(import_source, content, import_defaults)

    if rows.empty?
      redirect_to import_user_user_cards_path(@user),
                  alert: t('.nothing_parsed', default: "Rien n'a pu être lu. Vérifie le format.")
    elsif rows.size > ASYNC_IMPORT_THRESHOLD
      CollectionImportJob.perform_later(@user.id, import_source, content, import_defaults)
      redirect_to user_user_cards_path(@user),
                  notice: t('.queued', count: rows.size,
                                       default: "Import de #{rows.size} lignes lancé — tu seras notifié à la fin.")
    else
      @result = CollectionImport::Importer.new(@user).call(rows)
      render :import_result
    end
  rescue ArgumentError => e
    redirect_to import_user_user_cards_path(@user), alert: e.message
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
        format.html do
          redirect_to user_user_cards_path(@user),
                      notice: t('.success', name: name)
        end
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

  ASYNC_IMPORT_THRESHOLD = 50

  def import_source
    params[:source].to_s == "csv" ? "csv" : "decklist"
  end

  def import_content
    if import_source == "csv" && params[:file].present?
      params[:file].read
    else
      params[:decklist].to_s
    end
  end

  def import_defaults
    {
      condition: params[:default_condition].presence || "near_mint",
      language: params[:default_language].presence || "en",
      foil: params[:default_foil].presence
    }
  end

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
                 .includes(card_version: %i[card extension])

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      cards = cards.joins(card_version: :card)
                   .where("cards.name_fr ILIKE :q OR cards.name_en ILIKE :q", q: search_term)
    end

    # Apply language filter
    cards = cards.where(language: params[:language]) if params[:language].present?

    # Apply condition filter
    cards = cards.where(condition: params[:condition]) if params[:condition].present?

    # Apply foil filter
    cards = cards.where(foil: params[:foil] == 'true') if params[:foil].present?

    cards.order('card_versions.eur_price DESC NULLS LAST')
  end
end
