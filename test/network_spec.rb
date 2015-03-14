require_relative '../src/tripfinder'

describe Network do
  before do
    @network = Network.new("test/points_small.txt", "test/routes_small.txt")
  end

  describe "#new" do
    it "loads the correct number of point from file" do
      @network.size == 4
    end
    
    it "should load expected points from file" do
      point = @network.find_by_name("хижа Безбог")
      expect(point).not_to be_nil
      expect(point).to be_instance_of Point
      expect(point.name).to eql "хижа Безбог"
      expect(point.region).to eql "Пирин"
      expect(point.starting_point).to eql "не"
      expect(point.coordinates).to eql "41.73434 23.52475"
      expect(point.altitude).to eql "2236"
      expect(point.type).to eql "хижа"
      expect(point.comments).to be_empty 
    end
  end
end
