record Board, rows : Array(Array(Int32)) do
  def won?(picked)
    rows.any? { |r| r.all? { |v| picked.includes?(v) } } ||
      (0..4).any? { |c| (0..4).all? { |r| picked.includes?(rows[r][c]) } }
  end

  def score(picked, last)
    rows.flatten.reject { |v| picked.includes?(v) }.sum * last
  end
end

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

def output(part, composite)
  if composite
    puts "#{part}: %s" % composite[0].score(composite[2], composite[1])
  end
end

output "part1", first_won
output "part2", last_won
