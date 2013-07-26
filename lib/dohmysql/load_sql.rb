require 'dohmysql/connector_instance'
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

def self.load_sql_using_each_open3(dbconfig, filenames)
  dohlog.debug("loading sql file: " + filenames.first) if filenames.size == 1

  basecmd = 'mysql' + mysql_arg(dbconfig[:host], 'h') + mysql_arg(dbconfig[:username], 'u') + mysql_arg(dbconfig[:password], 'p') + ' ' + dbconfig[:database] + ' < '
  filenames.each do |elem|
    mysqlcmd = "#{basecmd} #{elem}"
    Open3.popen3(mysqlcmd) do |stdin, stdout, stderr, wait_thr|
      # don't care about any stdout
      stdout.read
      errstr = stderr.read.strip
      errstr = '' if errstr == 'Warning: Using a password on the command line interface can be insecure.'
      status = wait_thr.value.exitstatus
      raise "mysql had stderr #{errstr}" unless errstr.empty?
      raise "mysql command failed with exit code #{status}" unless status == 0
    end
  end
end

end
