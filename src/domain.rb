class Network
	
  def initialize(points_filepath, routes_filepath)
    @points = {}

    load_data(points_filepath, routes_filepath)
    populate_implicit_paths
  end	  

  def find_by_name(name) 
    for point in @points.keys
      return point if point.name == name 
    end
    raise "Invalid point name '%s'" % name
  end

  # Returns a list of Path objects
  def paths_from(point)
    Array.new @points[point]	  
  end

  def size 
    @points.size
  end    

  def points
    Array.new @points.keys
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
      row[2] = row[2].eql? "да" 
      @points[Point.new *row] = []
    end
    p "Loading paths..."
    CSV.foreach(routes_file) do |row|
      next if row[0][1] == "#"    
      row.map!{|value| value.strip if value}
      point = find_by_name(row[0])
      @points[point] << Path.new(point, find_by_name(row[1]), row[2].to_i, row[3])
    end
    p "Data loaded!"
  end

  def populate_implicit_paths
    for point in @points.keys
      paths_for_point = Array.new @points[point]
      to_add = []
      paths.each {|path| to_add << 
  	 Path.new(path.finish, path.start, path.hours, path.comments) \
  		 if path.finish.eql? point \
          	         and not paths_for_point.detect {|declared| declared.start.eql? path.finish \
               					        		and declared.finish.eql? path.start }}
      @points[point] = paths_for_point + to_add
     end 
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
    ["хижа", "заслон"].include? @type
  end

  def inspect
    "Point region: %s, name: %s, starting point: %s, altitude: %s, coordinates: %s" \
    	% [@region, @name, @starting_point, @altitude, @coordinates]
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
  
  def inspect 
    "Path start: %s finish: %s, hours: %s\n" % [start.name, finish.name, hours.to_s]
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
