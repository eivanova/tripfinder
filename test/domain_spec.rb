require_relative '../lib/tripfinder'

describe Route do

  describe "#eql?" do
    it "should return true for equal routes" do
      # Paths for route1
      path11 = Path.new("start1", "finish1", 1)
      path21 = Path.new("start2", "finish2", 2)
      path31 = Path.new("start3", "finish3", 2)
      path41 = Path.new("start4", "finish4", 2)
      # Paths for route2
      path12 = Path.new("start1", "finish1", 1)
      path22 = Path.new("start2", "finish2", 2)
      path32 = Path.new("start3", "finish3", 2)
      path42 = Path.new("start4", "finish4", 2)

      route1 = Route.new([[path11, path21], [path31, path41]])
      route2 = Route.new([[path12, path22], [path32, path42]])

      expect(route1.eql? route2).to be true
    end

    it "should return false for different routes" do
      # Paths for route1
      path11 = Path.new("start1", "finish1", 1)
      path21 = Path.new("start2", "finish2", 2)
      path31 = Path.new("start3", "finish3", 2)
      path41 = Path.new("start4", "finish4", 2)
      # Paths for route2
      path12 = Path.new("start1", "finish1", 1)
      path22 = Path.new("start2", "finish2", 2)
      path32 = Path.new("start3", "finish3", 2)
      path42 = Path.new("start4", "finish4", 2)

      route1 = Route.new([[path11, path21], [path31, path41]])
      route2 = Route.new([[path12, path22], [path42, path32]])

      expect(route1.eql? route2).to be false
     end
  end

end

describe Path do

  describe "#eql?" do
    it "should return true for equal paths" do
      path1 = Path.new("start1", "finish1", 1)
      path2 = Path.new("start1", "finish1", 1)
      expect(path1.eql? path2).to be true
    end

    it "should return false for non-equal paths" do
      path1 = Path.new("start1", "finish1", 1)
      path2 = Path.new("start2", "finish2", 1)
      expect(path1.eql? path2).to be false
     end
  end

end

