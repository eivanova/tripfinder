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
 
  def eql?(other)
    @start.eql? other.start and @finish.eql? other.finish and @hours.eql? other.hours and @comments.eql? other.comments	  
  end 

  def hash
    [@start, @finish, @hours, @comments].hash
  end

  def inspect 
    "Path start: %s finish: %s, hours: %s\n" % [start.name, finish.name, hours.to_s]
  end
end

class Route

  def initialize
    # route is represented by an array of arrays, where each inner array represnets a day. 
    # Thus a day is represented by an array of Path objects
    @route = []	  
  end

  def initialize(routes)
    # TODO some validation for {routes}
    @route = routes
  end
  
  def days_count()
    @route.size
  end

end

class RouteBuilder

  attr_reader :hours_per_day, :days_left, :cyclic

  def initialize(*args)
    if args[0].is_a? RouteBuilder
      create_from_builder(args[0])
    else
      create_empty(args[0], args[1], args[2])	   
    end 
  end

  def new_route
    RouteBuilder.new(self)
  end

  def add_path(path)
    @route << [path] 
    @days_left = @route.last && @route.last.last.finish.sleep_over? ? @days_left - 1 : @days_left
    balance_route
    [route_qualifies?, self]
  end

  def contains_path(path)
    @route.flatten.detect {|added| added.eql? path} ? true : false
  end

  def build
    Route.new @route
  end

  def current_route
    Array.new @route	  
  end

  def finish
    @route.last.last.finish	  
  end
  
  :private
  
  def create_empty(hours, days, cyclic)
    @route = []	  
    @hours_per_day = hours
    @days_left = days
    @cyclic = cyclic    
  end

  def create_from_builder(route)
    @route = route.current_route.map {|day| Array.new day} 
    @hours_per_day = route.hours_per_day
    @days_left = route.days_left
    @cyclic = route.cyclic
  end
  
  # Relies that there is only one series of paths to merge and it is in the end of the "route" array. Also
  # all paths before that segment are less than the expected number of hours.
  # Returns true if route is complete and qualifies, 1 if route is not complete but still could qualify and
  # -1 if route does not qualify. Keeps the route compact in terms of hours per day and sleeping poins.
  def balance_route
    # compact the route     
    non_sleepover_index = @route.index {|day| not day.last.finish.sleep_over?}
    if non_sleepover_index == 0
      @route = [@route.flatten]       
    elsif non_sleepover_index != nil and non_sleepover_index > 0
      to_merge = @route.slice(non_sleepover_index, @route.size - 1)
      @route.slice!(non_sleepover_index, @route.size - 1)
      @route << to_merge.flatten unless to_merge.empty?
    end
  end

  def route_qualifies?  
    return -1 if @days_left < 0
    # verify hours of compacted
    return -1 if @route.last.collect{|path| path.hours}.inject{|sum, hours| sum + hours} >= @hours_per_day
    # still more days to come
    return 1 if @days_left > 0
    # days are now 0 for sure, so check for cyclic route
    return -1 if @cyclic and not @route.first.first.start.eq? @route.last.last.finish
    return 1 if not @route.last.last.finish.sleep_over?
    # 0 days, all is fine
    @route.last.last.finish.starting_point ? true : -1 
  end
  
end
