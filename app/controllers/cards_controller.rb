class CardsController < ApplicationController
  require 'csv'
  require 'json'
  require 'open-uri'
  require "down"
  require "fileutils"
  require "pry-byebug"

  def index
    @cards = current_user.cards
  end

  def new
    require 'csv'
    @card = Card.new

    @cards = []
    @names = []
    filepath = 'lib/datas/cards.csv'
    CSV.foreach(filepath, headers: :first_row, liberal_parsing: true, :row_sep => :auto, :col_sep => ";") do |row|

    # Here, row is an array of columns. 46 => name, 59 => setCode, 68 uuid
      @cards << [row[9], row[12]]
      @names << row[9]
    end
    @uniqs_name = @names.uniq.sort
  end

  def create
    @card = Card.new(cards_params)
    fetch_image
    search_image
    save_image if @image.nil?
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
    check_destroy_image
    redirect_to user_cards_path(current_user)
  end

  private

  def cards_params
    params.require(:card).permit(:name, :quantity, :extension, :foil, :condition, :language)
  end

  def fetch_image
    url = 'https://api.scryfall.com/cards/named?fuzzy=' + @card.name
    card_serialized = open(url).read
    card = JSON.parse(card_serialized)
    @api_id = card["id"]
    cards_url = card["prints_search_uri"]
    cards_serialized = open(cards_url).read
    total_cards = JSON.parse(cards_serialized)
    number_cards = total_cards["total_cards"]
    (0...number_cards).to_a.each do |number|
      @img_path = total_cards["data"][number]["image_uris"]["border_crop"]
      return @img_path if total_cards["data"][number]["set"].upcase == @card.extension
    end
  end

  def search_image
    @image = Image.find_by(api_id: @api_id)
  end

  def save_image
    @image = Image.new(api_id: @api_id, img_path: "./app/assets/images/cards/#{@api_id}.jpg")
    tempfile = Down.download(@img_path)
    FileUtils.mv(tempfile.path, "./app/assets/images/cards/#{@api_id}.jpg")
  end

  def check_destroy_image
    if Card.find_by(image_id: @card.image_id).nil? && Want.find_by(image_id: @want.image_id).nil?
      image = Image.find(@card.image_id)
      FileUtils.rm("./app/assets/images/cards/#{image.api_id}.jpg")
      image.destroy
    end
  end
end
