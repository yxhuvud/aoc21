def step(pairs, rules)
  counts = Hash(Tuple(Char, Char), Int64).new(0)
  pairs.each do |pair, c|
    rules[pair].each { |p| counts[p] += c }
  end
  counts
end

def solve(pairs, rules, n, first, last)
  n.times { pairs = step(pairs, rules) }

  counts = Hash(Char, Int64).new(0)
  counts[first] = counts[last] = 1
  pairs.each do |(c1, c2), v|
    counts[c1] += v
    counts[c2] += v
  end

  (counts.values.max - counts.values.min) // 2
end

inputs = File.read("input.day14").lines
start = inputs.shift.chars
pairs = start.each_cons(2).map { |cs| {cs[0], cs[1]} }.tally
first, last = start[0], start[-1]

inputs.shift

rules = inputs.map(&.split(" -> ")).to_h do |vs|
  cs = vs[0].chars
  { {cs[0], cs[1]}, { {cs[0], vs[1][0]}, {vs[1][0], cs[1]} } }
end

p solve(pairs, rules, 10, first, last)
p solve(pairs, rules, 40, first, last)
