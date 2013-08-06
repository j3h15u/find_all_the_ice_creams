require 'rest-client'
require 'json'
require 'addressable/uri'
require 'debugger'
require 'nokogiri'
require 'open-uri'

p "Please enter an address: "
addr = gets.chomp

query = Addressable::URI.new(
         :scheme => "https",
         :host => "maps.googleapis.com",
         :path => "maps/api/geocode/json",
         :query_values => {:address => addr, :sensor => false}
         ).to_s


result = RestClient.get(query)

current_location = JSON.parse(result)
coord = current_location["results"].first["geometry"]["location"].values



places = Addressable::URI.new(
         :scheme => "https",
         :host => "maps.googleapis.com",
         :path => "maps/api/place/nearbysearch/json",
         :query_values => {:location => coord.join(","),
                           :radius => 500,
                           :types => 'food',
                           :keyword => 'icecream',
                           :sensor => false,
                           :key => 'AIzaSyCEj7y5rpqL6v-U9JjJCRZNFZCsjL8TA-Y'
                         }
         ).to_s

icecream = RestClient.get(places)

icecream_locations = JSON.parse(icecream)

icecream_choices =[]

icecream_locations["results"].each_with_index do |location, idx|
  icecream_hash = {}
  icecream_hash["coordinates"] = location["geometry"]["location"].values
  icecream_hash["name"] = location["name"]
  icecream_choices << icecream_hash
end

icecream_choices.each do |icecream_choice|

  directions = Addressable::URI.new(
               :scheme => "https",
               :host => "maps.googleapis.com",
               :path => "maps/api/directions/json",
               :query_values => {:origin => coord.join(","),
                     :destination => icecream_choice["coordinates"].join(", "),
                     :mode => 'walking',
                     :sensor => false
                    }
               ).to_s

   html_instructions = "For #{icecream_choice["name"]}: \n"
   direction_results = RestClient.get(directions)
   direction_json = JSON.parse(direction_results)

   #p direction_json["routes"].first["legs"].first["steps"].first["html_instructions"]

   direction_json["routes"].first["legs"].each do |leg|
     leg["steps"].each do |step|
       html_instructions.concat(step["html_instructions"])
     end
   end

   puts Nokogiri::HTML("#{html_instructions}").text
end






 #and and equals symbols must be present
 #1061 Market St, San Francisco, CA