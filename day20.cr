def num(map, x, y)
  i = 0
  -1.to(1) do |dx|
    -1.to(1) do |dy|
      i <<= 1
      i += map[x + dx][y + dy] ? 1 : 0
    end
  end
  i
end

def run(algo, bits, n)
  offset = n + 1
  map = Array.new(bits.size + 2 * offset) { Array.new(bits[0].size + 2 * offset, false) }
  new_map = Array.new(bits.size + 2 * offset) { Array.new(bits[0].size + 2 * offset, true) }
  bits.each_with_index do |r, x|
    r.each_with_index { |b, y| map[x + offset][y + offset] = b }
  end
  xmin = offset
  ymin = offset
  xmax = offset + bits.size - 1
  ymax = offset + bits[0].size - 1

  1.to(n) do |i|
    (xmin - i).to(xmax + i) do |x|
      (ymin - i).to(ymax + i) { |y| new_map[x][y] = algo[num(map, x, y)] }
    end
    map, new_map = new_map, map
  end
  map.sum &.count(true)
end

input = File.read("input.day20").lines
algo = input.shift.chars.map { |c| c == '#' }
input.shift
bits = input.map(&.chars.map { |c| c == '#' })

puts "part 1: %s" % run(algo, bits, 2)
puts "part 2: %s" % run(algo, bits, 50)
