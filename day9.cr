map = File.read("input.day9")
  .lines.map(&.chars.map(&.to_i8))

def neighbours(p : Pos)
  {
    Pos.new(p.x, p.y + 1),
    Pos.new(p.x, p.y - 1),
    Pos.new(p.x + 1, p.y),
    Pos.new(p.x - 1, p.y),
  }
end

def above_threshold?(pos, map, v)
  pos.x < 0 || pos.x >= map.size || pos.y < 0 || pos.y >= map[0].size ||
    map[pos.x][pos.y] > v
end

record(Pos, x : Int32, y : Int32)

min_points = Array(Pos).new
map.each_with_index do |row, x|
  row.each_with_index do |v, y|
    if neighbours(Pos.new(x, y)).all? { |n| above_threshold?(n, map, v) }
      min_points << Pos.new(x, y)
    end
  end
end

puts "part1: #{min_points.sum(0) { |p| map[p.x][p.y] } + min_points.size}"

queue = Deque(Pos).new
seen = Set(Pos).new
val = min_points.map do |p|
  seen.clear
  seen << p
  queue << p
  while p = queue.pop?
    neighbours(p).each do |pp|
      next if above_threshold?(pp, map, 8) || seen.includes?(pp)
      queue << pp unless seen.includes?(pp)
      seen << pp
    end
  end
  seen.size
end
  .sort.last(3).product

puts "part2: #{val}"
