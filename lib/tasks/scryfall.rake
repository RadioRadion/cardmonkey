require_relative 'scryfall_data_sync.rake'
require_relative 'initialize_cards.rake'
require_relative 'update_prices_task.rake'

namespace :scryfall do
  desc "Download latest Scryfall data and update cards/prices"
  task sync: :environment do
    ScryfallDataSync.new.perform
  end

  desc "Cleanup old Scryfall data backups"
  task cleanup_backups: :environment do
    # Garder seulement les 2 derniers backups
    backup_dir = Rails.root.join('tmp', 'scryfall', 'backups')
    if Dir.exist?(backup_dir)
      files = Dir.glob(File.join(backup_dir, '*')).sort_by { |f| File.mtime(f) }
      files[0...-2].each { |f| File.delete(f) } if files.size > 2
    end
  end
end
