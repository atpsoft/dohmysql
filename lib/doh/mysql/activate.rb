require 'doh/mysql/cache_connector'
require 'doh/mysql/connector_instance'
require 'doh/mysql/handle'
require 'doh/mysql/to_sql'
require 'doh/mysql/db_date'
require 'doh/mysql/unquoted'
require 'doh/config'

module DohDb

def self.activate
  root_cfg = Doh::config
  return unless root_cfg.fetch('enable_database', true)
  return unless root_cfg.key?('database')
  db_cfg = root_cfg['database']
  require 'doh/mysql'
  require 'doh/mysql/require_dbtypes'
  conn = DohDb::CacheConnector.new(db_cfg['host'], db_cfg['username'], db_cfg['password'], db_cfg['database'] || root_cfg['primary_database'])
  conn.port = db_cfg['port']
  conn.timeout = db_cfg['timeout'].to_i if db_cfg['timeout']
  conn.row_builder = db_cfg['row_builder'] || root_cfg['row_builder']
  DohDb::set_connector_instance(conn)
  DohDb::require_dbtypes
end

end
