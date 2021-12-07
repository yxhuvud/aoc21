def register(map, x, y)
  (map[x][y] += 1i8) == 2i8
end

def solve(map, inputs, short_y)
  inputs.sum do |values|
    xs = values[0].to(values[2])
    ys = values[1].to(values[3])
    (short_y ? xs.zip(ys.cycle) : xs.cycle.zip(ys))
      .count { |x, y| register(map, x, y) }
  end
end

by_diff_dir = File.read("input.day5").strip
  .split(/ -> |,|\n/).map(&.to_i16)
  .each_slice(4)
  .group_by { |(x1, y1, x2, y2)| {x1 == x2, y1 == y2} }

map = Array(Array(Int8)).new(size: 1000) { Array(Int8).new(size: 1000) { 0i8 } }
orthogonal = solve(map, by_diff_dir[{true, false}], false) + solve(map, by_diff_dir[{false, true}], true)

puts "part1: #{orthogonal}"
puts "part2: %s" % (orthogonal + solve(map, by_diff_dir[{false, false}], false))
