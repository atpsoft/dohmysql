require_relative 'db_unit_test'
require 'doh/mysql/metadata_util'

module DohDb

class Test_metadata_util < DohTest::TestGroup
  def tbl
    "doh_mysql_metadata_util_test"
  end

  def test_stuff
    dbh = DohDb::request_handle
    dbh.query("CREATE TABLE #{tbl} (num INT, str CHAR(7))")
    column_info = DohDb::column_info(tbl)
    info = column_info['str']
    assert_equal('char', info['data_type'])
    assert_equal(7, info['character_maximum_length'])
    info = column_info['num']
    assert_equal('int', info['data_type'])
    assert_equal(nil, info['character_maximum_length'])

    assert_equal(7, DohDb::field_character_size(tbl, 'str'))
    assert_equal(nil, DohDb::field_character_size(tbl, 'num'))

    row = {'num' => 'blahblahblah', 'str' => 'blahblahblah'}
    DohDb::chop_character_fields!(tbl, row)
    assert_equal('blahblahblah', row['num'])
    assert_equal('blahbla', row['str'])

    row = {'num' => 'blahblahblah', 'str' => 'blahblahblah'}
    newrow = DohDb::chop_character_fields(tbl, row)
    assert_equal('blahblahblah', newrow['num'])
    assert_equal('blahbla', newrow['str'])
    assert_equal('blahblahblah', row['num'])
    assert_equal('blahblahblah', row['str'])

    assert(DohDb::table_exist?(tbl))

    assert_equal('num', DohDb::find_primary_key(tbl))
    assert_raises(RuntimeError) { DohDb::find_primary_key(tbl, "this_database_doesnt_exist") }
    assert_raises(RuntimeError) { DohDb::find_primary_key("this table doesn't exist") }
  end

  def before_each
    DohDb::query("DROP TABLE IF EXISTS #{tbl}")
  end

  def after_each
    DohDb::query("DROP TABLE IF EXISTS #{tbl}")
  end
end

end
