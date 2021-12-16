require "bit_array"

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

class FrontQueue(T)
  def initialize(front_width : Int32)
    @size = 0
    @current = 0i32
    @front = Deque(Array(T)).new(front_width) { Array(T).new }
    @bucket_count = front_width
  end

  def pull : T?
    return nil if @size == 0

    @size -= 1
    until !@front[0].empty?
      @current += 1
      @front.rotate! 1
    end
    @front[0].pop
  end

  def insert(value : T, prio : Int32)
    @size += 1
    offset = prio - @current
    raise "size issue #{@current}, #{prio}, #{@bucket_count}" if offset > @bucket_count - 2 || offset <= 0
    @front[offset].push value
  end
end

def find(map, max_x, max_y)
  p = Pos.new(0, 0)
  target = Pos.new(max_x.to_i16, max_y.to_i16)
  queue = FrontQueue(Tuple(Pos, Int16)).new(11)
  queue.insert({p, 0i16}, 1i16)
  ba = BitArray.new((max_x + 1) * (max_y + 1))
  while t = queue.pull
    p, score = t
    break if p == target

    p.neighbours.each do |n|
      next if n.x < 0 || n.x > max_x || n.y < 0 || n.y > max_y ||
              n.visited?(ba, max_x + 1)

      n.visit(ba, max_x + 1)
      cost = score + n.val(map)
      queue.insert({n, cost}, cost.to_i32)
    end
  end
  score
end

inputs = File.read("input.day15").lines
map = inputs.map &.each_char.map(&.to_i8).to_a

puts "part 1: %s" % find(map, map.size - 1, map[0].size - 1)
puts "part 2: %s" % find(map, 5 * map.size - 1, 5 * map[0].size - 1)
