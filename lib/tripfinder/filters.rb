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

    for element in network.points + network.paths
      coef = matches?(element, params) ? @weight_match : @weight_mismatch
      mask[element] = calc_new_weight(mask[element], coef)
    end
    mask
  end

  :private

  def calc_new_weight(old, coef)
    old ? old * coef : coef
  end

  def matches?(element, params)
    region = params[:region].to_s.strip
    place = params[:place].to_s.strip
    if element.kind_of? Point
      region_eql = element.region.eql? region
      place_eql = element.name.eql? place
    else
      region_eql = element.start.region.eql?(region) or element.finish.region.eql?(region)
      place_eql = element.start.name.eql?(place) or element.finish.name.eql?(place)
    end
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
      desired_difficulty = params[:difficulty].to_f
      difference = (path.start.altitude - path.finish.altitude).abs + 1   # 1 meter is nothing, while this way we avoid division by 0
      avg_elevation = (path.start.altitude + path.finish.altitude) / 2
      path_difficulty = (@difficulty_scale - 1) / (avg_elevation * difference) + 1  # scaled [1, @difficulty_scale]
      difficulty_diff = (path_difficulty - desired_difficulty).abs
      # smaller coef makes for a bigger value in the mask
      coef = difficulty_diff == 0 ? 1 : difficulty_diff.to_f / @difficulty_scale
      mask[path] = calc_new_weight(mask[path], coef)
    end
    mask
  end


  :private

  def calc_new_weight(old, coef)
    old ? old * coef : coef
  end
end
