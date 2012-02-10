require 'bigdecimal'
require 'date'
begin
  require 'mysql'
  $mysql_loaded = true
rescue
  $mysql_loaded = false
end

class Object
  def to_sql
    if $mysql_loaded
      str = Mysql.escape_string(to_s)
    else
      str = non_mysql_escape_string
    end
    '"' + str + '"'
  end
private
  def non_mysql_escape_string
    str.gsub('\\', '\\\\').gsub('\'', '\\\'').gsub('"', '\\"')
  end
end

class NilClass
  def to_sql
    'NULL'
  end
end

class Numeric
  def to_sql
    to_s
  end
end

class DateTime
  def to_sql
    '"' + strftime('%Y-%m-%d %H:%M:%S') + '"'
  end
end

class TrueClass
  def to_sql
    '1'
  end
end

class FalseClass
  def to_sql
    '0'
  end
end

class BigDecimal
  def to_sql
    to_s('F')
  end
end

class Array
  def to_sql
    '(' + collect { |elem| elem.to_sql }.join(',') + ')'
  end
end
