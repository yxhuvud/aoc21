require "bit_array"
require "./priority_queue"

inputs = File.read("input.day15").lines

map = inputs.map &.each_char.map(&.to_i8).to_a

record(Pos, x : Int16, y : Int16) do
  def neighbours
    {
      Pos.new(x + 1, y),
      Pos.new(x - 1, y),
      Pos.new(x, y + 1),
      Pos.new(x, y - 1),
    }
  end

  def val(map)
    val = map[x % map.size][y % map[0].size].to_i8 + x // map.size + y // map[0].size
    val > 9 ? val - 9 : val
  end

  def visited?(ba, xz)
    ba[xz * x + y]
  end

  def visit(ba, xz)
    ba[xz * x + y] = true
  end
end

def find(map, max_x, max_y)
  p = Pos.new(0, 0)
  target = Pos.new(max_x.to_i16, max_y.to_i16)
  queue = PriorityQueue(Int16, Tuple(Pos, Int16)).new
  queue.insert({p, 0i16}, 0i16)
  ba = BitArray.new((max_x + 1) * (max_y + 1))
  while t = queue.pull
    p, score = t
    break if p == target

    p.neighbours.each do |n|
      next if n.x < 0 || n.x > max_x || n.y < 0 || n.y > max_y ||
              n.visited?(ba, max_x + 1)

      n.visit(ba, max_x + 1)
      cost = score + n.val(map)
      queue.insert({n, cost}, cost)
    end
  end
  score
end

puts "part 1: %s" % find(map, map.size - 1, map[0].size - 1)
puts "part 2: %s" % find(map, 5 * map.size - 1, 5 * map[0].size - 1)
