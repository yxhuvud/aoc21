def find(inputs, n)
  inputs
    .each_cons(n, reuse: true)
    .count { |x| x[0] < x[n - 1] }
end

inputs = File
  .read("input.day1")
  .split
  .map(&.to_i)

puts "part1: %s" % find(inputs, 2)
puts "part2: %s" % find(inputs, 4)
