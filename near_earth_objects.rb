require 'faraday'
require 'figaro'
require 'pry'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(
                  environment: 'production',
                  path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects

  def self.find_neos_by_date(date)
    @@date = date
    {
      astroid_list: astroid_list,
      biggest_astroid: largest_astroid_diameter,
      total_number_of_astroids: total_number_of_astroids
    }
  end

  private

  def self.conn
    Faraday.new(
      url: 'https://api.nasa.gov',
      params: { start_date: @@date, api_key: ENV['nasa_api_key']}
    )
  end

  def self.asteroids_data
    conn.get('/neo/rest/v1/feed').body
  end

  def self.parsed_asteroids_data
    data = JSON.parse(asteroids_data, symbolize_names: true)
    data[:near_earth_objects][:"#{@@date}"]
  end

  def self.total_number_of_astroids
    parsed_asteroids_data.count
  end

  def self.largest_astroid_diameter
    parsed_asteroids_data.map do |astroid|
      asteroid_diameter(astroid).to_i
    end.max { |a,b| a<=> b}
  end

  def self.asteroid_diameter(astroid)
    astroid[:estimated_diameter][:feet][:estimated_diameter_max]
  end

  def self.asteroid_miss_distance(astroid)
    astroid[:close_approach_data][0][:miss_distance][:miles]
  end

  def self.astroid_list
    parsed_asteroids_data.map do |astroid|
    {
      name: astroid[:name],
      diameter: "#{asteroid_diameter(astroid).to_i} ft",
      miss_distance: "#{asteroid_miss_distance(astroid).to_i} miles"
    }
    end
  end

end
