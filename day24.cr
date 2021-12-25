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

input = File.read("input.day24")
code = input.lines.map &.split

min, max = Machine.new.minmax(code)

puts "part 1: #{max}"
puts "part 2: #{min}"
