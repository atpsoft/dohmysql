require_relative 'db_unit_test'

module DohDb

class Test_CacheConnector < DohTest::TestGroup
  def create_table
    @cc.request_handle.query("CREATE TEMPORARY TABLE #@tbl (id INT AUTO_INCREMENT KEY)")
  end

  def insert_record
    @cc.request_handle.insert("INSERT INTO #@tbl (id) VALUES (null)")
  end

  def test_stuff
    sharedcc = DohDb::connector_instance
    @cc = DohDb::CacheConnector.new(sharedcc.host, sharedcc.username, sharedcc.password, sharedcc.database, sharedcc.row_builder)
    @tbl = 'doh_mysql_cache_connector_stuff_test'

    create_table
    assert_equal(1, insert_record)

    dbh = @cc.request_handle
    assert_equal(2, insert_record)
    dbh.close
    # temporary table gets deleted on handle close
    create_table

    #test it resets the handle
    @cc.reset
    create_table
    @cc.reset
    @cc.reset

    # test it still works after timeout
    create_table
    @cc.timeout = -1
    create_table
  end
end

end
