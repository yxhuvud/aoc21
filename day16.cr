class Packet
  property version : Int32
  property type_id : Int32
  property value : Int64
  property consumed
  property subpackets

  def initialize(input, consume = true)
    @version = input.shift(3).join.to_i(base: 2)
    @type_id = input.shift(3).join.to_i(base: 2)

    @value = 0
    @subpackets = Array(Packet).new
    if @type_id == 4
      cont = input.shift
      groups = input.shift(4)
      @consumed = 11
      while cont == '1'
        cont = input.shift
        groups.concat input.shift 4
        @consumed += 5
      end
      @value = groups.join.to_i64(base: 2)
    else
      length_type = input.shift
      if length_type == '0'
        length = input.shift(15).join.to_i(base: 2)
        @consumed = 6 + 1 + 15 + length
        while length > 0
          pkt = Packet.new(input, consume: false)
          @subpackets << pkt
          length -= pkt.consumed
        end
      else
        count = input.shift(11).join.to_i(base: 2)
        @consumed = 6 + 1 + 11
        count.times do
          pkt = Packet.new(input, consume: false)
          @subpackets << pkt
          @consumed += pkt.consumed
        end
      end
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
end

inputs = File.read("input.day16").strip.chars
digits = inputs.map(&.to_i(base: 16).to_s(2, precision: 4)).join.chars
packet = Packet.new(digits)

puts "part 1: #{packet.versions}"
puts "part 2: #{packet.evaluate}"
