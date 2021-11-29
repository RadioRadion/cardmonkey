require 'open-uri'
require "down"
require "fileutils"
require "uri"
require "net/http"

puts "==========================="
puts "Destroying seed !!!"
puts "==========================="
#User.destroy_all
puts "==========================="
puts "Seed destroyed !!!"
puts "==========================="


puts "==========================="
puts "Creating Users"
puts "==========================="

#u = User.new(email: "tony@botmail.com", password: "azerty", username:"tonygland")
   #u.save!

#User.new(email: "vito@botmail.com", password: "azerty", username:"vitogland").save!
#User.new(email: "bernardo@botmail.com", password: "azerty", username:"bernardoland").save!

#Chatroom.new(name: "general").save!

puts "==========================="
puts "C'est tout Bon !!! :)"
puts "==========================="


Card.fetch_cards("aer")
Card.fetch_cards("mir")

