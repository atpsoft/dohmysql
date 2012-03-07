require 'doh/mysql/connector_instance'
require_relative 'helpers'

module DohDb

class Test_ConnectorInstance < DohTest::TestGroup
  def test_stuff
    init_global_connector
    DohDb::query("CREATE TEMPORARY TABLE #{tbl} (id INT UNSIGNED AUTO_INCREMENT NOT NULL KEY, value INT NOT NULL DEFAULT 0, created_on DATE, created_at DATETIME, money DECIMAL(7,2) NOT NULL DEFAULT 0)")
    assert_equal(1, DohDb::insert("INSERT INTO #{tbl} (id, created_on, created_at, money) VALUES (null, CURDATE(), '2007-01-01 10:30:05', 10.5)"))
    assert_equal(2, DohDb::insert("INSERT INTO #{tbl} (id, created_on) VALUES (null, 0)"))
    assert_equal(1, DohDb::update("UPDATE #{tbl} SET money = 10.8 WHERE id = 1"))
    assert_equal(BigDecimal('10.80'), DohDb::select_field("SELECT money FROM #{tbl} WHERE id = 1"))
    assert_raises(UnexpectedQueryResult) {DohDb::select_row("SELECT * FROM #{tbl} WHERE id = 7")}
    assert_equal(nil, DohDb::select_optional_row("SELECT * FROM #{tbl} WHERE id = 7"))
    assert_raises(UnexpectedQueryResult){DohDb::select_optional_row("SELECT * FROM #{tbl} WHERE id < 3")}
    assert_equal(nil, DohDb::select_optional_field("SELECT money FROM #{tbl} WHERE id = 7"))
    assert_raises(UnexpectedQueryResult) {DohDb::select_field("SELECT money FROM #{tbl} WHERE id = 7")}
    assert_equal(1, DohDb::update_row("UPDATE #{tbl} SET money = 10.95 WHERE id = 1"))
    assert_raises(Mysql2::Error){DohDb::query("some invalid sql here")}
    # TODO: re-enable
    # assert(DohTest::pop_error)
    assert_raises(UnexpectedQueryResult) {DohDb::update_row("UPDATE #{tbl} SET money = 10.95 WHERE id = 7")}
    onerow = DohDb::select_row("SELECT * FROM #{tbl} WHERE id = 1")
    assert_equal(1, onerow['id'])
    onerow = DohDb::select_optional_row("SELECT * FROM #{tbl} WHERE id = 1")
    assert_equal(1, onerow['id'])
    rows = DohDb::select("SELECT * FROM #{tbl}")
    rows.each {|row| assert(row['id'] != 0)}
  end
end

end
