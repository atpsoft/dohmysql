require 'doh/mysql/connector_instance'
require 'doh/mysql/cache_connector'
require 'yaml'

config_filename = File.join(File.dirname(__FILE__), 'connector.yml')
raise RuntimeError.new("mysql connector configuration file (#{config_filename}) must exist (see #{config_filename}.tmpl for an example)") unless File.exist?(config_filename)
config = YAML.load_file(config_filename)

connector = DohDb::CacheConnector.new(config['host'], config['username'], config['password'], config['database'])
DohDb::set_connector_instance(connector)
