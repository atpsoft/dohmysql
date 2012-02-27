require 'bigdecimal'
require 'date'
require 'mysql2'

class Object
  def to_sql
    str = Mysql2::Client.escape(to_s)
    '"' + str + '"'
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

class Time
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
