class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @wants = current_user.wants
    @cards = current_user.cards
    @otherwants = @user.wants
    @othercards = @user.cards
    @trade = Trade.new
  end

end
