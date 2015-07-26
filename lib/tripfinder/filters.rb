class Filter

  def apply_mask(network, mask, params = {})
    raise NoMethodError("Filter classes must implement method apply_mask(network, mask, params)")
  end
end

class LocationFilter < Filter

  def initialize
    @weight_match = 1
    @weight_mismatch = 0.01
  end

  def apply_mask(network, mask, params = {})
    return mask if params[:region].to_s == '' and params[:place].to_s == ''

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
    region_eql = params[:region].to_s.strip.length > 0 and point.region.eql? params[:region]
    place_eql = params[:place].to_s.strip.length > 0 and point.name.eql? params[:place]
    region_eql or place_eql
  end
end

# Applicable to Path objects only, because it uses elevation in the heuristic.
class DifficultyFilter < Filter

  def initialize
    @difficulty_scale = 10
  end

  def apply_mask(network, mask, params = {})
    return mask if params[:difficulty].to_s == ''
    for path in network.paths
      desired_difficulty = params[:difficulty]
      difference = (path.start.altitude - path.finish.altitude).abs
      avg_elevation = difference / 2
      path_difficulty = (1 - 1 / (avg_elevation * difference)) * @difficulty_scale
      # smaller coef makes for a bigger value in the mask
      coef = 1 - 1 / (path_difficulty - desired_difficulty).abs
      mask[path] = calc_new_weight(mask[path], coef)
    end
  end


  :private

  def calc_new_weight(old, coef)
    old ? old * coef : coef
  end
end
