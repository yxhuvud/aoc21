alias Cube = Tuple(Range(Int32, Int32), Range(Int32, Int32), Range(Int32, Int32))

def intersect(a, b)
  intersection = {0, 1, 2}.map do |i|
    ({a[i], b[i]}.max_of(&.begin)..{a[i], b[i]}.min_of(&.end))
      .tap { |r| return if r.begin > r.end }
  end
end

def solve(ranges)
  cubes = Hash(Cube, Int64).new(0i64)
  ranges.each do |on, cube|
    cubes.each do |c, v|
      next if v == 0

      if intersection = intersect(cube, c)
        cubes[intersection] += vol(intersection, v < 0)
      end
    end
    cubes[cube] += vol(cube, on) if on
  end
  cubes.sum &.last
end

def vol(cube, on)
  xs, ys, zs = cube
  v = (xs.end.to_i64 - xs.begin + 1) * (ys.end - ys.begin + 1) * (zs.end - zs.begin + 1)
  on ? v : -v
end

input = File.read("input.day22").lines
ranges = input.map do |line|
  matches = /x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/.match(line).not_nil!
  on = !!line[/on/]?
  {on, {matches[1].to_i..matches[2].to_i, matches[3].to_i..matches[4].to_i, matches[5].to_i..matches[6].to_i}}
end

init_ranges = ranges.select { |_, cube| intersect(cube, {-50..50, -50..50, -50..50}) }

puts "part 1: #{solve(init_ranges)}"
puts "part 2: #{solve(ranges)}"
