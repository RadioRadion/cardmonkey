class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :privacy_policy]

  def home
    @results_sorted = current_user.group_matches if current_user
  end

  def privacy_policy
  end
end
