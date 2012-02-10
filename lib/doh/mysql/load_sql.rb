require 'doh/mysql/connector_instance'

module DohDb

def self.mysql_arg(value, option_specifier)
  return '' if value.to_s.strip.empty?
  ' -' + option_specifier + value
end

def self.load_sql(filenames, host, username, password, database)
  mysqlcmd = 'mysql' + mysql_arg(host, 'h') + mysql_arg(username, 'u') + mysql_arg(password, 'p') + ' ' + database
  io = IO::popen(mysqlcmd, 'r+')
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1
  filenames.each do |elem|
    open(elem) {|file| io << file.read}
  end
  io.close
end

def self.load_sql_connector(filenames, connector = nil, alternate_database = nil)
  connector ||= DohDb::connector_instance
  load_sql(filenames, connector.host, connector.username, connector.password, alternate_database || connector.database)
end

end

