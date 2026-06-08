require 'fileutils'
require 'logger'
require_relative 'scryfall_client'

class ScryfallDataSync
  SCRYFALL_BULK_DATA_URL = 'https://api.scryfall.com/bulk-data'

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
      update_cards_and_prices

      @logger.info("Sync completed successfully at #{Time.current}")
    rescue => e
      @logger.error("Sync failed: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
      restore_from_backup
      raise
    end
  end

  # Removes all backups but the most recent one.
  def cleanup_backups
    backup = @backup_dir.join('all-cards.backup.json')
    stale = Dir.glob(@backup_dir.join('*')).reject { |f| f == backup.to_s }
    stale.each { |f| File.delete(f) if File.file?(f) }
    @logger.info("Cleaned up #{stale.size} stale backup file(s)")
    puts "Cleaned up #{stale.size} stale backup file(s)."
  end

  private

  def current_file
    @data_dir.join('all-cards.json')
  end

  def download_latest_data
    @logger.info('Fetching bulk data information from Scryfall')

    bulk_data = ScryfallClient.get_json(SCRYFALL_BULK_DATA_URL)
    default_cards = bulk_data['data'].find { |item| item['type'] == 'default_cards' }
    raise 'Could not find default cards data in Scryfall response' unless default_cards

    @logger.info("Downloading cards data from #{default_cards['download_uri']}")

    # Keep the previous successful file as a backup, then stream the new one
    # straight to disk (no multi-GB in-memory copy, no validation re-parse).
    rotate_backups
    ScryfallClient.download_to(default_cards['download_uri'], current_file)

    @logger.info("Download completed, size: #{File.size(current_file)} bytes")
  end

  def rotate_backups
    return unless File.exist?(current_file)

    previous_backup = @backup_dir.join('all-cards.backup.json')
    File.delete(previous_backup) if File.exist?(previous_backup)
    FileUtils.cp(current_file, previous_backup)
    @logger.info("Created backup at #{previous_backup}")
  end

  def restore_from_backup
    backup_file = @backup_dir.join('all-cards.backup.json')

    if File.exist?(backup_file)
      @logger.info('Restoring previous data file from backup')
      FileUtils.cp(backup_file, current_file)
      @logger.info('Restore completed')
    else
      @logger.error('No backup available for restore')
    end
  end

  def update_cards_and_prices
    @logger.info('Updating cards and prices')

    Rake::Task['cards:initialize'].invoke
    Rake::Task['prices:update'].invoke

    @logger.info('Cards and prices update completed')
  end
end

namespace :scryfall do
  desc 'Download latest Scryfall data and update cards/prices'
  task sync: :environment do
    ScryfallDataSync.new.perform
  end

  desc 'Remove stale Scryfall backup files (keep the latest)'
  task cleanup_backups: :environment do
    ScryfallDataSync.new.cleanup_backups
  end
end
