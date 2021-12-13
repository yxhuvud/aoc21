inputs = File.read("input.day13").lines
map = Set(Tuple(Int32, Int32)).new

while (i = inputs.shift?) && i != ""
  vs = i.split(',')
  map << {vs[0].to_i, vs[1].to_i}
end

folds = inputs.map(&.gsub("fold along ", "")
  .split('='))
  .map { |vs| {vs[0][0], vs[1].to_i} }

def fold(map, dir, i)
  map2 = Set(Tuple(Int32, Int32)).new

  map.each do |x, y|
    x = 2*i - x if dir == 'x' && x > i
    y = 2*i - y if dir == 'y' && y > i
    map2 << {x, y}
  end
  map2
end

puts "part 1: #{fold(map, *folds[0]).size}"

folds.each { |fold| map = fold(map, *fold) }

letters =
  6.times.map do |y|
    39.times.map do |x|
      map.includes?({x, y}) ? '#' : ' '
    end.join
  end.join('\n')

puts "part 2:\n%s" % letters
