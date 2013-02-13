require 'doh/mysql/connector_instance'
require 'open3'

module DohDb

def self.mysql_arg(value, option_specifier)
  if value.to_s.strip.empty? then '' else " -#{option_specifier}#{value}" end
end

def self.load_sql_using_one_popen(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  mysqlcmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database]
  io = IO.popen(mysqlcmd, 'r+')
  filenames.each do |elem|
    open(elem) {|file| io << file.read}
  end
  io.close
end

# this works on JRuby, but is slower than popen
def self.load_sql_using_each_backtick(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  basecmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database] + ' < '
  filenames.each do |elem|
    `#{basecmd} #{elem}`
  end
end

# pass through so we can change implemenation easily
def self.load_sql(dbconfig, filenames)
  if RUBY_ENGINE == "jruby"
    DohDb.load_sql_using_each_backtick(dbconfig, filenames)
  else
    DohDb.load_sql_using_one_popen(dbconfig, filenames)
  end
end

# trying Open3 now for better error handling; unknown as of yet if this works under JRuby
def self.load_sql_using_each_open3(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  basecmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database] + ' < '
  filenames.each do |elem|
    mysqlcmd = "#{basecmd} #{elem}"
    stdin, stdout, stderr = Open3.popen3(mysqlcmd)
    stdoutstr = stdout.read
    stdout.close
    stderrstr = stderr.read
    raise "#{stderrstr}" if !stderrstr.empty?
  end
end

end
