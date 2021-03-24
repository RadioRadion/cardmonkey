require 'json'

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    if @user != current_user
      @trade = Trade.new
      @path = "/users/#{@user.id}/trades/"

      # Les id des cartes que l'on veut dans sa collection pour les afficher en premier
      cards_id_wants = want_cards_id_by_user(current_user, @user)
      # On prend les instances de ces cartes
      @cards_i_wants = Card.find(cards_id_wants)
      # les autres cards
      @other_cards = @user.cards.where.not(id: cards_id_wants)

      # Inversement
      cards_id_other_wants = want_cards_id_by_user(@user, current_user)
      @cards_other_wants = Card.find(cards_id_other_wants)
      @my_cards = current_user.cards.where.not(id: cards_id_other_wants)
    end
    @cards = current_user.cards
    @wants = current_user.wants
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    redirect_to user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:area, :address)
  end

  def want_cards_id_by_user(user, other_user)
    # format avant {user_id: [card_id, card_id], user_id: ......}
    user.want_cards_by_user.select { |user_cards| user_cards[:user_id] == other_user.id }[0][:cards]
    # format apres [card_id, card_id]
  end
end
