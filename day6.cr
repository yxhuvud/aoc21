inputs = File.read("input.day6").split(',').map(&.to_i8)

def solve(n, inputs)
  deq = Deque(Int64).new(9) { 0i64 }
  inputs.each { |v| deq[v] += 1 }
  n.times do
    deq.rotate! 1
    deq[6] += deq[8]
  end
  deq.sum
end

puts "part1: #{solve(80, inputs)}"
puts "part2: #{solve(256, inputs)}"
