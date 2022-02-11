require "bit_array"
require "./priority_queue"

def find_day1(inputs, n)
  inputs
    .each_cons(n, reuse: true)
    .count { |x| x[0] < x[n - 1] }
end

def day1
  inputs = File
    .read("input.day1")
    .split
    .map(&.to_i)

  puts "part1: %s" % find_day1(inputs, 2)
  puts "part2: %s" % find_day1(inputs, 4)
end

def day2
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
end

def find_day3(inputs, max_bit)
  range = 0..(inputs.size - 1)
  max_bit.downto(0) do |b|
    ones = range.count { |i| inputs[i].bit(b) == 1 }
    range =
      if yield(range, ones)
        ones.zero? ? range : (range.end - ones + 1)..range.end
      else
        range.begin..(range.end - ones)
      end
  end
  inputs[range.begin]
end

def day3
  inputs = File.read_lines("input.day3")
    .map(&.to_i(2))
    .sort

  max_bit = inputs.last.bit_length - 1

  common = least = 0
  max_bit.downto(0) do |b|
    common <<= 1
    least <<= 1

    if inputs.count { |input| input.bit(b) == 1 } < inputs.size // 2
      least += 1
    else
      common += 1
    end
  end

  puts "part 1: #{common * least}"

  oxygen = find_day3(inputs, max_bit) { |range, ones| ones >= range.size / 2 }
  co2 = find_day3(inputs, max_bit) { |range, ones| ones < range.size / 2 }
  puts "part 2: #{oxygen * co2}"
end

record Board, rows : Array(Array(Int32)) do
  def won?(picked)
    rows.any? { |r| r.all? { |v| picked.includes?(v) } } ||
      (0..4).any? { |c| (0..4).all? { |r| picked.includes?(rows[r][c]) } }
  end

  def score(picked, last)
    rows.flatten.reject { |v| picked.includes?(v) }.sum * last
  end
end

def output(part, composite)
  if composite
    puts "#{part}: %s" % composite[0].score(composite[2], composite[1])
  end
end

def day4
  inputs = File.read_lines("input.day4")
  numbers = inputs.shift.split(',').map(&.to_i)
  boards = Array(Board).new
  while inputs.any?
    row = inputs.shift
    boards << Board.new(rows: Array(Array(Int32)).new(5) do
      inputs.shift.split.map(&.to_i)
    end)
  end

  picked = Set(Int32).new
  first_won = last_won = nil

  while boards.any?
    last = numbers.shift
    picked << last

    boards.reject! do |b|
      if b.won?(picked)
        first_won ||= {b, last, picked.dup}
        last_won = {b, last, picked}
      end
    end
  end

  output "part1", first_won
  output "part2", last_won
end

def register(map, x, y)
  (map[x][y] += 1i8) == 2i8
end

def solve(map, inputs, short_y)
  inputs.sum do |values|
    xs = values[0].to(values[2])
    ys = values[1].to(values[3])
    (short_y ? xs.zip(ys.cycle) : xs.cycle.zip(ys))
      .count { |x, y| register(map, x, y) }
  end
end

def day5
  by_diff_dir = File.read("input.day5").strip
    .split(/ -> |,|\n/).map(&.to_i16)
    .each_slice(4)
    .group_by { |(x1, y1, x2, y2)| {x1 == x2, y1 == y2} }

  map = Array(Array(Int8)).new(size: 1000) { Array(Int8).new(size: 1000) { 0i8 } }
  orthogonal = solve(map, by_diff_dir[{true, false}], false) + solve(map, by_diff_dir[{false, true}], true)

  puts "part1: #{orthogonal}"
  puts "part2: %s" % (orthogonal + solve(map, by_diff_dir[{false, false}], false))
end

def solve6(n, inputs)
  deq = Deque(Int64).new(9) { 0i64 }
  inputs.each { |v| deq[v] += 1 }
  n.times do
    deq.rotate! 1
    deq[6] += deq[8]
  end
  deq.sum
end

