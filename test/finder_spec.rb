require_relative '../lib/tripfinder'

describe Finder do
  before do
    network = Network.new("test/points_small.txt", "test/routes_small.txt")
    @finder = Finder.new(network)
  end

  describe "#find" do
    it "should return prioritized list of routes" do
      params = {:days => 1 , :hours => 6, :cyclic => false}
      routes = @finder.find(params)
      expect(routes).not_to be nil
      expect(routes.size).to be 5
      expect(routes.first[0].avg_hours).to be > 0
    end

    it "should respond to strig parameters" do
      params = {:days=> "1", :hours=> "6"}
      routes = @finder.find(params)
      expect(routes).not_to be nil
      expect(routes.size).to be 5
    end

    it "should return cyclic routes when requested" do
      params = {:days => 2, :hours => 6, :cyclic => true}
      routes = @finder.find(params)
      expect(routes.all? { |route| route[0].cyclic? }).to be true
    end
  end
end
