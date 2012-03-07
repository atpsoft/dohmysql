require_relative 'helpers'
require 'doh/mysql/convert'

module DohDb

class Test_Convert < DohTest::TestGroup
  def before_all
    # TODO: shouldn't really have to do this, but for now convert is dependent on it
    init_global_connector
  end

  def before_each
    drop_tbl
    get_dbh.query("CREATE TABLE #{tbl} (not_null_field CHAR(1) NOT NULL, null_ok_field CHAR(1), int_field INT, bool_field TINYINT(1), date_field DATE, datetime_field DATETIME)")
  end

  def after_each
    drop_tbl
  end

  def convert(value)
    DohDb::convert(tbl, @field, value)
  end

  def verify(converted, original)
    assert_equal(converted, convert(original))
  end

  def verify_same(value)
    verify(value, value)
  end

  def verify_exception(value, exception_class)
    assert_raises(exception_class) { convert(value) }
  end

  def test_nil_null
    assert_equal('blah', DohDb::convert('some_table_that_doesnt_exist', 'some_column_that_doesnt_exist', 'blah'))
    assert_equal('blah', DohDb::convert('', 'some_column_that_doesnt_exist', 'blah'))
    assert_raises(CannotBeNull) { DohDb::convert(tbl, 'not_null_field', nil) }
    assert_equal(nil, DohDb::convert(tbl, 'null_ok_field', nil))
    assert_equal('', DohDb::convert(tbl, 'not_null_field', ''))
    assert_equal(nil, DohDb::convert(tbl, 'null_ok_field', ''))
    assert_equal(nil, DohDb::convert(tbl, 'int_field', ''))
  end
end

end
