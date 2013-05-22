require 'dohmysql/cache_connector'
require_relative 'helpers'

module DohDb

class Test_CacheConnector < DohTest::TestGroup
  def create_table
    @cc.request_handle.query("CREATE TEMPORARY TABLE #{tbl} (id INT AUTO_INCREMENT KEY)")
  end

  def insert_record
    @cc.request_handle.insert("INSERT INTO #{tbl} (id) VALUES (NULL)")
  end

  def test_stuff
    @cc = DohDb::CacheConnector.new(dbcfg)

    create_table
    assert_equal(1, insert_record)

    dbh = @cc.request_handle
    assert_equal(2, insert_record)
    dbh.close

    # temporary table should get deleted when the connection closes
    create_table

    @cc.reset
    create_table
    @cc.reset
    @cc.reset

    # test it still works after timeout
    create_table
    @cc.config[:timeout] = -1
    create_table
  end
end

end
