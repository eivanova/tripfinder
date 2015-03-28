class LocationFilter
  
  def initialize
    @weight_match = 1
    @weight_mismatch = 0.01
  end

  def apply_mask(network, mask, params = {})
    for point in network.points
      coef = matches?(point, params) ? @weight_match : @weight_mismatch
      mask[point] = calc_new_weight(mask[point], coef) 
    end
    mask
  end	  

  :private

  def calc_new_weight(old, coef)
    old ? old * coef : coef
  end

  def matches?(point, params)
    point.region.eql? params[:region] or point.name.eql? params[:place]
  end  
end
