require 'dohmysql/readonly_row'
require 'dohmysql/smart_row'

module DohDb

class TypedRowBuilder
  def initialize(arg = ReadOnlyRow)
    if arg.is_a?(String)
      @row_klass = SmartRow
      @table = arg
    elsif arg.is_a?(Hash)
      @row_klass = ReadOnlyRow
      @table = arg[:read]
    else
      @row_klass = arg
      @table = nil
    end
  end

  def build_rows(result_set)
    return [] if result_set.size == 0

    retval = []
    result_set.each do |row|
      keys = []
      values = []
      row.each_pair do |key, value|
        keys.push(key)
        if value.is_a?(Time)
          values.push(value.to_datetime)
        else
          values.push(value)
        end
      end
      if @table
        row = @row_klass.new(keys, values, @table)
      else
        row = @row_klass.new(keys, values)
      end
      retval.push(row)
    end
    retval
  end
end

end
