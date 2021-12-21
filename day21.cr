def step(v, p, s)
  p += v
  if p > 10
    p %= 10
    p = 10 if p == 0
  end
  s += p
  {p, s}
end

def new_key(key, v, current)
  if current == 0
    pnew, snew = step(v, key[0], key[2])
    {pnew.to_i8, key[1], snew, key[3]}
  else
    pnew, snew = step(v, key[1], key[3])
    {key[0], pnew.to_i8, key[2], snew}
  end
end

input = File.read("input.day21").lines
start1 = input.shift.split.last.to_i
start2 = input.shift.split.last.to_i

dice = 1.to(100).cycle
pawns = [start1, start2]
scores = [0, 0]
current = 0
rolled = 0
loop do
  v = 3.times.sum { dice.next.as(Int32) }
  pawns[current], scores[current] = step(v, pawns[current], scores[current])
  rolled += 3
  break if scores[current] >= 1000
  current = 1 - current
end
puts "part 1: %s" % (scores.min * rolled)

states = Hash(Tuple(Int8, Int8, Int8, Int8), Int64).new(0)
states[{start1.to_i8, start2.to_i8, 0i8, 0i8}] = 1i64
newstate = Hash(Tuple(Int8, Int8, Int8, Int8), Int64).new(0)
current = 0
wins = [0i64, 0i64]
while states.any?
  {3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}.each do |v, multiplier|
    states.each do |key, count|
      key = new_key(key, v, current)
      (wins[current] += count * multiplier) && next if key[current + 2] > 20
      newstate[key] += count * multiplier
    end
  end
  states, newstate = newstate, states.clear
  current = 1 - current
end
puts "part 2: %s" % wins.max
