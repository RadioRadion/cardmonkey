require 'json'

class UsersController < ApplicationController
  def show
    # serialized_artworks = File.read("public/artworks.json")

    # artworks = JSON.parse(serialized_artworks)
    # raise

    @user = User.find(params[:id])
    @wants = current_user.wants
    @cards = current_user.cards
    @other_wants = @user.wants
    @other_cards = @user.cards
    @trade = Trade.new
  end

end
