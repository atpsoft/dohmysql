require 'doh/mysql/connector_instance'
require_relative 'helpers'

module DohDb

class Test_ConnectorInstance < DohTest::TestGroup
  def test_stuff
    init_global_connector
    Doh.db.query("CREATE TEMPORARY TABLE #{tbl} (id INT UNSIGNED AUTO_INCREMENT NOT NULL KEY, value INT NOT NULL DEFAULT 0, created_on DATE, created_at DATETIME, money DECIMAL(7,2) NOT NULL DEFAULT 0)")
    assert_equal(1, Doh.db.insert("INSERT INTO #{tbl} (id, created_on, created_at, money) VALUES (null, CURDATE(), '2007-01-01 10:30:05', 10.5)"))
    assert_equal(2, Doh.db.insert("INSERT INTO #{tbl} (id, created_on) VALUES (null, 0)"))
    assert_equal(1, Doh.db.update("UPDATE #{tbl} SET money = 10.8 WHERE id = 1"))
    assert_equal(BigDecimal('10.80'), Doh.db.select_field("SELECT money FROM #{tbl} WHERE id = 1"))
    assert_raises(UnexpectedQueryResult) {Doh.db.select_row("SELECT * FROM #{tbl} WHERE id = 7")}
    assert_equal(nil, Doh.db.select_optional_row("SELECT * FROM #{tbl} WHERE id = 7"))
    assert_raises(UnexpectedQueryResult){Doh.db.select_optional_row("SELECT * FROM #{tbl} WHERE id < 3")}
    assert_equal(nil, Doh.db.select_optional_field("SELECT money FROM #{tbl} WHERE id = 7"))
    assert_raises(UnexpectedQueryResult) {Doh.db.select_field("SELECT money FROM #{tbl} WHERE id = 7")}
    assert_equal(1, Doh.db.update_row("UPDATE #{tbl} SET money = 10.95 WHERE id = 1"))
    # TODO: re-enable
    # assert(DohTest::pop_error)
    assert_raises(UnexpectedQueryResult) {Doh.db.update_row("UPDATE #{tbl} SET money = 10.95 WHERE id = 7")}
    onerow = Doh.db.select_row("SELECT * FROM #{tbl} WHERE id = 1")
    assert_equal(1, onerow['id'])
    onerow = Doh.db.select_optional_row("SELECT * FROM #{tbl} WHERE id = 1")
    assert_equal(1, onerow['id'])
    rows = Doh.db.select("SELECT * FROM #{tbl}")
    rows.each {|row| assert(row['id'] != 0)}
    assert_raises(Mysql2::Error){Doh.db.query("some invalid sql here")}
  end
end

end
