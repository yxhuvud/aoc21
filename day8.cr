inputs = File.read("input.day8").lines.map(&.split('|').map(&.split))

p1 = inputs.sum &.last.count(&.size.in?(2, 4, 3, 7))
puts "part1: #{p1}"

def chose(all, size)
  all.find { |s| s.size == size && yield(s) }.not_nil!
end

def all?(lookup, num, chars)
  lookup[num].all? { |c| chars.includes?(c) }
end

lookup = Array(Array(Char)).new(10) { Array(Char).new }
p2 = inputs.sum do |is|
  ins, os = is[0], is[1]
  all = ins.map &.chars.sort

  lookup[1] = chose(all, 2) { true }
  lookup[4] = chose(all, 4) { true }
  lookup[7] = chose(all, 3) { true }
  lookup[8] = chose(all, 7) { true }
  lookup[9] = chose(all, 6) { |s| all?(lookup, 4, s) }
  lookup[0] = chose(all, 6) { |s| all?(lookup, 7, s) && s != lookup[9] }
  lookup[6] = chose(all, 6) { |s| !s.in?(lookup[9], lookup[0]) }
  lookup[3] = chose(all, 5) { |s| all?(lookup, 1, s) }
  lookup[5] = chose(all, 5) { |s| s.all? { |ls| lookup[6].includes?(ls) } }
  lookup[2] = chose(all, 5) { |s| !s.in?(lookup[3], lookup[5]) }

  os.reduce(0) do |acc, v|
    10 * acc + lookup.index(v.chars.sort).not_nil!
  end
end

puts "part2: #{p2}"
