map = File.read("input.day9")
  .lines.map(&.chars.map(&.to_i8))

record(Pos, x : Int8, y : Int8) do
  def neighbours
    {
      Pos.new(x, y + 1), Pos.new(x + 1, y),
      Pos.new(x, y - 1), Pos.new(x - 1, y),
    }
  end

  def above_threshold?(map, v)
    x < 0 || x >= map.size || y < 0 || y >= map[0].size ||
      map[x][y] > v
  end
end

min_points = 0.to(map.size - 1).flat_map do |x|
  0.to(map[0].size - 1)
    .map { |y| Pos.new(x.to_i8, y.to_i8) }
    .select { |p| p.neighbours.all? &.above_threshold?(map, map[p.x][p.y]) }
end.to_a

puts "part1: #{min_points.sum(0) { |p| map[p.x][p.y] } + min_points.size}"

queue = Deque(Pos).new
seen = Set(Pos).new
val = min_points.map do |p|
  seen.clear
  seen << p
  queue << p
  while p = queue.pop?
    p.neighbours.each do |n|
      next if n.above_threshold?(map, 8) || seen.includes?(n)
      queue << n unless seen.includes?(n)
      seen << n
    end
  end
  seen.size
end
  .sort.last(3).product

puts "part2: #{val}"
