class CardsController < ApplicationController
  require 'csv'

  def index
    @cards = current_user.cards
  end

  def new
    require 'csv'
    @card = Card.new

    @cards = []
    @names = []
    filepath = 'lib/datas/cards.csv'
    CSV.foreach(filepath) do |row|

    # Here, row is an array of columns. 46 => name, 59 => setCode, 68 uuid
      @cards << [row[46], row[59]]
      @names << row[46]
    end
    @uniqsName = @names.uniq.sort
  end

  def create
    @card = Card.new(cards_params)
    @card.user = current_user
    if @card.save!
      redirect_to user_cards_path
    else
      render :new

    end
  end


  def edit
    @card = Card.find(params[:id])
  end

  def update
    @card = Card.find(params[:id])

    if @card.update(cards_params)
      redirect_to user_cards_path
    else
      render :new

    end
  end

  def destroy
    @card = Card.find(params[:id])
    @card.destroy
    redirect_to user_cards_path(current_user)
  end

  private

  def cards_params
    params.require(:card).permit(:name, :quantity, :extension, :foil, :condition, :language)
  end
end
