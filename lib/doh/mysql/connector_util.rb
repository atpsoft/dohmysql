module DohDb

def self.create_and_connect(connector, new_default_database = nil, drop_first = true)
  connector.reset
  connector.database = new_default_database if new_default_database
  dbh = connector.request_handle('')
  dbh.query("DROP DATABASE IF EXISTS #{connector.database}") if drop_first
  dbh.query("CREATE DATABASE IF NOT EXISTS #{connector.database}")
  dbh.query("USE #{connector.database}")
  dbh
end

def self.drop_create_and_connect(connector, new_default_database = nil)
  create_and_connect(connector, new_default_database, true)
end

def self.reconfigure_connector(cfg, connector = nil)
  connector ||= DohDb.connector_instance
  connector.reset
  connector.host = cfg['host'] if cfg.key?('host')
  connector.username = cfg['username'] if cfg.key?('username')
  connector.password = cfg['password'] if cfg.key?('password')
  connector.database = cfg['database'] if cfg.key?('database')
  connector.port = cfg['port'] if cfg.key?('port')
end

end
