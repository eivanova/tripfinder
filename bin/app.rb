require_relative 'tripfinder'
require_relative 'config'

TripfinderGem.configure({:points => "../datasets/points.txt", :routes => "../datasets/routes.txt"})
network = Network.new
finder = Finder.new network

