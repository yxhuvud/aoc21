require "bit_array"

inputs = File.read("input.day12").lines.map(&.split('-'))
paths = (inputs.map { |vs| [vs[0], vs[1]] } + inputs.map { |vs| [vs[1], vs[0]] })
  .group_by(&.first).transform_values(&.map(&.last))

index = paths.keys.each_with_index.to_h { |k, i| {k, i.to_i8} }
from, to = index["start"], index["end"]
neighbours = paths.values.map { |vs| vs.map { |v| index[v] } }

lowercase = BitArray.new(index.size)
paths.keys.each { |k| lowercase[index[k]] = k[0].lowercase? }

def queue_and_count(queue, counts, next_entry, value)
  queue << next_entry if counts[next_entry].zero?
  counts[next_entry] += value
end

def solve(paths, revisit, from, to, lowercase)
  visited = BitArray.new(paths.size).tap { |ba| ba[from] = true }
  working = Deque{ {from, visited, !revisit} }
  counts = Hash(Tuple(Int8, BitArray, Bool), Int32).new { 0 }
  counts[{from, visited, !revisit}] = 1

  while entry = working.shift?
    value = counts[entry]
    current, visited, twice = entry

    paths[current].each do |c|
      counts[{c, visited, revisit}] += value if c == to
      next if c.in?(from, to)
      if !twice && lowercase[c] && visited[c]
        queue_and_count(working, counts, {c, visited, true}, value)
      elsif lowercase[c] && !visited[c]
        queue_and_count(working, counts, {c, visited.dup.tap { |v| v[c] = true }, twice}, value)
      elsif !lowercase[c]
        paths[c].each do |c2|
          counts[{c2, visited, revisit}] += value if c2 == to
          next if c2.in?(from, to)
          if !twice && visited[c2]
            queue_and_count(working, counts, {c2, visited, true}, value)
          elsif !visited[c2]
            queue_and_count(working, counts, {c2, visited.dup.tap { |v| v[c2] = true }, twice}, value)
          end
        end
      end
    end
  end
  counts.select { |k, _| k[0] == to }.values.sum
end

puts "part1: %s" % solve(neighbours, false, from, to, lowercase)
puts "part2: %s" % solve(neighbours, true, from, to, lowercase)
