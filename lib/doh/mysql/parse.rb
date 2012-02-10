require 'bigdecimal'
require 'date'

module DohDb

def self.parse_bool(str)
  if str == '0'
    false
  elsif str == '1'
    true
  else
    raise ArgumentError.new("unexpected value: " + str)
  end
end

def self.parse_datetime(str)
  raise ArgumentError.new("unexpected value: " + str) unless str.size == 19
  return nil if str == '0000-00-00 00:00:00'
  DateTime.parse(str)
end

def self.parse_date(str)
  raise ArgumentError.new("unexpected value: " + str) unless str.size == 10
  return nil if str == '0000-00-00'
  Date.new(str[0..3].to_i, str[5..6].to_i, str[8..9].to_i)
end

def self.parse_decimal(str)
  BigDecimal(str)
end

def self.parse_int(str)
  str.to_i
end

end
