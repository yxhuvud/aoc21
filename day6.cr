inputs = File.read("input.day6").split(',').map(&.to_i8)

def solve(n, inputs)
  by_day = inputs.tally.transform_values { |v| v.to_i64 }
  n.times do |i|
    by_day = by_day.transform_keys { |k| k -= 1 }
    by_day[6] ||= 0i64
    by_day[8] = by_day[-1]? || 0i64
    by_day[6] += by_day.delete(-1) || 0
  end
  by_day.values.sum
end

puts "part1: #{solve(80, inputs)}"
puts "part2: #{solve(256, inputs)}"

