class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @search_matches = current_user.want_cards_by_user
  end
end
