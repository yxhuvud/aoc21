record(Pos, x : Int8, y : Int8) do
  def neighbours
    {
      Pos.new(x, y + 1), Pos.new(x + 1, y),
      Pos.new(x, y - 1), Pos.new(x - 1, y),

      Pos.new(x + 1, y + 1), Pos.new(x - 1, y - 1),
      Pos.new(x + 1, y - 1), Pos.new(x - 1, y + 1),
    }
  end

  def increment?(map)
    return unless x >= 0 && x < 10 && y >= 0 && y < 10
    map[x][y] += 1
    map[x][y] > 9
  end
end

def step(map)
  flashes = 0
  to_flash = Deque(Pos).new
  flashed = Set(Pos).new
  0.to(map.size - 1).each do |x|
    0.to(map[0].size - 1).each do |y|
      p = Pos.new(x.to_i8, y.to_i8)
      if p.increment?(map)
        to_flash << p
        flashed << p
      end
    end
  end

  while p = to_flash.pop?
    p.neighbours.each do |n|
      if n.increment?(map)
        next if flashed.includes?(n)
        to_flash << n
        flashed << n
      end
    end
  end
  flashed.each { |s| map[s.x][s.y] = 0 }
  flashed.size
end

map = File.read("input.day11").lines.map &.chars.map(&.to_i8)
puts "part 1: %s" % 100.times.sum { step(map) }
puts "part2: %s" % (101..).find { |i| step(map) == 100 }
