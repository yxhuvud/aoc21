def find
  min = (0..2000).bsearch { |i| yield(i) < yield(i + 1) }
  yield(min) if min
end

def calc(inputs, i)
  inputs.sum { |input| (input - i).abs }
end

def calc2(inputs, i)
  inputs.sum { |input| cost((input - i).abs) }
end

def cost(n)
  n * (n + 1) // 2
end

inputs = File.read("input.day7").split(',').map(&.to_i)
puts "part1: #{find { |i| calc(inputs, i) }}"
puts "part2: #{find { |i| calc2(inputs, i) }}"
