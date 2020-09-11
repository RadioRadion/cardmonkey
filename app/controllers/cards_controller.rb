class CardsController < ApplicationController
  require 'csv'
  require 'json'
  require 'open-uri'
  require "down"
  require "fileutils"

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
    fetchImage
    searchImage
    saveImage if @image.nil?
    @card.image = @image
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

  def fetchImage
    url = 'https://api.scryfall.com/cards/named?fuzzy=' + @card.name
    card_serialized = open(url).read
    card = JSON.parse(card_serialized)
    @api_id = card["id"]
    @img_path = card["image_uris"]["border_crop"]
  end

  def searchImage
    @image = Image.find_by(api_id: @api_id)
  end

  def saveImage
    @image = Image.new(api_id: @api_id, img_path: @img_path)
    # open("https://api.scryfall.com/cards/named?fuzzy=opt") do |image|
    #   File.open("./app/assets/images/cards/test2.jpg", "wb") do |file|
    #     file.write(image.read)
    #   end
    # end

    tempfile = Down.download(@img_path)
    FileUtils.mv(tempfile.path, "./app/assets/images/cards/#{@api_id}.jpg")

  end
end
