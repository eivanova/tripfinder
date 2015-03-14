require_relative 'tripfinder'

network = Network.new("../datasets/points.txt", "../datasets/routes.txt")
finder = Finder.new network

