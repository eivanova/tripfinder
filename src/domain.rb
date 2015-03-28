
class Network
	
  def initialize(points_filepath, routes_filepath)
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

  def paths_from(point)
    @points[point]	  
  end

  def size 
    @points.size
  end    

  def points
    @points.keys
  end

  def paths
    @points.values.flatten.uniq
  end

  :private

  # for each point we keep a list of paths The neighbours of the point 
  # can be found by collecting all the finishes of the paths for that point
  def load_data(points_file, routes_file)
    require 'csv'
    p "Loading points..."
    CSV.foreach(points_file) do |row|
      next if row[0][1] == "#" 
      row.map!{|value| value.strip if value }
      row[2] = row[2].eql? "да" ? true : false
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

  def sleep_over?
    @type.eq? "хижа" or @type.eq? "заслон"	  
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
