require_relative 'db_unit_test'
require 'doh/mysql/types'

module DohDb

class ConvertToString
  def self.build(field, value)
    value.to_s
  end
end

class Test_types < DohTest::TestGroup
  def test_stuff
    dbh = DohDb::request_handle
    tbl = "doh_mysql_types_stuff_test"
    tbl2 = "island.doh_mysql_types_stuff_another_test"
    DohDb::query("CREATE TEMPORARY TABLE #{tbl} (amount INT)")
    DohDb::query("INSERT INTO #{tbl} SET amount = NULL")
    assert_equal(nil, DohDb::select_field("SELECT amount FROM #{tbl}"))
    DohDb::query("UPDATE #{tbl} SET amount = 5")
    assert_equal(5, DohDb::select_field("SELECT amount FROM #{tbl}"))

    DohDb::query("CREATE TEMPORARY TABLE #{tbl2} (other INT)")
    DohDb::query("INSERT INTO #{tbl2} SET other = 7")
    assert_equal(5, DohDb::select_field("SELECT amount, other FROM #{tbl}, #{tbl2}"))

    DohDb::register_column_type(DohDb::connector_instance.database, tbl, 'amount', ConvertToString)
    assert_equal('5', DohDb::select_field("SELECT amount FROM #{tbl}"))
  end
end

end
