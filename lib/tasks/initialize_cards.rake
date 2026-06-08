require_relative '../../config/environment'
require 'logger'
require_relative 'scryfall_client'

class CardInitializer
  BATCH_SIZE = 1000
  IMPORTED_LANGUAGES = %w[en fr].freeze
  SCRYFALL_SETS_URL = 'https://api.scryfall.com/sets'

  def initialize
    @logger = Logger.new(Rails.root.join('log', 'card_import.log'))
    @success_count = { cards: 0, versions: 0 }
    @error_count = { cards: 0, versions: 0 }
    @skipped = 0
    @extensions_by_code = {}
  end

  def perform
    json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')

    unless File.exist?(json_file_path)
      @logger.error("File not found: #{json_file_path}")
      raise 'Cards data file not found'
    end

    @logger.info("Starting card import at #{Time.current}")
    load_extensions

    buffer = []
    ScryfallClient.each_object(json_file_path) do |card_data|
      next unless importable?(card_data)

      buffer << card_data
      if buffer.size >= BATCH_SIZE
        flush(buffer)
        buffer = []
      end
    end
    flush(buffer) unless buffer.empty?

    log_results
  end

  private

  # Skip non-physical / non-supported printings.
  def importable?(card_data)
    return false unless IMPORTED_LANGUAGES.include?(card_data['lang'])
    return false if card_data['digital']            # MTGO/Arena/Alchemy only
    return false if card_data['layout'] == 'token'  # tokens are not tradeable cards

    true
  end

  # Fetch every set once and upsert the Extension rows we depend on.
  def load_extensions
    @logger.info('Loading set/extension data from Scryfall')
    sets = ScryfallClient.get_json(SCRYFALL_SETS_URL)['data']

    sets.each do |set_data|
      extension = Extension.find_or_initialize_by(code: set_data['code'])
      extension.assign_attributes(
        name: set_data['name'],
        release_date: set_data['released_at'],
        icon_uri: set_data['icon_svg_uri']
      )
      if extension.save
        @extensions_by_code[set_data['code']] = extension
      else
        @logger.error("Failed to save extension #{set_data['code']}: #{extension.errors.full_messages.join(', ')}")
      end
    end

    @logger.info("Loaded #{@extensions_by_code.size} extensions")
  end

  def flush(batch)
    ActiveRecord::Base.transaction do
      batch.each { |card_data| process_card(card_data) }
    end
  rescue => e
    @logger.error("Error processing batch: #{e.message}")
    raise
  end

  def process_card(card_data)
    card = upsert_card(
      scryfall_oracle_id: card_data['oracle_id'],
      name_en: card_data['lang'] == 'en' ? card_data['name'] : nil,
      name_fr: card_data['lang'] == 'fr' ? (card_data['printed_name'] || card_data['name']) : nil
    )

    process_card_version(card, card_data) if card
  rescue => e
    @error_count[:cards] += 1
    @logger.error("Error processing card #{card_data['oracle_id']}: #{e.message}")
  end

  def upsert_card(attributes)
    card = Card.find_or_initialize_by(scryfall_oracle_id: attributes[:scryfall_oracle_id])
    # Only overwrite a localized name when this printing carries it.
    card.name_en = attributes[:name_en] if attributes[:name_en]
    card.name_fr = attributes[:name_fr] if attributes[:name_fr]
    # Fall back so the (presence-validated) columns are never nil for EN-only cards.
    card.name_en ||= card.name_fr
    card.name_fr ||= card.name_en

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
    extension = @extensions_by_code[card_data['set']]
    unless extension
      @skipped += 1
      @logger.warn("Skipping version #{card_data['id']}: unknown set '#{card_data['set']}'")
      return
    end

    version_attributes = {
      card_id: card.id,
      extension_id: extension.id,
      scryfall_id: card_data['id'],
      img_uri: image_uri_for(card_data),
      eur_price: card_data.dig('prices', 'eur'),
      eur_foil_price: card_data.dig('prices', 'eur_foil'),
      rarity: card_data['rarity'],
      frame: card_data['frame'],
      border_color: card_data['border_color'],
      collector_number: card_data['collector_number']
    }

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

  # Single-faced cards expose image_uris directly; double-faced / split /
  # adventure cards only expose them per face -> fall back to the front face.
  def image_uri_for(card_data)
    card_data.dig('image_uris', 'normal') ||
      card_data.dig('card_faces', 0, 'image_uris', 'normal')
  end

  def log_results
    summary = "cards: #{@success_count[:cards]} ok / #{@error_count[:cards]} err, " \
              "versions: #{@success_count[:versions]} ok / #{@error_count[:versions]} err, " \
              "skipped versions (unknown set): #{@skipped}"
    @logger.info("Import completed at #{Time.current} — #{summary}")
    puts "Import completed. Check log/card_import.log for details."
    puts summary
  end
end

namespace :cards do
  desc 'Initialize cards safely with streaming + batch processing'
  task initialize: :environment do
    CardInitializer.new.perform
  end
end
