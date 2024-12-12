require 'net/http'
require 'json'
require 'fileutils'
require 'logger'

class ScryfallDataSync
  SCRYFALL_BULK_DATA_URL = 'https://api.scryfall.com/bulk-data'
  BACKUP_LIMIT = 2 # On garde seulement le fichier actuel et le précédent
  
  def initialize
    @logger = Logger.new(Rails.root.join('log', 'scryfall_sync.log'))
    @data_dir = Rails.root.join('tmp', 'scryfall')
    @backup_dir = Rails.root.join('tmp', 'scryfall', 'backups')
    
    FileUtils.mkdir_p(@data_dir)
    FileUtils.mkdir_p(@backup_dir)
  end

  def perform
    @logger.info("Starting Scryfall data sync at #{Time.current}")
    
    begin
      download_latest_data
      rotate_backups
      save_new_data
      update_cards_and_prices
      
      @logger.info("Sync completed successfully at #{Time.current}")
    rescue => e
      @logger.error("Sync failed: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
      restore_from_backup
      raise
    end
  end

  private

  def download_latest_data
    @logger.info("Fetching bulk data information from Scryfall")
    
    bulk_data_uri = URI(SCRYFALL_BULK_DATA_URL)
    bulk_data_response = Net::HTTP.get(bulk_data_uri)
    bulk_data = JSON.parse(bulk_data_response)
    
    default_cards = bulk_data['data'].find { |item| item['type'] == 'default_cards' }
    
    unless default_cards
      raise "Could not find default cards data in Scryfall response"
    end

    @logger.info("Downloading cards data from #{default_cards['download_uri']}")
    
    download_uri = URI(default_cards['download_uri'])
    @new_data = Net::HTTP.get(download_uri)
    
    # Vérifier que c'est du JSON valide
    JSON.parse(@new_data)
    
    @logger.info("Download completed, size: #{@new_data.bytesize} bytes")
  end

  def rotate_backups
    current_file = @data_dir.join('all-cards.json')
    
    if File.exist?(current_file)
      # Garder seulement le backup précédent
      previous_backup = @backup_dir.join('all-cards.backup.json')
      
      if File.exist?(previous_backup)
        File.delete(previous_backup)
        @logger.info("Deleted old backup")
      end
      
      FileUtils.cp(current_file, previous_backup)
      @current_backup = previous_backup
      
      @logger.info("Created backup at #{previous_backup}")
    end
  end

  def save_new_data
    output_path = @data_dir.join('all-cards.json')
    
    File.write(output_path, @new_data)
    @logger.info("Saved new data to #{output_path}")
  end

  def restore_from_backup
    backup_file = @backup_dir.join('all-cards.backup.json')
    
    if File.exist?(backup_file)
      @logger.info("Restoring from backup")
      
      FileUtils.cp(backup_file, @data_dir.join('all-cards.json'))
      
      @logger.info("Restore completed")
    else
      @logger.error("No backup available for restore")
    end
  end

  def update_cards_and_prices
    @logger.info("Updating cards and prices")
    
    Rake::Task['cards:initialize'].invoke
    Rake::Task['prices:update'].invoke
    
    @logger.info("Cards and prices update completed")
  end
end

# Ajout des tâches Rake
namespace :scryfall do
  desc "Download latest Scryfall data and update cards/prices"
  task :sync => :environment do
    ScryfallDataSync.new.perform
  end
end

# Ajout d'une tâche pour la mise à jour quotidienne
if defined?(Whenever)
  every 1.day, at: '4:00 am' do # Choisir une heure creuse
    rake "scryfall:sync"
  end
end
