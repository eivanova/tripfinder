require_relative 'domain'

class Finder
  
  def initialize(network)
    @network = network
    @chain = initialize_chain()
  end

  def initialize_chain
    require_relative 'filters' 
    chain = []
    chain << LocationFilter.new
    chain
  end

  # search happens by two types of characteristics - those of single 
  # point/path, which are handled by the chain of filters by applying 
  # weight masks; and those of route construction, like number of days,
  # lenght of each day, etc... Those are handled by the collect_routes
  # method
  def find(params)
    mask = init_mask
    for filter in @chain
      mask = filter.apply_mask(@network, mask, params)	    
    end

    collect_routes(mask, params)
  end

  :private

  def collect_routes(mask, params)
    routes = {}
    mask = mask.sort_by{|point, weight| weight}.to_h
    starting_points = @network.points.select { |point| point.starting_point }
    # TODO do the search for the top n points only? What if we have had a filter
    # for region, do we still search points from other regions? My guess for now
    # is yes 

    # A basic search - for each starting point, see if we can get to
    # a starting point again in the necessary number of hops. If yes, save the 
    # route to routes; if not - proceed to the next starting point. This could be
    # slow, will see and optimise if necessary.
    for start  in starting_points
      routes.merge! get_weighted_routes(start, params, mask)    
    end

    routes    
  end

  # Get the routes starting at start and adhering the paramteres in params.
  # Mask contains the weights for different points and paths.
  # Routes contains the result and current_route is the route we are exploring currently
  def get_weighted_routes(start, params, mask)
    routes = {}
    current_route = []
    current_weight = 0.1
    weighted_routes(start, routes, current_route, current_weight, params[:hours], params[:days], params[:cyclic], mask) 
  end

  def weighted_routes(start, routes, current_route, current_weight, hours, days, cyclic, mask)
    for path in @network.paths_from(start)
      next if path.hours > hours 
      
      current_route << [path]
      current_weight *= mask[path]
      done = balance_route(current_route, hours, days, cyclic)
      if done == true	      
        routes[current_route] = current_weight
      elsif done == 1 
        days_left = current_route.last.last.finish.sleep_over? ? days - 1 : days
        start = current_route.last.last.finish
        weighted_routes(start, routes, current_route, current_weight, hours, days_left, cyclic, mask)
      end
    end
    routes
  end

  # Relies that there is only one series of paths to merge and it is in the end of the "route" array. Also
  # all paths before that segment are less than the expected number of hours.
  # Returns true if route is complete and qualifies, 1 if route is not complete but still could qualify and
  # -1 if route does not qualify. Keeps the route compact in terms of hours per day and sleeping poins.
  def balance_route(route, hours, days, cyclic)
    return -1 if days < 0
    # compact the route	    
    non_sleepover_index = route.index {|day| not day.last.finish.sleep_over?}
    if non_sleepover_index == 0
      route = [route.flatten]	    
    elsif non_sleepover_idex > 0
      to_merge = route.slice(non_sleepover_index, route.size - 1)
      route.slice!(0..non_sleepover_index - 1)
      route << to_merge.flatten unless to_merge.empty?
    end
    # verify hours of compacted
    return -1 if route.last.collect{|path| path.hours}.inject{|sum, hours| sum + hours}  > hours
    # still more days to come
    return 1 if days > 0
    # days are now 0 for sure, so check for cyclic route
    return -1 if cyclic and not route.first.first.start.eq? route.last.last.finish
    return 1 if not route.last.last.finish.sleep_over?
    # 0 days, all is fine
    true
  end

  def init_mask
    mask = @network.points.collect{|point| [point, 1]}.to_h
    mask.merge!(@network.paths.collect {|path| [path, 1]}.to_h)
    mask
  end
end

