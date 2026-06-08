class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home privacy_policy faq]

  def home
    @results_sorted = current_user.group_matches if current_user
  end

  def privacy_policy
  end

  def faq
  end
end
