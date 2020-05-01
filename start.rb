require_relative 'near_earth_objects'

def start
  @date = user_date_input
  generate_asteroid_data
  generate_columns
  summary
end

def user_date_input
  puts "________________________________________________________________________________________________________________________________"
  puts "Welcome to NEO. Here you will find information about how many meteors, astroids, comets pass by the earth every day. \nEnter a date below to get a list of the objects that have passed by the earth on that day."
  puts "Please enter a date in the following format YYYY-MM-DD."
  print ">>"
  gets.chomp
end

def format_row_data(row_data)
  row = row_data.keys.map { |key| row_data[key].ljust(@column_data[key][:width]) }.join(' | ')
  puts "| #{row} |"
end

def header
  "| #{ @column_data.map { |_,col| col[:label].ljust(col[:width]) }.join(' | ') } |"
end

def divider
  "+-#{@column_data.map { |_,col| "-"*col[:width] }.join('-+-') }-+"
end

def create_rows
  @astroid_list.each { |astroid| format_row_data(astroid) }
end

def generate_columns
  col_labels = { name: "Name", diameter: "Diameter", miss_distance: "Missed The Earth By:" }
  @column_data = col_labels.each_with_object({}) do |(col, label), hash|
    hash[col] = {
      label: label,
      width: [@astroid_list.map { |astroid| astroid[col].size }.max, label.size].max}
  end
end

def generate_asteroid_data
  @astroid_list = NearEarthObjects.find_neos_by_date(@date)[:astroid_list]
end

def format_date
  DateTime.parse(@date).strftime("%A %b %d, %Y")
end

def summary
  puts "______________________________________________________________________________"
  puts "On #{format_date}, there were #{NearEarthObjects.total_number_of_astroids} objects that almost collided with the earth."
  puts "The largest of these was #{NearEarthObjects.largest_astroid_diameter} ft. in diameter."
  puts "\nHere is a list of objects with details:"
  puts divider
  puts header
  create_rows
  puts divider
end

start