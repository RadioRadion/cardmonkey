namespace :data do
  desc "Rake task to get news prices to cards"
  task :fetchCards => :environment do
    puts "Updating Cards prices…"
    Card.getprices
    puts "#{Time.now} — Success for cards!"
  end
end

namespace :data do
  desc "Rake task to get news prices wants"
  task :fetchWants => :environment do
    puts "Updating Wants prices…"
    Want.getprices
    puts "#{Time.now} — Success for wants"
  end
end