def day6
  inputs = File.read("input.day6").split(',').map(&.to_i8)

  puts "part1: #{solve6(80, inputs)}"
  puts "part2: #{solve6(256, inputs)}"
end

def find7
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

def day7
  inputs = File.read("input.day7").split(',').map(&.to_i)
  puts "part1: #{find7 { |i| calc(inputs, i) }}"
  puts "part2: #{find7 { |i| calc2(inputs, i) }}"
end

def chose(all, size)
  all.find { |s| s.size == size && yield(s) }.not_nil!
end

def all?(lookup, num, chars)
  lookup[num].all? { |c| chars.includes?(c) }
end

def day8
  inputs = File.read("input.day8").lines.map(&.split('|').map(&.split))

  p1 = inputs.sum &.last.count(&.size.in?(2, 4, 3, 7))
  puts "part1: #{p1}"

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
end

record(Pos9, x : Int8, y : Int8) do
  def neighbours
    {
      Pos9.new(x, y + 1), Pos9.new(x + 1, y),
      Pos9.new(x, y - 1), Pos9.new(x - 1, y),
    }
  end

  def above_threshold?(map, v)
    x < 0 || x >= map.size || y < 0 || y >= map[0].size ||
      map[x][y] > v
  end
end

def day9
  map = File.read("input.day9")
    .lines.map(&.chars.map(&.to_i8))

  min_points = 0.to(map.size - 1).flat_map do |x|
    0.to(map[0].size - 1)
      .map { |y| Pos9.new(x.to_i8, y.to_i8) }
      .select { |p| p.neighbours.all? &.above_threshold?(map, map[p.x][p.y]) }
  end.to_a

  puts "part1: #{min_points.sum(0) { |p| map[p.x][p.y] } + min_points.size}"

  queue = Deque(Pos9).new
  seen = Set(Pos9).new
  val = min_points.map do |p|
    seen.clear
    seen << p
    queue << p
    while p = queue.pop?
      p.neighbours.each do |n|
        next if n.above_threshold?(map, 8) || seen.includes?(n)
        queue << n unless seen.includes?(n)
        seen << n
      end
    end
    seen.size
  end
    .sort.last(3).product

  puts "part2: #{val}"
end

def consume_all?(string, stack)
  string.each_char do |c|
    case c
    when '[', '(', '<', '{' then stack.push c
    when ']'                then return c if stack.pop != '['
    when ')'                then return c if stack.pop != '('
    when '>'                then return c if stack.pop != '<'
    when '}'                then return c if stack.pop != '{'
    end
  end
end

def score2(stack)
  scores2 = 0i64
  while c = stack.pop?
    scores2 *= 5
    scores2 +=
      case c
      when '(' then 1
      when '[' then 2
      when '{' then 3
      when '<' then 4
      else          raise "Unreachable"
      end
  end
  scores2
end

