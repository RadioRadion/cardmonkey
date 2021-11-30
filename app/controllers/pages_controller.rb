class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @results_sorted = current_user.group_matches if current_user
  end
end
