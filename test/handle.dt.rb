require_relative 'db_unit_test'
require 'doh/core_ext/hash'

module DohDb

class Test_Handle < DohTest::TestGroup
  def test_stuff
    dbh = DohDb::request_handle
    tbl = "doh_mysql_handle_stuff_test"
    dbh.query("CREATE TEMPORARY TABLE #{tbl} (id INT UNSIGNED AUTO_INCREMENT NOT NULL KEY, value INT NOT NULL DEFAULT 0, created_on DATE, created_at DATETIME, money DECIMAL(7,2) NOT NULL DEFAULT 0)")
    assert_equal(1, dbh.insert("INSERT INTO #{tbl} (id, created_on, created_at, money) VALUES (null, CURDATE(), '2007-01-01 10:30:05', 10.5)"))
    assert_equal(2, dbh.insert("INSERT INTO #{tbl} (id, created_on, created_at) VALUES (null, 0, 0)"))
    assert_equal(3, dbh.insert("INSERT INTO #{tbl} (id) VALUES (null)"))
    onerow = dbh.select_row("SELECT * FROM #{tbl} WHERE id = 1")
    assert_equal(1, onerow['id'])
    rows = dbh.select("SELECT * FROM #{tbl}")
    rows.each {|row| assert(row['id'] != 0)}
  end

  def test_select_transpose_2fields
    dbh = DohDb::request_handle
    tbl = "doh_mysql_handle_select_transpose_2fields_test"
    DohDb::query("CREATE TEMPORARY TABLE #{tbl} (field CHAR(30) NOT NULL, value CHAR(30) NOT NULL)")
    DohDb::query("INSERT INTO #{tbl} SET field = 'some_name', value = 'some_value'")
    DohDb::query("INSERT INTO #{tbl} SET field = 'other_name', value = 'matching_other_value'")
    DohDb::query("INSERT INTO #{tbl} SET field = 'yet_another_name', value = 'strange_value'")
    hash = DohDb::select_transpose("SELECT field, value FROM #{tbl}")
    assert_equal('some_value', hash['some_name'])
    assert_equal('matching_other_value', hash['other_name'])
    assert_equal('strange_value', hash['yet_another_name'])
  end

  def test_select_transpose_3fields
    dbh = DohDb::request_handle
    tbl = "doh_mysql_handle_select_transpose_3fields_test"
    DohDb::query("CREATE TEMPORARY TABLE #{tbl} (field CHAR(30), some_value CHAR(30), other_value CHAR(30))")
    DohDb::query("INSERT INTO #{tbl} SET field = 'some_name', some_value = 'some_value', other_value = 'blah'")
    DohDb::query("INSERT INTO #{tbl} SET field = 'other_name', some_value = 'matching_other_value', other_value = 'blee'")
    DohDb::query("INSERT INTO #{tbl} SET field = 'yet_another_name', some_value = 'strange_value', other_value = 'bloo'")
    hash = DohDb::select_transpose("SELECT field, some_value, other_value FROM #{tbl}")
    assert_equal(hash['some_name'], {'some_value' => 'some_value', 'other_value' => 'blah'})
    assert_equal(hash['other_name'], {'some_value' => 'matching_other_value', 'other_value' => 'blee'})
    assert_equal(hash['yet_another_name'], {'some_value' => 'strange_value', 'other_value' => 'bloo'})
  end

  def test_select_values
    dbh = DohDb::request_handle
    tbl = "doh_mysql_handle_select_values_test"
    DohDb::query("CREATE TEMPORARY TABLE #{tbl} (field CHAR(30), some_value CHAR(30))")
    DohDb::query("INSERT INTO #{tbl} SET field = 'some_name', some_value = 'some_value'")
    assert_equal([['some_name', 'some_value']], DohDb::select_values("SELECT field, some_value FROM #{tbl}"))
    assert_equal([['some_name']], DohDb::select_values("SELECT field FROM #{tbl}"))
  end

  def test_insert_hash
    dbh = DohDb::request_handle
    tbl = "doh_mysql_insert_hash_test"
    dbh.query("CREATE TEMPORARY TABLE #{tbl} (value INT KEY)")
    hash1 = {'value' => 1}
    assert_equal(0, dbh.insert_hash(hash1, tbl))
    assert_raises(Mysql2::Error) { dbh.insert_hash(hash1, tbl) }
    assert_equal(0, dbh.insert_ignore_hash(hash1, tbl))
  end
end

end