def day10
  scores = 0
  scores2 = Array(Int64).new
  stack = [] of Char

  File.each_line("input.day10") do |l|
    stack.clear
    case consume_all?(l, stack)
    when ')' then scores += 3
    when ']' then scores += 57
    when '}' then scores += 1197
    when '>' then scores += 25137
    else          scores2 << score2(stack)
    end
  end

  puts "part1: #{scores}"
  puts "part2: %s" % scores2.sort[scores2.size // 2]
end

record(Pos11, x : Int8, y : Int8) do
  def neighbours
    {
      Pos11.new(x, y + 1), Pos11.new(x + 1, y),
      Pos11.new(x, y - 1), Pos11.new(x - 1, y),

      Pos11.new(x + 1, y + 1), Pos11.new(x - 1, y - 1),
      Pos11.new(x + 1, y - 1), Pos11.new(x - 1, y + 1),
    }
  end

  def increment?(map)
    return unless x >= 0 && x < 10 && y >= 0 && y < 10
    map[x][y] += 1
    map[x][y] > 9
  end
end

def step(map)
  flashes = 0
  to_flash = Deque(Pos11).new
  flashed = Set(Pos11).new
  0.to(map.size - 1).each do |x|
    0.to(map[0].size - 1).each do |y|
      p = Pos11.new(x.to_i8, y.to_i8)
      if p.increment?(map)
        to_flash << p
        flashed << p
      end
    end
  end

  while p = to_flash.pop?
    p.neighbours.each do |n|
      if n.increment?(map)
        next if flashed.includes?(n)
        to_flash << n
        flashed << n
      end
    end
  end
  flashed.each { |s| map[s.x][s.y] = 0 }
  flashed.size
end

def day11
  map = File.read("input.day11").lines.map &.chars.map(&.to_i8)
  puts "part 1: %s" % 100.times.sum { step(map) }
  puts "part2: %s" % (101..).find { |i| step(map) == 100 }
end

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

def day12
  inputs = File.read("input.day12").lines.map(&.split('-'))
  paths = (inputs.map { |vs| [vs[0], vs[1]] } + inputs.map { |vs| [vs[1], vs[0]] })
    .group_by(&.first).transform_values(&.map(&.last))

  index = paths.keys.each_with_index.to_h { |k, i| {k, i.to_i8} }
  from, to = index["start"], index["end"]
  neighbours = paths.values.map { |vs| vs.map { |v| index[v] } }

  lowercase = BitArray.new(index.size)
  paths.keys.each { |k| lowercase[index[k]] = k[0].lowercase? }

  puts "part1: %s" % solve(neighbours, false, from, to, lowercase)
  puts "part2: %s" % solve(neighbours, true, from, to, lowercase)
end

def fold(map, dir, i)
  map2 = Set(Tuple(Int32, Int32)).new

  map.each do |x, y|
    x = 2*i - x if dir == 'x' && x > i
    y = 2*i - y if dir == 'y' && y > i
    map2 << {x, y}
  end
  map2
end

def day13
  inputs = File.read("input.day13").lines
  map = Set(Tuple(Int32, Int32)).new

  while (i = inputs.shift?) && i != ""
    vs = i.split(',')
    map << {vs[0].to_i, vs[1].to_i}
  end

  folds = inputs.map(&.gsub("fold along ", "")
    .split('='))
    .map { |vs| {vs[0][0], vs[1].to_i} }

  puts "part 1: #{fold(map, *folds[0]).size}"

  folds.each { |fold| map = fold(map, *fold) }

  letters =
    6.times.map do |y|
      39.times.map do |x|
        map.includes?({x, y}) ? '#' : ' '
      end.join
    end.join('\n')

  puts "part 2:\n%s" % letters
end

def step14(pairs, rules)
  counts = Hash(Tuple(Char, Char), Int64).new(0)
  pairs.each do |pair, c|
    rules[pair].each { |p| counts[p] += c }
  end
  counts
end

def solve14(pairs, rules, n, first, last)
  n.times { pairs = step14(pairs, rules) }

  counts = Hash(Char, Int64).new(0)
  counts[first] = counts[last] = 1
  pairs.each do |(c1, c2), v|
    counts[c1] += v
    counts[c2] += v
  end

  (counts.values.max - counts.values.min) // 2
end

def day14
  inputs = File.read("input.day14").lines
  start = inputs.shift.chars
  pairs = start.each_cons(2).map { |cs| {cs[0], cs[1]} }.tally
  first, last = start[0], start[-1]

  inputs.shift

  rules = inputs.map(&.split(" -> ")).to_h do |vs|
    cs = vs[0].chars
    { {cs[0], cs[1]}, { {cs[0], vs[1][0]}, {vs[1][0], cs[1]} } }
  end

  p solve14(pairs, rules, 10, first, last)
  p solve14(pairs, rules, 40, first, last)
end

record(Pos15, x : Int16, y : Int16) do
  def neighbours
    {
      Pos15.new(x + 1, y),
      Pos15.new(x - 1, y),
      Pos15.new(x, y + 1),
      Pos15.new(x, y - 1),
    }
  end

  def val(map)
    val = map[x % map.size][y % map[0].size].to_i8 + x // map.size + y // map[0].size
    val > 9 ? val - 9 : val
  end

  def visited?(ba, xz)
    ba[xz * x + y]
  end

  def visit(ba, xz)
    ba[xz * x + y] = true
  end
end

class FrontQueue(T)
  def initialize(front_width : Int32)
    @size = 0
    @current = 0i32
    @front = Deque(Array(T)).new(front_width) { Array(T).new }
    @bucket_count = front_width
  end

  def pull : Tuple(T, Int32)?
    return nil if @size == 0

    @size -= 1
    until !@front[0].empty?
      @current += 1
      @front.rotate! 1
    end
    {@front[0].pop, @current}
  end

  def insert(value : T, prio : Int32)
    @size += 1
    offset = prio - @current
    @front[offset].push value
  end
end

def find15(map, max_x, max_y)
  p = Pos15.new(0, 0)
  target = Pos15.new(max_x.to_i16, max_y.to_i16)
  queue = FrontQueue(Pos15).new(11)
  queue.insert(p, 0)
  ba = BitArray.new((max_x + 1) * (max_y + 1))
  while t = queue.pull
    p, score = t
    break if p == target

    p.neighbours.each do |n|
      next if n.x < 0 || n.x > max_x || n.y < 0 || n.y > max_y ||
              n.visited?(ba, max_x + 1)

      n.visit(ba, max_x + 1)
      cost = score + n.val(map)
      queue.insert(n, cost)
    end
  end
  score
end

def day15
  inputs = File.read("input.day15").lines
  map = inputs.map &.each_char.map(&.to_i8).to_a

  puts "part 1: %s" % find15(map, map.size - 1, map[0].size - 1)
  puts "part 2: %s" % find15(map, 5 * map.size - 1, 5 * map[0].size - 1)
end

class Packet
  property version : Int32
  property type_id : Int32
  property value : Int64
  property consumed : Int32
  property subpackets : Array(Packet)

  def initialize(input, consume = true)
    @version = input.shift(3).join.to_i(base: 2)
    @type_id = input.shift(3).join.to_i(base: 2)
    @value = 0
    @subpackets = Array(Packet).new
    if @type_id == 4
      @consumed, @value = read_literal(input)
    else
      length_type = input.shift
      @consumed, @subpackets =
        length_type == '0' ? read_packet_bits(input) : read_packet_count(input)
    end
    while @consumed % 4 != 0 && consume
      @consumed += 1
      input.shift
    end
  end

  def evaluate : Int64
    pkts = subpackets.map(&.evaluate)
    case type_id
    when 0 then pkts.sum
    when 1 then pkts.product
    when 2 then pkts.min
    when 3 then pkts.max
    when 4 then @value
    when 5 then pkts[0] > pkts[1] ? 1i64 : 0i64
    when 6 then pkts[0] < pkts[1] ? 1i64 : 0i64
    when 7 then pkts[0] == pkts[1] ? 1i64 : 0i64
    else        raise "unknown"
    end
  end

  def versions
    version + subpackets.sum(0, &.versions)
  end

  private def read_packet_bits(input)
    length = input.shift(15).join.to_i(base: 2)
    consumed = 6 + 1 + 15 + length
    subpackets = [] of Packet
    while length > 0
      pkt = Packet.new(input, consume: false)
      subpackets << pkt
      length -= pkt.consumed
    end
    {consumed, subpackets}
  end

  private def read_packet_count(input)
    count = input.shift(11).join.to_i(base: 2)
    consumed = 6 + 1 + 11
    subpackets = [] of Packet
    count.times do
      pkt = Packet.new(input, consume: false)
      subpackets << pkt
      consumed += pkt.consumed
    end
    {consumed, subpackets}
  end

  private def read_literal(input)
    cont = input.shift
    groups = input.shift(4)
    consumed = 11
    while cont == '1'
      cont = input.shift
      groups.concat input.shift 4
      consumed += 5
    end
    value = groups.join.to_i64(base: 2)
    {consumed, value}
  end
end

def day16
  inputs = File.read("input.day16").strip.chars
  digits = inputs.map(&.to_i(base: 16).to_s(2, precision: 4)).join.chars
  packet = Packet.new(digits)

  puts "part 1: #{packet.versions}"
  puts "part 2: #{packet.evaluate}"
end

def find17(target)
  val = 0
  20.to(target[0].end) do |xvel|
    target[1].begin.to(100) do |yvel|
      if nmax = simulate(xvel, yvel, target)
        val = yield val, nmax
      end
    end
  end
  val
end

def simulate(xvel, yvel, target)
  max = 0
  xpos = ypos = 0
  while ypos >= target[1].begin && xpos <= target[0].end
    xpos, ypos, xvel, yvel = step17(xpos, ypos, xvel, yvel)
    max = ypos if ypos > max
    return max if target[0].covers?(xpos) && target[1].covers?(ypos)
  end
  nil
end

def step17(x, y, xvel, yvel)
  x += xvel
  y += yvel
  xvel -= 1 if xvel > 0
  xvel += 1 if xvel < 0
  yvel -= 1
  {x, y, xvel, yvel}
end

def day17
  input = File.read("input.day17").strip
  matches = /x=(\d+)..(\d+), y=(-\d+)..(-\d+)/.match(input).not_nil!
  x1, x2, y1, y2 = matches[1].to_i, matches[2].to_i, matches[3].to_i, matches[4].to_i
  target = {x1..x2, y1..y2}

  puts "part1: %s" % find17(target) { |val, max| max < val ? val : max }
  puts "part2: %s" % find17(target) { |val, _| val += 1 }
end

class Fish
  property left : Fish | Int32
  property right : Fish | Int32

  def self.new(input)
    input.shift
    left =
      if (c = input.shift) == '['
        input.unshift c
        new(input)
      else
        c.to_i
      end
    input.shift
    right =
      if (c = input.shift) == '['
        input.unshift c
        new(input)
      else
        c.to_i
      end
    input.shift
    new(left, right)
  end

  def initialize(left, right)
    @right = right
    @left = left
  end

  def +(other : Fish)
    Fish.new(self.dup, other.dup).reduce!
  end

  def dup
    Fish.new(left.dup, right.dup)
  end

  def reduce!
    while explode && split
    end
    self
  end

  def split
    l, r = left, right
    if l.is_a?(Fish)
      return true if l.split
    elsif l > 9
      v = l / 2
      @left = Fish.new(v.floor.to_i, v.ceil.to_i)
      return true
    end
    if r.is_a?(Fish)
      return true if r.split
    elsif r > 9
      v = r / 2
      @right = Fish.new(v.floor.to_i, v.ceil.to_i)
      return true
    end
    false
  end

  def explode(depth = 1)
    return {left.as(Int32), 0, right.as(Int32)} if depth > 4

    l, r = left, right
    if l.is_a?(Fish)
      propagate_left, @left, to_propagate = l.explode(depth + 1)
      @right = to_propagate ? add_right(right, to_propagate) : right
    end
    if r.is_a?(Fish)
      to_propagate, @right, propagate_right = r.explode(depth + 1)
      @left = to_propagate ? add_left(left, to_propagate) : left
    end
    {propagate_left, self, propagate_right}
  end

  def add_left(fish, v : Int32)
    return fish + v if fish.is_a?(Int32)

    fish.right = add_left(fish.right, v)
    fish
  end

  def add_right(fish, v)
    return fish + v if fish.is_a?(Int32)

    fish.left = add_right(fish.left, v)
    fish
  end

  def to_s
    "[#{left.to_s},#{right.to_s}]"
  end

  def magnitude
    l, r = left, right
    3 * (l.is_a?(Fish) ? l.magnitude : l) +
      2 * (r.is_a?(Fish) ? r.magnitude : r)
  end
end

def day18
  fishes = File.read("input.day18").lines.map(&.chars).map { |r| Fish.new(r) }
  puts "part 1: %s" % fishes.reduce { |acc, fish| acc + fish }.magnitude
  puts "part 2: %s" % fishes.each_permutation(size: 2, reuse: true).max_of { |(f1, f2)| (f1 + f2).magnitude }
end

class Scanner
  property coords : Set(Pos3)
  property lookup
  property fingerprint : Set(Int32)

  def initialize(coords)
    @coords = coords.to_set
    @lookup = Hash(Tuple(Pos3, Pos3, Pos3), Array(Pos3)).new
    Pos3.rotations(coords) { |reference, poss| @lookup[reference] = poss }
    @fingerprint = coords.each_combination(2)
      .map { |(p1, p2)| (p1.x.to_i32 - p2.x)**2 + (p1.y.to_i32 - p2.y)**2 + (p1.z.to_i32 - p2.z)**2 }
      .to_set
  end

  def within?(pos)
    {pos.x, pos.y, pos.z}.all? { |v| (-1000i16..1000i16).includes?(v) }
  end

  def counter(offset, other_values)
    other_values.count do |p|
      p_with_offset = Pos3.new(p.x + offset.x, p.y + offset.y, p.z + offset.z)
      within?(p_with_offset) && (@coords.includes?(p_with_offset) || return 0)
    end
  end

  def find_matches(other : Scanner)
    return if (fingerprint & other.fingerprint).size < 66
    @coords.each do |candidate|
      other.lookup.each do |remote, other_values|
        other_values.each do |candidate_remote|
          offset = Pos3.new(candidate.x - candidate_remote.x, candidate.y - candidate_remote.y, candidate.z - candidate_remote.z)

          return remote, offset if counter(offset, other_values) >= 12
        end
      end
    end
  end
end

record(Pos3, x : Int16, y : Int16, z : Int16) do
  EYE = {Pos3.new(1, 0, 0), Pos3.new(0, 1, 0), Pos3.new(0, 0, 1)}

  def self.rotations(values : Enumerable(Pos3))
    reference = EYE

    2.times do
      3.times do
        reference = reference.map &.roll
        values = values.map &.roll
        yield reference, values
        3.times do
          reference = reference.map &.turn
          values = values.map &.turn
          yield reference, values
        end
      end
      reference = reference.map &.roll.turn.roll
      values = values.map &.roll.turn.roll
    end
  end

  def roll
    Pos3.new(x, z, -y)
  end

  def turn
    Pos3.new(-y, x, z)
  end

  def *(positions : Tuple(Pos3, Pos3, Pos3))
    Pos3.new(
      positions[0].x * x + positions[1].x * y + positions[2].x * z,
      positions[0].y * x + positions[1].y * y + positions[2].y * z,
      positions[0].z * x + positions[1].z * y + positions[2].z * z,
    )
  end

  def +(other : Pos3)
    Pos3.new(x + other.x, y + other.y, z + other.z)
  end
end

def trans(ps : Tuple(Pos3, Pos3, Pos3))
  {
    Pos3.new(ps[0].x, ps[1].x, ps[2].x),
    Pos3.new(ps[0].y, ps[1].y, ps[2].y),
    Pos3.new(ps[0].z, ps[1].z, ps[2].z),
  }
end

def matmul(ps, ps2)
  {
    Pos3.new(
      ps[0].x * ps2[0].x + ps[0].y * ps2[1].x + ps[0].z * ps2[2].x,
      ps[1].x * ps2[0].x + ps[1].y * ps2[1].x + ps[1].z * ps2[2].x,
      ps[2].x * ps2[0].x + ps[2].y * ps2[1].x + ps[2].z * ps2[2].x,
    ),
    Pos3.new(
      ps[0].x * ps2[0].y + ps[0].y * ps2[1].y + ps[0].z * ps2[2].y,
      ps[1].x * ps2[0].y + ps[1].y * ps2[1].y + ps[1].z * ps2[2].y,
      ps[2].x * ps2[0].y + ps[2].y * ps2[1].y + ps[2].z * ps2[2].y,
    ),
    Pos3.new(
      ps[0].x * ps2[0].z + ps[0].y * ps2[1].z + ps[0].z * ps2[2].z,
      ps[1].x * ps2[0].z + ps[1].y * ps2[1].z + ps[1].z * ps2[2].z,
      ps[2].x * ps2[0].z + ps[2].y * ps2[1].z + ps[2].z * ps2[2].z,
    ),
  }
end

def neighbours(scanner, scanners)
  scanners.each do |other|
    ms = scanner.find_matches(other)
    yield other, *ms if ms
  end
end

def day19
  input = File.read("input.day19").lines
  scanners = Array(Scanner).new
  while input.any?
    input.shift
    values = input.shift
    coords = Array(Pos3).new
    while values && values != ""
      splatt = values.split(',').map(&.to_i16)
      coords << Pos3.new(splatt[0], splatt[1], splatt[2])
      values = input.shift?
    end
    scanners << Scanner.new(coords)
  end

  points = Set(Pos3).new
  first = scanners.shift
  rest = Set.new(scanners)
  queue = Deque{ {first, Pos3::EYE, Pos3.new(0, 0, 0)} }
  offsets = Array(Pos3).new
  while triple = queue.pop?
    current, rotation, offset = triple
    offsets << offset
    current.lookup[rotation].each { |p| points << p + offset }
    neighbours(current, rest) do |n, rotation2, offset2|
      rest.delete(n)
      queue << {n, matmul(trans(rotation), trans(rotation2)), offset2*rotation + offset}
    end
  end

  max = offsets.each_combination(2)
    .max_of { |(v1, v2)| (v1.x - v2.x).abs + (v1.y - v2.y).abs + (v1.z - v2.z).abs }

  puts "part 1: #{points.size}"
  puts "part 2: #{max}"
end

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

def day20
  input = File.read("input.day20").lines
  algo = input.shift.chars.map { |c| c == '#' }
  input.shift
  bits = input.map(&.chars.map { |c| c == '#' })

  puts "part 1: %s" % run(algo, bits, 2)
  puts "part 2: %s" % run(algo, bits, 50)
end

def step21(v, p, s)
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
    pnew, snew = step21(v, key[0], key[2])
    {pnew.to_i8, key[1], snew, key[3]}
  else
    pnew, snew = step21(v, key[1], key[3])
    {key[0], pnew.to_i8, key[2], snew}
  end
end

def day21
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
    pawns[current], scores[current] = step21(v, pawns[current], scores[current])
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
end

alias Cube = Tuple(Range(Int32, Int32), Range(Int32, Int32), Range(Int32, Int32))

def intersect(a, b)
  intersection = {0, 1, 2}.map do |i|
    ({a[i], b[i]}.max_of(&.begin)..{a[i], b[i]}.min_of(&.end))
      .tap { |r| return if r.begin > r.end }
  end
end

def solve22(ranges)
  cubes = Hash(Cube, Int64).new(0i64)
  ranges.each do |on, cube|
    cubes.each do |c, v|
      next if v == 0

      if intersection = intersect(cube, c)
        cubes[intersection] += vol(intersection, v < 0)
      end
    end
    cubes[cube] += vol(cube, on) if on
  end
  cubes.sum &.last
end

def vol(cube, on)
  xs, ys, zs = cube
  v = (xs.end.to_i64 - xs.begin + 1) * (ys.end - ys.begin + 1) * (zs.end - zs.begin + 1)
  on ? v : -v
end

def day22
  input = File.read("input.day22").lines
  ranges = input.map do |line|
    matches = /x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/.match(line).not_nil!
    on = !!line[/on/]?
    {on, {matches[1].to_i..matches[2].to_i, matches[3].to_i..matches[4].to_i, matches[5].to_i..matches[6].to_i}}
  end

  init_ranges = ranges.select { |_, cube| intersect(cube, {-50..50, -50..50, -50..50}) }

  puts "part 1: #{solve22(init_ranges)}"
  puts "part 2: #{solve22(ranges)}"
end

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

def neighbours23(state)
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

def solve23(pods)
  queue = PriorityQueue(Int32, Tuple(Array(Pod), Int32)).new
  queue.insert({pods.sort!, 0}, estimate(pods))
  seen = Set(Array(Pod)).new
  while state = queue.pull
    last = state
    break if goal?(state)

    neighbours23(state) do |pods, cost, estimate|
      next if seen.includes?(pods)
      seen << pods
      queue.insert({pods, cost}, estimate)
    end
  end
  last[1] if last
end

def day23
  input = File.read("input.day23")
  chars = input.lines.map(&.chars)
  part1 = read_pods(chars)
  chars = chars[0..2] + [
    "  #D#C#B#A#".chars,
    "  #D#B#A#C#".chars,
  ] + chars[3..]
  part2 = read_pods(chars)

  puts "part 1: #{solve23(part1)}"
  puts "part 2: #{solve23(part2)}"
end

class Machine
  property registry : Array(Int64)

  def initialize
    @registry = Array.new(4, 0i64)
    @stack = Array(Int32).new
  end

  def val(v)
    if x = v.to_i64?
      x
    else
      @registry[v[0].ord - 'w'.ord]
    end
  end

  def setval(v, v2 : Int64)
    @registry[v[0].ord - 'w'.ord] = v2
  end

  def minmax(code)
    dependency = -1
    current = -1
    reduce = false
    min = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    max = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    code.each do |line|
      ins, v1, v2 = line[0], line[1], line[2]?
      if v2
        case ins
        when "add" then setval(v1, val(v1) + val(v2))
        when "mul" then setval(v1, val(v1) * val(v2))
        when "div"
          if reduce = val(v2) != 1
            dependency = @stack.pop
          else
            @stack.push current
          end
          setval(v1, val(v1) // val(v2))
        when "mod"
          setval(v1, val(v1) % val(v2))
        when "eql"
          if reduce
            reduce = false
            if val(v1) > 0
              min[current] = 1 + val(v1)
              min[dependency] = 1
              max[current] = 9
              max[dependency] = 9 - val(v1)
            else
              min[current] = 1
              min[dependency] = 1 - val(v1)
              max[current] = 9 + val(v1)
              max[dependency] = 9
            end
            setval(v1, 1i64)
          else
            setval(v1, val(v1) == val(v2) ? 1i64 : 0i64)
          end
        else raise ""
        end
      else
        current += 1
        setval(v1, 0i64)
      end
    end
    {min.join, max.join}
  end
end

def day24
  input = File.read("input.day24")
  code = input.lines.map &.split

  min, max = Machine.new.minmax(code)

  puts "part 1: #{max}"
  puts "part 2: #{min}"
end

enum Spot : UInt8
  Empty
  Left
  Down
end

def step25(map, map2, xsize, ysize)
  changed = false
  xsize.times do |x|
    m = map[x] # note: quite a bit faster like this instead of inline.
    m2 = map2[x]

    ysize.times do |y|
      if m[y].left?
        if m[(y + 1) % ysize].empty?
          changed = true
          m2[(y + 1) % ysize] = Spot::Left
        else
          m2[y] = Spot::Left
        end
      end
    end
  end

  xsize.times do |x|
    m = map[x]
    mnext = map[(x + 1) % xsize]
    m2 = map2[x]
    m2next = map2[(x + 1) % xsize]

    ysize.times do |y|
      if m[y].down?
        if mnext[y].down? || !m2next[y].empty?
          m2[y] = Spot::Down
        else
          changed = true
          m2next[y] = Spot::Down
        end
      end
    end
  end
  changed
end

def day25
  input = File.read("input.day25").lines
  map = input.map &.chars.map do |c|
    case c
    when '>' then Spot::Left
    when 'v' then Spot::Down
    else          Spot::Empty
    end
  end

  xsize = input.size
  ysize = input[0].size
  map2 = Array.new(xsize) { Array.new(ysize, Spot::Empty) }

  (1..).each do |i|
    unless step25(map, map2, xsize, ysize)
      puts "part 1: #{i}"
      break
    end
    map.each(&.fill(Spot::Empty))
    map, map2 = map2, map
  end
end

times = [] of Time::Span

{% for i in (1..25) %}
  times << Time.measure { day{{i.id}} }
{% end %}

puts
puts

times.each_with_index do |t, i|
  puts "day #{i + 1}:\t #{t}s"
end
puts
puts "total:\t %s" % times.sum
