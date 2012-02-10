require 'mysql'
require 'doh/mysql/readonly_row'

module DohDb

class RawRowBuilder
  def build_rows(result_set)
    field_names = result_set.fetch_fields.collect {|elem| elem.name}
    retval = []
    result_set.each {|elem| retval.push(DohDb::ReadOnlyRow.new(field_names, elem))}
    retval
  end
end

end
