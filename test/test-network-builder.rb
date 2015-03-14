require_relative '../src/tripfinder'

describe Network do
  before do
    @network = Network.new("datasets/points.txt", "datasets/routes.txt")
  end

  describe "#new" do
    it "loads all data in files" do
          
    end
  end
end
