enum Spot : UInt8
  Empty
  Left
  Down
end

def step(map, map2, xsize, ysize)
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
  unless step(map, map2, xsize, ysize)
    puts "part 1: #{i}"
    break
  end
  map.each(&.fill(Spot::Empty))
  map, map2 = map2, map
end
