module InternalTestHelpers
  def dbcfg
    { :host => 'localhost', :username => 'root', :database => 'test' }
  end

  def tbl
    @tbl ||= self.class.to_s.gsub(/:/, '_').downcase
  end

  def drop_stmt
    "DROP TABLE IF EXISTS #{tbl}"
  end

  def drop_tbl
    get_dbh.query("DROP TABLE IF EXISTS #{tbl}")
  end

  def get_dbh
    require 'dohmysql/handle'
    DohDb::Handle.new(dbcfg)
  end

  def init_global_connector
    require 'dohmysql/connector_instance'
    require 'dohmysql/cache_connector'
    DohDb.set_connector_instance(DohDb::CacheConnector.new(dbcfg))
  end
end

class DohTest::TestGroup
  include InternalTestHelpers
end
