require 'doh/mysql/readonly_row'
require 'doh/mysql/default_type_guesser'

module DohDb

class TypedRowBuilder
  def initialize(row_klass = nil, guesser = nil)
    @row_klass = row_klass || ReadOnlyRow
    @guesser = guesser || DefaultTypeGuesser
  end

  def build_rows(result_set)
    meta_info = result_set.fetch_fields
    field_names = meta_info.collect {|elem| elem.name}

    retval = []
    result_set.each do |row|
      typed_values = []
      row.each_with_index do |field, index|
        typed_values[index] = @guesser.guess_type(field, meta_info[index])
      end
      retval.push(@row_klass.new(field_names, typed_values))
    end
    retval
  end
end

end
