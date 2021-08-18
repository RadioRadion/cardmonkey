class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    if current_user
      users = User.near(current_user.address, current_user.area)
      @search_matches = current_user.want_cards_by_user(users)
    end
  end
end
