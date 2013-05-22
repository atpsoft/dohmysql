require_relative 'helpers'
require 'dohmysql/metadata_util'

module DohDb

class Test_metadata_util < DohTest::TestGroup
  def before_all
    # TODO: shouldn't really have to do this, but for now metadata_util is dependent on it
    init_global_connector
  end

  def before_each
    drop_tbl
  end

  def after_each
    drop_tbl
  end

  def test_stuff
    dbh = get_dbh
    dbh.query("CREATE TABLE #{tbl} (num INT, str CHAR(7))")
    column_info = DohDb.column_info(tbl)
    info = column_info['str']
    assert_equal('char', info['data_type'])
    assert_equal(7, info['character_maximum_length'])
    info = column_info['num']
    assert_equal('int', info['data_type'])
    assert_equal(nil, info['character_maximum_length'])

    assert_equal(7, DohDb.field_character_size(tbl, 'str'))
    assert_equal(nil, DohDb.field_character_size(tbl, 'num'))

    row = {'num' => 'blahblahblah', 'str' => 'blahblahblah'}
    DohDb.chop_character_fields!(tbl, row)
    assert_equal('blahblahblah', row['num'])
    assert_equal('blahbla', row['str'])

    row = {'num' => 'blahblahblah', 'str' => 'blahblahblah'}
    newrow = DohDb.chop_character_fields(tbl, row)
    assert_equal('blahblahblah', newrow['num'])
    assert_equal('blahbla', newrow['str'])
    assert_equal('blahblahblah', row['num'])
    assert_equal('blahblahblah', row['str'])
  end
end

end
