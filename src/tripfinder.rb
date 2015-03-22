require_relative 'domain'

class Finder
  
  def initialize(network)
    @network = network
    @chain = initialize_chain()
  end

  def initialize_chain
    require_relative 'filters' 
    chain = []
    chain.add(LocationFilter.new)
    chain
  end

  # search happens by two types of characteristics - those of single 
  # point/path, which are handled by the chain of filters by applying 
  # weight masks; and those of route construction, like number of days,
  # lenght of each day, etc... Those are handled by the collect_routes
  # method
  def find(params)
    mask = init_mask
    for filter in chain
      mask = chain.apply_mask(@network, mask, params)	    
    end

    collect_routes(mask, params)
  end

  :private

  def collect_routes(mask, params)
    routes = []
    mask = mask.sort_by{|point, weight| weight}
    starting_points = @network.point.select { |point| point.starting_point }

    # TODO some basic search - for each starting point, see if we can get to
    # a starting point again in the necessary nember of hops. If yes, save the 
    # route to routes; if not - proceed to the next starting point. This could be
    # slow, will see and optimise if necessary.
    
    # TODO do the search for the top n points only? What if we have had a filter
    # for region, do we still search points from other regions? My guess for now
    # is yes 

    params[:days]
    params[:hours]
    routes    
  end

  def init_mask
    mask = @network.keys.collect{|point| [point, 1]}.to_h
    mask.merge!(@network.paths.collect {|path| [path, 1]}.to_h)
    mask
  end
end

