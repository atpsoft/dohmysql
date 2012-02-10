require 'doh/mysql/metadata_util'
require 'doh/mysql/readonly_row'
require 'doh/mysql/types'

module DohDb

class LinkedRow
  def self.build(field, idvalue)
    return ReadOnlyRow.new([], []) if idvalue.to_i == 0
    table = field.sub(/_id/, '')
    table = table.rafter('_') unless DohDb::table_exist?(table)
    raise "unable to determine child table name for field #{field}" unless DohDb::table_exist?(table)
    DohDb::select_row("SELECT * FROM #{table} WHERE #{DohDb::find_primary_key(table)} = #{idvalue}", DohDb::find_row_type(table) || :smart)
  end
end

end
