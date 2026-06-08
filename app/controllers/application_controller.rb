class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def set_locale
    # MVP is French-only; default_locale is configured in application.rb.
    # When more locales are added, resolve from user preference / params here.
    I18n.locale = I18n.default_locale
  end

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.not_found', default: 'Ressource introuvable.') }
      format.json { render json: { error: 'not_found' }, status: :not_found }
      format.any  { head :not_found }
    end
  end
end
