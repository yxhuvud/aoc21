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
