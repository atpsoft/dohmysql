require 'doh/mysql/readonly_row'

module DohDb

class TypedRowBuilder
  def initialize(row_klass = nil, guesser = nil)
    @row_klass = row_klass || ReadOnlyRow
  end

  def build_rows(result_set)
    return [] if result_set.size == 0

    field_names = result_set.fields

    retval = []
    result_set.each do |row|
      retval.push(@row_klass.new(field_names, row.values))
    end
    retval
  end
end

end
