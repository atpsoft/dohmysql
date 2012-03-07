require_relative 'helpers'
require 'mysql2'

module DohDb

class Test_typecasting < DohTest::TestGroup
  def test_stuff
    Mysql2::Client.default_query_options[:database_timezone] = :utc
    Mysql2::Client.default_query_options[:application_timezone] = :utc

    dbh = get_dbh
    dbh.query("CREATE TEMPORARY TABLE #{tbl} (char_field CHAR(1) NOT NULL, int_field INT, bool_field TINYINT(1), date_field DATE, datetime_field DATETIME, decimal_field DECIMAL(7,2))")
    dbh.insert("INSERT INTO #{tbl} SET char_field = 'c', int_field = 5, bool_field = 1, date_field = '2012-02-20', datetime_field = '2012-02-20 21:06:00', decimal_field = 54.12")
    row = dbh.select_row("SELECT * FROM #{tbl}")
    assert_equal('c', row['char_field'])
    assert_equal(5, row['int_field'])
    assert_equal(true, row['bool_field'])
    assert_equal(Date.new(2012,2,20), row['date_field'])
    assert_equal(DateTime.new(2012,2,20, 21, 6, 0), row['datetime_field'])
    assert_equal(BigDecimal('54.12'), row['decimal_field'])
  end
end

end
