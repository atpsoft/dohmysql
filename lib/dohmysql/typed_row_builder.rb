require 'dohmysql/readonly_row'

module DohDb

class TypedRowBuilder
  def initialize(arg = ReadOnlyRow)
    @row_klass = arg
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
      retval.push(@row_klass.new(keys, values))
    end
    retval
  end
end

end
