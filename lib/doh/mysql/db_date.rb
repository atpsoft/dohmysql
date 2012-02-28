require 'doh/core_ext/date'
require 'doh/core_ext/datewithtime'
require 'doh/mysql/to_sql'

module DohDb

class DateToday < Date
  def to_sql
    'CURDATE()'
  end
end

class DateTimeNow < DateTime
  def to_sql
    'NOW()'
  end
end

def self.today
  day = Date.utcday
  DateToday.new(day.year, day.month, day.mday)
end

def self.now
  dt = DateTime.utcnow
  DateTimeNow.new(dt.year, dt.month, dt.mday, dt.hour, dt.min, dt.sec, dt.zone)
end

end
