require "./priority_queue"
alias Pod = Tuple(Int8, Int8, Char)

def goal?(state)
  pods, _ = state
  pods.empty?
end

def estimate(pods : Array(Pod))
  a = b = c = d = 0
  s = pods.sum do |pod|
    case pod[2]
    when 'A'
      a += 1
      dy = (pod[1] - 3).abs
      dx = dy > 0 ? pod[0] : 0
      (a - 1 + dx + dy)
    when 'B'
      b += 1
      dy = (pod[1] - 5).abs
      dx = dy > 0 ? pod[0] : 0
      (b - 1 + dx + dy) * 10
    when 'C'
      c += 1
      dy = (pod[1] - 7).abs
      dx = dy > 0 ? pod[0] : 0
      (c - 1 + dx + dy) * 100
    when 'D'
      d += 1
      dy = (pod[1] - 9).abs
      dx = dy > 0 ? pod[0] : 0
      (d - 1 + dx + dy) * 1000
    else raise "wtf"
    end
  end
end

def in_hallway?(pod)
  pod.first == 1
end

def valid_hallway_positions(pods, pod)
  return if pods.any? { |p| p[1] == pod[1] && p[0] < pod[0] }

  {1i8, 2i8, 4i8, 6i8, 8i8, 10i8, 11i8}.each do |dest_column|
    range = pod[1] < dest_column ? (pod[1] + 1)..dest_column : dest_column...pod[1]
    next if pods.any? { |p| in_hallway?(p) && range.includes?(p[1]) }
    yield(1i8, dest_column)
  end
end

def dist(x, y, xnew, ynew)
  (xnew - x).abs + (ynew - y).abs
end

def cost(c, dist)
  case c
  when 'A' then 1 * dist
  when 'B' then 10 * dist
  when 'C' then 100 * dist
  when 'D' then 1000 * dist
  else          raise "wtf"
  end
end

def dest_column(pod)
  x, y, c = pod
  case c
  when 'A' then 3i8
  when 'B' then 5i8
  when 'C' then 7i8
  when 'D' then 9i8
  else          raise "hfud"
  end
end

def find_valid_dest_position(pods, pod)
  dest_column = dest_column(pod)
  range = pod[1] > dest_column ? dest_column...pod[1] : (pod[1] + 1)..dest_column
  return if pods.any? { |p| in_hallway?(p) && range.includes?(p[1]) || p[1] == dest_column }
  count = pods.count { |p| p[2] == pod[2] }
  yield(count.to_i8 + 1, dest_column)
end

def neighbours(state)
  pods, cost = state
  pods.each_with_index do |(x, y, c), i|
    pod = {x, y, c}
    if in_hallway?(pod)
      find_valid_dest_position(pods, pod) do |xnew, ynew|
        distance = dist(x, y, xnew, ynew)
        new_pods = pods.dup
        new_pods.delete_at(i)
        newcost = cost + cost(c, distance)
        yield({new_pods, newcost, estimate(new_pods)})
      end
    else
      valid_hallway_positions(pods, pod) do |xnew, ynew|
        new_pods = pods.dup
        distance = dist(x, y, xnew, ynew)
        new_pods[i] = {xnew, ynew, c}
        newcost = cost + cost(c, distance)
        yield(new_pods.sort!, newcost, newcost + estimate(new_pods))
      end
    end
  end
end

def read_pods(chars)
  pods = Array(Pod).new
  chars.each_with_index do |r, x|
    r.each_with_index do |c, y|
      pods << {x.to_i8, y.to_i8, c} if c.in?('A', 'B', 'C', 'D')
    end
  end
  pods
end

def solve(pods)
  queue = PriorityQueue(Int32, Tuple(Array(Pod), Int32)).new
  queue.insert({pods.sort!, 0}, estimate(pods))
  seen = Set(Array(Pod)).new
  while state = queue.pull
    last = state
    break if goal?(state)

    neighbours(state) do |pods, cost, estimate|
      next if seen.includes?(pods)
      seen << pods
      queue.insert({pods, cost}, estimate)
    end
  end
  last[1] if last
end

input = File.read("input.day23")
chars = input.lines.map(&.chars)
part1 = read_pods(chars)
chars = chars[0..2] + [
  "  #D#C#B#A#".chars,
  "  #D#B#A#C#".chars,
] + chars[3..]
part2 = read_pods(chars)

puts "part 1: #{solve(part1)}"
puts "part 2: #{solve(part2)}"
