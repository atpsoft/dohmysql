require 'doh/mysql/connector_instance'

module DohDb

def self.mysql_arg(value, option_specifier)
  if value.to_s.strip.empty? then '' else " -#{option_specifier}#{value}" end
end

# NOTE: this doesn't work on jruby, but keeping it around in case it's determined to be significantly faster than the more portable version in place now
# in which case, we can use the popen version on the rubys that it works with and the other one as needed
def self.load_sql_using_popen(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  mysqlcmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database]
  io = IO.popen(mysqlcmd, 'r+')
  filenames.each do |elem|
    open(elem) {|file| io << file.read}
  end
  io.close
end

def self.load_sql(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  basecmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database] + ' < '
  filenames.each do |elem|
    `#{basecmd} #{elem}`
  end
end

end

