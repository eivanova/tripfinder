
class Finder
  
  def initialize(network)
    @network = network
    @chain = initialize_chain()
  end

  def initialize_chain
  end
end

class Network

  def initialize(points_filepath, routes_filepath)
    # for each point we keep a list of routes. The neighbours of the point 
    # can be found by collecting all the finishes of the routes for that point
    @points = {}

    load_data(points_filepath, routes_filepath)
  end	  

  def find_by_name(name) 
    for point in @points.keys
      if point.name == name 
        break
      end
    end
    raise "Invalid point name '%s'" % name if not point
    point
  end

  :private

  def load_data(points_file, routes_file)
    require 'csv'
    p "Loading points..."
    CSV.foreach(points_file) do |row|
      next if row[0][1] == "#" 
      row.map!{|value| value.strip if value }
      @points[Point.new *row] = []
    end
    p "Loading paths..."
    CSV.foreach(routes_file) do |row|
      next if row[0][1] == "#"    
      row.map!{|value| value.strip if value}
      point = find_by_name(row[0])
      @points[point] << Path.new(point, find_by_name(row[1]), row[2], row[3])
    end
    p "Data loaded!"
  end

  def size 
    @points.size
  end    
end

class Point
  attr_reader :region, :name, :starting_point, 
	  :altitude, :coordinates, :type, :comments

  def initialize(region, name, starting_point, altitude, coordinates, type, comments = "")
    @region = region
    @name = name
    @starting_point = starting_point
    @altitude = altitude
    @coordinates = coordinates
    @type = type
    @comments = comments.to_s
  end

  def eql?(other)
    @coordinates.eql? other.coordinates and @name.eql? other.name
  end

  def hash
    [@coordinates, @name].hash
  end
end

class Path
  attr_reader :start, :finish, :hours, :comments

  def initialize(start, finish, hours, comments = "")
    @start = start
    @finish = finish
    @hours = hours
    @comments = comments    
  end	  
end

class Route

  def initialize()
    # route is represented by an array of arrays, where each inner array represnets a day. 
    # Thus a day is represented by an array of Path objects
    @route = []
  end
  
  def days_count()
    @route.size
  end

end
