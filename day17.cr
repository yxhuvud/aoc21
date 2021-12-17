def simulate(xvel, yvel, target)
  max = 0
  xpos = ypos = 0
  while ypos >= target[1].begin && xpos <= target[0].end
    xpos, ypos, xvel, yvel = step(xpos, ypos, xvel, yvel)
    max = ypos if ypos > max
    return max if within?(xpos, ypos, target)
  end
  nil
end

def step(x, y, xvel, yvel)
  x += xvel
  y += yvel
  xvel -= 1 if xvel > 0
  xvel += 1 if xvel < 0
  yvel -= 1
  {x, y, xvel, yvel}
end

def within?(x, y, target)
  target[0].covers?(x) && target[1].covers?(y)
end

def find(target)
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

inputs = File.read("input.day17").strip.chars
input = "target area: x=201..230, y=-99..-65"
matches = /x=(\d+)..(\d+), y=(-\d+)..(-\d+)/.match(input).not_nil!
x1, x2, y1, y2 = matches[1].to_i, matches[2].to_i, matches[3].to_i, matches[4].to_i
target = {x1..x2, y1..y2}

puts "part1: %s" % find(target) { |val, max| max < val ? val : max }
puts "part2: %s" % find(target) { |val, _| val += 1 }
