require_relative '../src/tripfinder'

describe Network do
  before do
    @network = Network.new("test/points_small.txt", "test/routes_small.txt")
  end

  describe "#new" do
    it "should load the correct number of point from file" do
      @network.size == 4
    end
    
    it "should load expected points from file" do
      point = @network.find_by_name("хижа Безбог")
      expect(point).not_to be_nil
      expect(point).to be_instance_of Point
      expect(point.name).to eql "хижа Безбог"
      expect(point.region).to eql "Пирин"
      expect(point.starting_point).to eql false 
      expect(point.coordinates).to eql "41.73434 23.52475"
      expect(point.altitude).to eql "2236"
      expect(point.type).to eql "хижа"
      expect(point.comments).to be_empty 
    end
  end
end

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
      expect(routes.size).to be 4 
    end
  end
end
