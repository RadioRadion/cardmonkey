namespace :data do
  desc "Rake task to get news prices to cards"
  task :fetchCards => :environment do
    puts "Updating newsexit Articles…"
    Card.getprices
    puts "#{Time.now} — Success for cards!"
  end
end

namespace :data do
  desc "Rake task to get news prices wants"
  task :fetchWants => :environment do
    puts "Updating news Articles…"
    Want.getprices
    puts "#{Time.now} — Success for wants"
  end
end
