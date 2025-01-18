require_relative '../../config/environment'
require 'json'
require 'logger'

class CardInitializer
  BATCH_SIZE = 1000
  
  def initialize
    @logger = Logger.new(Rails.root.join('log', 'card_import.log'))
    @success_count = { cards: 0, versions: 0 }
    @error_count = { cards: 0, versions: 0 }
  end

  def perform
    json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')
    
    unless File.exist?(json_file_path)
      @logger.error("File not found: #{json_file_path}")
      raise "Cards data file not found"
    end

    @logger.info("Starting card import at #{Time.current}")
    
    begin
      file = File.read(json_file_path)
      cards_data = JSON.parse(file)
      
      process_in_batches(cards_data)
      
      log_results
    rescue JSON::ParserError => e
      @logger.error("JSON parsing error: #{e.message}")
      raise
    rescue => e
      @logger.error("Unexpected error: #{e.message}")
      raise
    end
  end

  private

  def process_in_batches(cards_data)
    cards_data.each_slice(BATCH_SIZE) do |batch|
      ActiveRecord::Base.transaction do
        begin
          process_batch(batch)
        rescue => e
          @logger.error("Error processing batch: #{e.message}")
          raise
        end
      end
    end
  end

  def process_batch(batch)
    filtered_batch = batch.select { |card| ['en', 'fr'].include?(card['lang']) }
    
    filtered_batch.each do |card_data|
      process_card(card_data)
    end
  end

  def process_card(card_data)
    # Trouver ou créer la carte avec upsert
    card_attributes = {
      scryfall_oracle_id: card_data['oracle_id'],
      name_en: card_data['lang'] == 'en' ? card_data['name'] : nil,
      name_fr: card_data['lang'] == 'fr' ? (card_data['printed_name'] || card_data['name']) : nil
    }

    card = upsert_card(card_attributes)
    
    if card
      process_card_version(card, card_data)
    end
  rescue => e
    @error_count[:cards] += 1
    @logger.error("Error processing card #{card_data['oracle_id']}: #{e.message}")
  end

  def upsert_card(attributes)
    card = Card.find_or_initialize_by(scryfall_oracle_id: attributes[:scryfall_oracle_id])
    
    # Met à jour seulement si les champs ne sont pas nil
    card.name_en = attributes[:name_en] if attributes[:name_en]
    card.name_fr = attributes[:name_fr] if attributes[:name_fr]
    
    if card.save
      @success_count[:cards] += 1
      card
    else
      @error_count[:cards] += 1
      @logger.error("Failed to save card: #{card.errors.full_messages.join(', ')}")
      nil
    end
  end

  def process_card_version(card, card_data)
    version_attributes = {
      card_id: card.id,
      scryfall_id: card_data['id'],
      img_uri: card_data.dig('image_uris', 'normal'),
      eur_price: card_data.dig('prices', 'eur'),
      eur_foil_price: card_data.dig('prices', 'eur_foil')
    }

    # Utilise find_or_initialize_by pour éviter les doublons
    card_version = CardVersion.find_or_initialize_by(
      card_id: version_attributes[:card_id],
      scryfall_id: version_attributes[:scryfall_id]
    )

    card_version.assign_attributes(version_attributes)

    if card_version.save
      @success_count[:versions] += 1
    else
      @error_count[:versions] += 1
      @logger.error("Failed to save card version: #{card_version.errors.full_messages.join(', ')}")
    end
  rescue => e
    @error_count[:versions] += 1
    @logger.error("Error processing card version for card #{card.id}: #{e.message}")
  end

  def log_results
    @logger.info("Import completed at #{Time.current}")
    @logger.info("Successfully processed: #{@success_count[:cards]} cards and #{@success_count[:versions]} versions")
    @logger.info("Errors encountered: #{@error_count[:cards]} cards and #{@error_count[:versions]} versions")
    
    puts "Import completed. Check logs at log/card_import.log for details."
    puts "Successfully processed: #{@success_count[:cards]} cards and #{@success_count[:versions]} versions"
    puts "Errors encountered: #{@error_count[:cards]} cards and #{@error_count[:versions]} versions"
  end
end

# Ajout de la tâche Rake
namespace :cards do
  desc "Initialize cards safely with batch processing and error handling"
  task :initialize => :environment do
    CardInitializer.new.perform
  end
end
