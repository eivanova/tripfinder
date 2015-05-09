require_relative '../lib/tripfinder'

describe Network do
  before do
    TripfinderGem.configure({:points => "test/points_small.txt", :routes =>"test/routes_small.txt"})	  
    @network = Network.new #("test/points_small.txt", "test/routes_small.txt")
  end

  describe "#new" do
    it "should load the correct number of point from file" do
      expect(@network.size).to eql 4
    end
    
    it "should load expected points from file" do
      point = @network.find_by_name("хижа Безбог")
      expect(point).not_to be_nil
      expect(point).to be_instance_of Point
      expect(point.name).to eql "хижа Безбог"
      expect(point.region).to eql "Пирин"
      expect(point.starting_point).to eql true 
      expect(point.coordinates).to eql "41.73434 23.52475"
      expect(point.altitude).to eql "2236"
      expect(point.type).to eql "хижа"
      expect(point.comments).to be_empty 
    end
  end

  describe "#paths_from" do
    it "should return a collection of defined and implicit reverse paths" do
      point = @network.find_by_name("връх Безбог")
      paths = @network.paths_from(point)
      expect(paths.size).to eql 2 
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
      expect(routes.size).to be 5 
    end
  end
end
