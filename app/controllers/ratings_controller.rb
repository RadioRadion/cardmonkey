class RatingsController < ApplicationController
  before_action :set_trade
  before_action :verify_can_rate, only: [:new, :create]

  def new
    @rating = Rating.new
    @other_user = @trade.other_user(current_user)
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.trade = @trade
    @rating.rater = current_user
    @rating.rated = @trade.other_user(current_user)

    if @rating.save
      redirect_to trade_path(@trade), notice: "Merci pour votre évaluation !"
    else
      @other_user = @trade.other_user(current_user)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:trade_id])
  end

  def verify_can_rate
    unless @trade.done?
      redirect_to trade_path(@trade), alert: "Vous ne pouvez noter que les échanges terminés."
      return
    end

    unless [@trade.user_id, @trade.user_id_invit].include?(current_user.id)
      redirect_to root_path, alert: "Vous n'êtes pas autorisé à noter cet échange."
      return
    end

    if Rating.exists?(trade: @trade, rater: current_user)
      redirect_to trade_path(@trade), alert: "Vous avez déjà noté cet échange."
      return
    end
  end

  def rating_params
    params.require(:rating).permit(:score, :comment)
  end
end
