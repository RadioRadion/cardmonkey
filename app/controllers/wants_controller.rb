class WantsController < ApplicationController
  require 'csv'
  require 'json'
  require 'open-uri'
  require "down"
  require "fileutils"
  require "pry-byebug"

  def index
    @wants = current_user.wants
  end

  def new
    @want = Want.new

    @cards = []
    @names = []
    filepath = 'lib/datas/cards.csv'
    CSV.foreach(filepath, headers: :first_row, liberal_parsing: true, :row_sep => :auto, :col_sep => ";") do |row|
    # Here, row is an array of columns. 46 => name, 59 => setCode
      @cards << [row[9], row[12]]
      @names << row[9]
    end
    # On veut supprimer dans cette variable tous les doublons
    @uniqsName = @names.uniq.sort
  end

  def create
    @want = Want.new(wants_params)
    fetchImage
    searchImage
    saveImage if @image.nil?
    @want.image = @image
    @want.user = current_user
    if @want.save!
      redirect_to user_wants_path
    else
      render :new
    end
  end

  def edit
    @want = Want.find(params[:id])
  end

  def update
    @want = Want.find(params[:id])

    if @want.update!(wants_params)
      redirect_to user_wants_path
    else
      render :new
    end
  end

  def destroy
    @want = Want.find(params[:id])
    @want.destroy
    redirect_to user_wants_path(current_user)
  end

  private

  def wants_params
    params.require(:want).permit(:name, :quantity, :extension, :foil, :min_cond, :language)
  end

  def fetchImage
    url = 'https://api.scryfall.com/cards/named?fuzzy=' + @want.name
    card_serialized = open(url).read
    card = JSON.parse(card_serialized)
    @api_id = card["id"]
    cardsUrl = card["prints_search_uri"]
    cards_serialized = open(cardsUrl).read
    totalCards = JSON.parse(cards_serialized)
    numberCards = totalCards["total_cards"]
    (0...numberCards).to_a.each do |number|
      @img_path = totalCards["data"][number]["image_uris"]["border_crop"]
      return @img_path if totalCards["data"][number]["set"].upcase == @want.extension
    end
  end

  def searchImage
    @image = Image.find_by(api_id: @api_id)
  end

  def saveImage
    @image = Image.new(api_id: @api_id, img_path: "./app/assets/images/cards/#{@api_id}.jpg")
    tempfile = Down.download(@img_path)
    FileUtils.mv(tempfile.path, "./app/assets/images/cards/#{@api_id}.jpg")
  end

  def checkDestroyImage
    if Card.find_by(image_id: @want.image_id).nil? && Want.find_by(image_id: @want.image_id).nil?
      image = Image.find(@want.image_id)
      FileUtils.rm("./app/assets/images/cards/#{image.api_id}.jpg")
      image.destroy
    end
  end
end
