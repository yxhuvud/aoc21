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

def find(inputs, max_bit)
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

oxygen = find(inputs, max_bit) { |range, ones| ones >= range.size / 2 }
co2 = find(inputs, max_bit) { |range, ones| ones < range.size / 2 }

puts "part 2: #{oxygen * co2}"
