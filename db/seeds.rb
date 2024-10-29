# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

Team.delete_all
League.delete_all


def get_teams(custom_id, league)
  url = URI("https://v3.football.api-sports.io/standings?league=#{custom_id}&season=2022")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'v3.football.api-sports.io'
  request["x-rapidapi-key"] = '3a1526697e73de9263945ed57a8e6040'

  response = http.request(request)

  if response.is_a?(Net::HTTPSuccess)
    json_data = JSON.parse(response.read_body)

    if json_data.key?('response')
      json_data['response'].each do |item|
        standings_data = item['league']['standings'].flatten

        standings_data.each do |team|
          team_data = team['team']

          Team.find_or_create_by!(
            team_name: team_data['name'],
            points: team['points'],
            goal_diff: team['goalsDiff'],
            league_id: league.id
          )
        end
      end
    else
      puts "Key 'response' not found in the JSON data."
    end
  else
    puts "HTTP request failed with code: #{response.code}"
  end
end

url = URI("https://v3.football.api-sports.io/leagues")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["x-rapidapi-host"] = 'v3.football.api-sports.io'
request["x-rapidapi-key"] = '3a1526697e73de9263945ed57a8e6040'

response = http.request(request)

if response.is_a?(Net::HTTPSuccess)
  json_data = JSON.parse(response.read_body)

  if json_data.key?('response')
    json_data['response'].take(10).each do |item|
      league_data = item['league']
      country_data = item['country']

      leagues = League.find_or_create_by!(
        league_name: league_data['name'],
        league_type: league_data['type'],
        custom_id: league_data['id'],
        country_name: country_data['name']
      )
      get_teams(leagues.custom_id, leagues)
    end
  else
    puts "Key 'response' not found in the JSON data."
  end
else
  puts "HTTP request failed with code: #{response.code}"
end

puts "There are now #{League.count} leagues in the database."
puts "There are now #{Team.count} teams in the database."
