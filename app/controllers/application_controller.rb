class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_locale

  private

  def set_locale
    I18n.locale = :fr
  end
end
