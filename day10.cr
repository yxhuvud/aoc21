inputs = File.read("input.day10").lines

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

scores = 0
scores2 = Array(Int64).new

stack = [] of Char
filtered = inputs.reject do |l|
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
