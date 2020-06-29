class TradesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    raise
    @user = User.find(params[:user_id])
    @trade = Trade.new(statut: "pending")
    @trade.user = @user
    if @trade.save
      redirect_to user_path(@user)
    else
      render 'users/show'
    end
  end

  private

  def trade_params
    params.require(:trade).permit(:offer, :target)
  end

end
