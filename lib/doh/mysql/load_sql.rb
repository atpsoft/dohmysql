require 'doh/mysql/connector_instance'

module DohDb

def self.mysql_arg(value, option_specifier)
  if value.to_s.strip.empty? then '' else " -#{option_specifier}#{value}" end
end

def self.load_sql(dbconfig, filenames)
  mysqlcmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database]
  io = IO::popen(mysqlcmd, 'r+')
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1
  filenames.each do |elem|
    open(elem) {|file| io << file.read}
  end
  io.close
end

end

