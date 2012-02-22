require 'doh/mysql/readonly_row'

module DohDb

class TypedRowBuilder
  def initialize(row_klass = nil, guesser = nil)
    @row_klass = row_klass || ReadOnlyRow
  end

  def build_rows(result_set)
    return [] if result_set.size == 0

    retval = []
    result_set.each do |row|
      keys = []
      values = []
      row.each_pair do |key, value|
        keys.push(key)
        values.push(value)
      end
      retval.push(@row_klass.new(keys, values))
    end
    retval
  end
end

end
