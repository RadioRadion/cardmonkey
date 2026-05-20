require 'json'
require 'set'
require 'logger'

module UpdatePricesTask
  class Updater
    BATCH_SIZE = 1000

    def initialize
      @logger = Logger.new(Rails.root.join('log', 'price_updates.log'))
      @updated_count = 0
      @error_count = 0
      @start_time = Time.current
    end

    def perform
      @logger.info("Starting price update at #{@start_time}")
      
      begin
        process_price_updates
      rescue => e
        @logger.error("Fatal error during price update: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        raise
      ensure
        log_results
      end
    end

    private

    def process_price_updates
      json_file_path = Rails.root.join('tmp', 'scryfall', 'all-cards.json')
      
      unless File.exist?(json_file_path)
        @logger.error("Price data file not found: #{json_file_path}")
        raise "Price data file not found"
      end

      cards_data = JSON.parse(File.read(json_file_path))
      process_in_batches(cards_data)
    end

    def process_in_batches(cards_data)
      cards_data.each_slice(BATCH_SIZE) do |batch|
        ActiveRecord::Base.transaction do
          begin
            update_batch(batch)
          rescue => e
            @logger.error("Error processing batch: #{e.message}")
            raise
          end
        end
      end
    end

    def update_batch(batch)
      batch.each do |card_data|
        update_card_prices(card_data)
      end
    end

    def update_card_prices(card_data)
      scryfall_id = card_data['id']
      return unless scryfall_id

      card_version = CardVersion.find_by(scryfall_id: scryfall_id)
      return unless card_version

      old_prices = {
        eur: card_version.eur_price,
        eur_foil: card_version.eur_foil_price
      }

      new_prices = {
        eur: card_data.dig('prices', 'eur'),
        eur_foil: card_data.dig('prices', 'eur_foil')
      }

      if prices_changed?(old_prices, new_prices)
        update_prices(card_version, new_prices)
      end
    rescue => e
      @error_count += 1
      @logger.error("Error updating prices for card #{scryfall_id}: #{e.message}")
    end

    def prices_changed?(old_prices, new_prices)
      old_prices[:eur] != new_prices[:eur] || old_prices[:eur_foil] != new_prices[:eur_foil]
    end

    def update_prices(card_version, prices)
      if card_version.update(
        eur_price: prices[:eur],
        eur_foil_price: prices[:eur_foil]
      )
        @updated_count += 1
        log_price_change(card_version, prices)
      else
        @error_count += 1
        @logger.error("Failed to update prices for card version #{card_version.id}: #{card_version.errors.full_messages.join(', ')}")
      end
    end

    def log_price_change(card_version, new_prices)
      card_name = card_version.card&.name_en || 'Unknown Card'
      @logger.info("Updated prices for #{card_name} (ID: #{card_version.id})")
      @logger.info("  New prices: EUR: #{new_prices[:eur]}, EUR Foil: #{new_prices[:eur_foil]}")
    end

    def log_results
      duration = Time.current - @start_time
      @logger.info("Price update completed at #{Time.current}")
      @logger.info("Duration: #{duration.round(2)} seconds")
      @logger.info("Successfully updated: #{@updated_count} card versions")
      @logger.info("Errors encountered: #{@error_count}")

      puts "Price update completed. Check logs at log/price_updates.log for details."
      puts "Successfully updated: #{@updated_count} card versions"
      puts "Errors encountered: #{@error_count}"
    end
  end

  def self.perform
    Updater.new.perform
  end
end

# Ajout de la tâche Rake
namespace :prices do
  desc "Update card prices safely with batch processing and error handling"
  task :update => :environment do
    UpdatePricesTask.perform
  end
end
