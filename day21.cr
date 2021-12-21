def ev(v, p, s)
  p += v
  if p > 10
    p %= 10
    p = 10 if p == 0
  end
  s += p
  {p, s}
end

input = File.read("input.day21").lines
start1 = input.shift.split.last.to_i
start2 = input.shift.split.last.to_i

# dice = 1.to(100).cycle
# pawns = [start1, start2]
# scores = [0, 0]
# current = 0
# rolled = 0
# loop do
#   v = 3.times.sum { dice.next.as(Int32) }
#   pawns[current], scores[current] = ev(v, pawns[current], scores[current])
#   rolled += 3
#   break if scores[current] >= 1000
#   current = 1 - current
# end
# puts "part 1: %s" % (scores.min * rolled)

pawns = [start1, start2]
p pawns
states = { { start1, start2, 0, 0} => 1i64 }
current = 0
wins = [0i64, 0i64]
keys = [] of typeof(states.keys.first)
while states.any?
  newstate = typeof(states).new
  {3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}.each do |v, multiplier|
    states.each do |key, count|
      key =
        if current == 0
          pnew, snew = ev(v, key[0], key[2])
          {pnew, key[1], snew, key[3]}
        else
          pnew, snew = ev(v, key[1], key[3])
          {key[0], pnew, key[2], snew}
        end
      newstate[key] ||= 0i64
      newstate[key] += count * multiplier

      #      ps[current], ss[current] = ev(v, ps[current], ss[current])
    end
  end
  # states.keys.each do |k|
  #   keys << k
  # end
  states = newstate
  states.reject! { |key, count| key[2 + current] >= 21 && (wins[current] += count) }
  current = 1 - current
end

p keys.size
p keys.uniq.size

puts "part 2: %s" % wins.max
