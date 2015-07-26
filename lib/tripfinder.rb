require 'tripfinder/domain'
require 'tripfinder/filters'
require 'chatbot/eliza'

class Finder

  def initialize(network)
    @network = network
    @chain = initialize_chain()
  end

  def initialize_chain
    chain = []
    chain << LocationFilter.new
    chain << DifficultyFilter.new
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
    starting_points = mask.keys.select { |point| point.kind_of? Point and point.starting_point }
    # TODO do the search for the top n points only? What if we have had a filter
    # for region, do we still search points from other regions? My guess for now
    # is yes

    # A basic search - for each starting point, see if we can get to
    # a starting point again in the necessary number of hops. If yes, save the
    # route to routes; if not - proceed to the next starting point. This could be
    # slow, will see and optimise if necessary.
    for start in starting_points
      weighted = get_weighted_routes(start, params, mask)
      routes.merge! weighted
    end

    routes
  end

  # Get the routes starting at start and adhering the paramteres in params.
  # Mask contains the weights for different points and paths.
  # Routes contains the result and current_route is the route we are exploring currently
  def get_weighted_routes(start, params, mask)
    routes = {}
    current_route = RouteBuilder.new(params[:hours].to_i, params[:days].to_i, params[:cyclic])
    current_weight = 0.1
    weighted_routes(start, routes, current_route, current_weight, mask)
    routes
  end

  def weighted_routes(start, routes, current_route, current_weight, mask)
    return routes if routes.count > 10

    network_paths = @network.paths_from(start)
    sorted_paths = mask.keys.select {|path| path.kind_of? Path and network_paths.include? path}
    for path in @network.paths_from(start)
      next if path.hours > current_route.max_hours or current_route.contains_path path
      this_route = current_route.new_route
      this_weight = current_weight * mask[path]
      done, this_route = this_route.add_path path
      if done == true
        routes[this_route.build] = this_weight
      elsif done == 1
        start = this_route.finish
        weighted_routes(start, routes, this_route, this_weight, mask)
      end
    end
    routes
  end

  def init_mask
    mask = @network.points.collect{|point| [point, 1]}.to_h
    mask.merge!(@network.paths.collect {|path| [path, 1]}.to_h)
    mask
  end
end

