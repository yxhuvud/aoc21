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

fishes = File.read("input.day18").lines.map(&.chars).map { |r| Fish.new(r) }
puts "part 1: %s" % fishes.reduce { |acc, fish| acc + fish }.magnitude
puts "part 2: %s" % fishes.each_permutation(size: 2, reuse: true).max_of { |(f1, f2)| (f1 + f2).magnitude }
