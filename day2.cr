inputs = File.read_lines("input.day2")
  .map(&.split).map { |ss| {ss[0], ss[1].to_i} }

depth = 0
horizontal = 0

inputs.each do |command, amount|
  case command
  when "forward"
    horizontal += amount
  when "up"
    depth -= amount
  when "down"
    depth += amount
  end
end

puts "part1: %s" % (depth * horizontal)

horizontal = 0
depth = 0
aim = 0

inputs.each do |command, amount|
  case command
  when "forward"
    horizontal += amount
    depth += aim * amount
  when "up"
    aim -= amount
  when "down"
    aim += amount
  end
end

puts "part2: %s" % (depth * horizontal)
