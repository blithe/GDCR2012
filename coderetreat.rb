require 'rspec'
require 'set'

class Space < Struct.new(:x, :y)
	def neighbors
		y_values = Range.new(y - 1, y + 1).to_a
		x_values = Range.new(x - 1, x + 1).to_a

		x_values.product(y_values).map { |x, y| Space.new(x, y) } - [Space.new(x, y)]
	end
end

class Universe
	attr_reader :occupied_spaces

	def initialize(occupied_spaces = [])
		@occupied_spaces = occupied_spaces
	end

	def occupy(space)
		@occupied_spaces << space
	end

	def occupied_by_living_thing?(space)
		@occupied_spaces.include?(space)
	end

	def occupied_neighbors(space)
		space.neighbors.select{ |neighbor| occupied_by_living_thing?(neighbor)}
	end

	def cells_that_will_die
		@occupied_spaces.select { |space| occupied_neighbors(space).count < 2 or occupied_neighbors(space).count > 3 }
	end

	def cells_that_will_be_born
		unoccupied_neighbors.select { |space| occupied_neighbors(space).count == 3 }
	end

	def unoccupied_neighbors
		Set.new(@occupied_spaces.map { |space| space.neighbors }.flatten) - @occupied_spaces
	end

	def to_s
		str = ""

		(-20).upto(20) { |y|
			(-20).upto(20) { |x|
				str << (occupied_by_living_thing?(Space.new(x, y)) ? "X" : " ")
			}

			str << "\n"
		}

		str
	end
end

class GameOfLife
	def self.play_turn(universe)
		Universe.new(universe.occupied_spaces - universe.cells_that_will_die + universe.cells_that_will_be_born)
	end
end

describe GameOfLife do
	it "kills cells that have less than two neighbors" do
		universe = Universe.new
		universe.occupy(Space.new(0, 0))
		universe.occupy(Space.new(0, 1))

		next_universe = GameOfLife.play_turn(universe)
		next_universe.occupied_by_living_thing?(Space.new(0, 0)).should_not be_true
		next_universe.occupied_by_living_thing?(Space.new(0, 1)).should_not be_true
	end

	it "allows cells with two or three neighbors to live" do
		universe = Universe.new
		universe.occupy(Space.new(0, 0))
		universe.occupy(Space.new(0, 1))
		universe.occupy(Space.new(0, 2))

		next_universe = GameOfLife.play_turn(universe)
		next_universe.occupied_by_living_thing?(Space.new(0, 1)).should be_true
	end

	it "kills cells that have more than three neighbors" do
		universe = Universe.new
		universe.occupy(Space.new(0, 0))
		universe.occupy(Space.new(0, 1))
		universe.occupy(Space.new(0, 2))
		universe.occupy(Space.new(1, 0))		
		universe.occupy(Space.new(1, 1)) # will die

		next_universe = GameOfLife.play_turn(universe)
		next_universe.occupied_by_living_thing?(Space.new(1, 1)).should_not be_true			
	end

	it "births cells that has exactly three neighbors" do
		universe = Universe.new
		universe.occupy(Space.new(0, 0))
		universe.occupy(Space.new(0, 1))
		universe.occupy(Space.new(0, 2))

		next_universe = GameOfLife.play_turn(universe)
		next_universe.occupied_by_living_thing?(Space.new(1, 1)).should be_true			
	end	
end	

describe Universe do
	it "can occupy spaces" do
		universe = Universe.new
		space = Space.new(0, 1)

		universe.occupy(space)
		universe.occupied_by_living_thing?(space).should be_true
	end

	it "finds occupied neighbors for a given space" do
		universe = Universe.new
		universe.occupy(Space.new(0, 0))
		universe.occupy(Space.new(0, 1))

		universe.occupied_neighbors(Space.new(1, 1)).should =~ [
			Space.new(0, 0),
			Space.new(0, 1)
		]
	end
end	

describe Space do
	it "knows its neighbors" do
		space = Space.new(1, 1)

		space.neighbors.should =~ [
			Space.new(0, 0),
			Space.new(1, 0),
			Space.new(2, 0),
			Space.new(0, 1),
			Space.new(2, 1),
			Space.new(0, 2),
			Space.new(1, 2),
			Space.new(2, 2)
		]
	end
end

universe = Universe.new
universe.occupy(Space.new(0, 0))
universe.occupy(Space.new(0, 1))
universe.occupy(Space.new(0, 2))

loop {
	puts universe.to_s
	universe = GameOfLife.play_turn(universe)
	sleep 2
}


